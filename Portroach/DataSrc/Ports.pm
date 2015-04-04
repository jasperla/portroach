#------------------------------------------------------------------------------
# Copyright (C) 2010, Shaun Amott <shaun@inerd.com>
# Copyright (C) 2015, Jasper Lievisse Adriaanse <j@jasper.la>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#------------------------------------------------------------------------------

package Portroach::DataSrc::Ports;

use base qw(Portroach::DataSrc);

use File::stat;

use URI;

use Try::Tiny;

use Portroach::Const;
use Portroach::Config;
use Portroach::API;
use Portroach::Util;

use strict;

require 5.006;


#------------------------------------------------------------------------------
# Globals
#------------------------------------------------------------------------------

our %settings;


#------------------------------------------------------------------------------
# Func: new()
# Desc: Constructor.
#
# Args: n/a
#
# Retn: $self
#------------------------------------------------------------------------------

sub new
{
	my $class = shift;

	my $self = {};

	bless ($self, $class);

	return $self;
}


#------------------------------------------------------------------------------
# Func: Build()
# Desc: Perform a full database build.
#
# Args: n/a
#
# Retn: $success - true/false
#------------------------------------------------------------------------------

sub Build
{
    my $self = shift;
    my $sdbh = shift;

    return $self->BuildDB($sdbh);
}


#------------------------------------------------------------------------------
# Func: Rebuild()
# Desc: Perform a partial (incremental) database build.
#
# Args: n/a
#
# Retn: $success - true/false
#------------------------------------------------------------------------------

sub Rebuild
{
	my $self = shift;
        my $sdbh = shift;

	return $self->BuildDB($sdbh, 1);
}

#------------------------------------------------------------------------------
# Func: BuildDB()
# Desc: Build database.
#
# Args: $incremental - true if we're just doing a partial update.
#
# Retn: $success     - true/false
#------------------------------------------------------------------------------

sub BuildDB
{
	my $self = shift;

	my ($sdbh, $incremental) = @_;

	my (%sths, $dbh,  %portsmaintok, $mfi, @ports,
		$num_ports, $got_ports, $buildtime, $ssth, %psths);

	my $ps = Portroach::API->new;

	my $lastbuild = getstat('buildtime', TYPE_INT);

	print "Looking for updated ports...\n\n" if ($incremental);

	$got_ports = 0;
	$num_ports = 0;
	$buildtime = time;

	$dbh = connect_db();

	prepare_sql($dbh, \%sths,
		qw(portdata_masterport_str2id portdata_masterport_enslave
		   portdata_findslaves)
	);

	if ($settings{restrict_maintainer}) {
		print "Querying for maintainer associations...\n";

		$ssth = $sdbh->prepare("SELECT fullpkgpath FROM Ports WHERE MAINTAINER like ?;");
		$ssth->execute("%".$settings{restrict_maintainer}."%") or die DBI->errstr;
	        my @ports_by_maintainer;
		while(@ports_by_maintainer = $ssth->fetchrow_array()) {
		    my $port = $ports_by_maintainer[0];
		    $portsmaintok{$port} = $settings{restrict_maintainer};
		}
	}

	# Query SQLports for all the information we need. We don't care about
	# restrictions for now as this step basically copies sqlports. Check()
	# will handle any restrictions instead.
	# XXX: Re-add support for $incremental
	$num_ports = $sdbh->selectrow_array("SELECT COUNT(FULLPKGPATH) FROM Ports;");

	print "\n" unless ($num_ports < 1 or $settings{quiet});

	if ($num_ports > 1) {
	    print("Building...\n\n");
	} else {
	    print("None found!\n");
	}

	BuildPort($ps, $sdbh);

	if ($num_ports > 1) {
		print "\n" unless ($settings{quiet});
	}

	setstat('buildtime', $buildtime);

	finish_sql(\$dbh, \%sths);

	return 1;
}

# Queries SQLports for:
sub BuildPort
{
    my ($ps, $sdbh) = @_;
    my (@ports, $ssth);
    my $n_port = 0;
    my $total_ports = $sdbh->selectrow_array("SELECT COUNT(FULLPKGPATH) FROM Ports;");

    $ssth = $sdbh->prepare("SELECT FULLPKGPATH, CATEGORIES, DISTNAME, DISTFILES, MASTER_SITES, MAINTAINER, COMMENT, PORTROACH, EXTRACT_SUFX FROM Ports");
    $ssth->execute() or die DBI->errstr;

    while(@ports = $ssth->fetchrow_array()) {
	my ($fullpkgpath, $name, $category, $distname, @distfiles, $maintainer,
	    $comment, $version, $sufx, %pcfg, @sites, $ver);
	$n_port++;

	$fullpkgpath = $ports[0];
	$category    = primarycategory($ports[1]);

	# Bail out early if the port has no distfiles to begin with
	next if (split(/ /, $ports[3]) < 1);

	$name     = fullpkgpathtoport($fullpkgpath);

	$distname = $ports[2];
	foreach my $file (split /\s+/, $ports[3]) {
	    $file =~ s/:[A-Za-z0-9][A-Za-z0-9\,]*$//g;
	    push @distfiles, $file;
	}
	$maintainer = $ports[5];
	$comment    = $ports[6];
	foreach (split /\s+/, $ports[7]) {
		if (/^([A-Za-z]+):(.*)$/i) {
			$pcfg{lc $1} = $2;
		}
	}
	$sufx = $ports[8];
	foreach my $site (split /\s+/, $ports[4]) {
		my $ignored = 0;

		$site =~ s/^\s+//;
		$site =~ s/\/+$/\//;
		$site =~ s/:[A-Za-z0-9][A-Za-z0-9\,]*$//g; # site group spec.
		if (length($site) == 0) {
			print "Empty or no master sites for $fullpkgpath \n" unless ($settings{quiet});
			next;
		}
		try {
			$site = URI->new($site)->canonical;
			next if (length $site->host == 0);

			my $mastersite_regex = Portroach::Util::restrict2regex($settings{mastersite_ignore});
			if ($mastersite_regex) {
				$ignored = 1 if ($site =~ /$mastersite_regex/);
			}

			push(@sites, $site) unless $ignored;
		} catch {
			warn "caught error: $_";
		};
	}

	if ($distname =~ /\d/) {
		my $name_q;
		$ver = $distname;
		$name_q = quotemeta $name;

		$name_q =~ s/^(node|p5|mod|py|ruby|hs)(?:[\-\_])/($1\[\\-\\_\])?/;

		# XXX: fix me
		my $chop =
			'sources?|bin|src|snapshot|freebsd\d*|freebsd-?\d\.\d{1,2}|'
			. 'linux|unstable|elf|i\d86|x86|sparc|mips|linux-i\d86|html|'
			. 'en|en_GB|en_US|full-src|orig|setup|install|export|'
			. 'fbsd[7654]\d{1,2}|export|V(?=\d)';

		foreach (split '\|', $chop) {
			unless ($name =~ /($_)/i) {
				$ver =~ s/[\.\-\_]?($chop)$//gi;
				$ver =~ s/^($chop)[\.\-\_]?//gi;
			}
		}

		unless ($ver =~ s/.*$name_q[-_\.]//i) {
			# Resort to plan B
			if ($ver =~ /^(.*)-(.*)$/) {
				$ver = $2;
			} elsif ($name !~ /\d/) {
				$ver =~ s/^\D*(\d.*)$/$1/;
			}
		}

		# Sanity check, if $ver doesn't match what matched the common
		# case, fix it up. Prevents recording '-core-2.1' as version.
		if ($distname =~ /^(.*)-(\d[^-]*)$/) {
		    if ($ver ne $2) {
			$name = $1;
			$ver = $2;
		    }
		}

		# If the $name is digits-only, try harder to make something
		# sensible from it.
		if ($name =~ /^\d*$/) {
			if ($distname =~ /^(.*)-(\d[^-]*)[-]?(\w*)(.*)$/) {
				$name = $1;
				$ver = $2;
			}
		}

		$ver = '' if ($ver eq $name);
	}


	print '[' . strchop($category, 15) . '] ' unless ($settings{quiet});
	info($name, "($n_port out of $total_ports)");

	$ps->AddPort({
	    'name'        => $name,
	    'category'    => $category,
	    'version'     => $ver,
	    'maintainer'  => $maintainer,
	    'comment'     => $comment,
	    'distname'    => $distname,
	    'suffix'      => $sufx,
	    'distfiles'   => \@distfiles,
	    'sites'       => \@sites,
	    'options'     => \%pcfg,
	    'fullpkgpath' => $fullpkgpath,
	});
    }

    return 1;
}

#------------------------------------------------------------------------------
# Func: Exists()
# Desc: Verify if a given directory still contains what appears to be a valid port
#
# Args: $dir - Directory to check.
#
# Retn: $rc - true/false
#------------------------------------------------------------------------------

sub Exists
{
	my $self = shift;
	my ($dir) = @_;
	my $rc = 1;

	# Simple heuristics to determine if a given directory still contains a valid port.
	$rc = 0 unless (-d $settings{ports_dir} . "/" . ${dir});
	$rc = 0 unless (-f $settings{ports_dir} . "/" . ${dir} . "/Makefile");

	return ($rc)
}


1;
