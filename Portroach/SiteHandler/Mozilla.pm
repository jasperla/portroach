#------------------------------------------------------------------------------
# Copyright (C) 2015, Landry Breuil <landry@openbsd.org>
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

package Portroach::SiteHandler::Mozilla;

use LWP::UserAgent;

use Portroach::Const;
use Portroach::Config;

use strict;

require 5.006;


#------------------------------------------------------------------------------
# Globals
#------------------------------------------------------------------------------

push @Portroach::SiteHandler::sitehandlers, __PACKAGE__;

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
	my $self      = {};
	my $class     = shift;

	$self->{name} = 'Mozilla';

	bless ($self, $class);
	return $self;
}


#------------------------------------------------------------------------------
# Func: CanHandle()
# Desc: Ask if this handler (package) can handle the given site.
#
# Args: $url - URL of site.
#
# Retn: $res - true/false.
#------------------------------------------------------------------------------

sub CanHandle
{
	my $self = shift;

	my ($url) = @_;

	return ($url =~ /pub\/mozilla\.org/);
}


#------------------------------------------------------------------------------
# Func: GetFiles()
# Desc: Extract a list of files from the given URL. In the case of Mozilla,
#       we are removing .source from the distname and checking in the parent^2
#       directory.
#
# Args: $url     - URL we would normally fetch from.
#       \%port   - Port hash fetched from database.
#       \@files  - Array to put files into.
#
# Retn: $success - False if file list could not be constructed; else, true.
#------------------------------------------------------------------------------

sub GetFiles
{
	my $self = shift;

	my ($url, $port, $files) = @_;
	my ($v, $ua, $resp);
	# remove .source from ver
	# check for esr and replace with latest accordingly
	$v = $port->{ver};
	$v =~ s/\.source//;
	# seamonkey doesnt have latest symlinks
	if ($url =~ /seamonkey/) {
		$v =~ /^(\d)\.(\d+)/;
		my $r = "$1.".($2+1);
		$url =~ s/$v/$r/;
	} elsif ($port->{ver} =~ /esr/) {
		$url =~ s/$v/latest-esr/;
	} else {
		$url =~ s/$v/latest/;
	}
	_debug("GET $url");
	$ua = LWP::UserAgent->new;
	$ua->agent(USER_AGENT);
	$resp = $ua->request(HTTP::Request->new(GET => $url));

	if ($resp->is_success) {
	    $resp->decoded_content =~ /href="([\w\d\.-]+\.source\.tar\.(bz2|xz))"/;
	    _debug("FOUND $url$1");
	    push(@$files, "$url$1");
	} else {
	    _debug("GET failed: " . $resp->code);
	}

	return 1;
}


#------------------------------------------------------------------------------
# Func: _debug()
# Desc: Print a debug message.
#
# Args: $msg - Message.
#
# Retn: n/a
#------------------------------------------------------------------------------

sub _debug
{
	my ($msg) = @_;

	$msg = '' if (!$msg);

	print STDERR "(" . __PACKAGE__ . ") $msg\n" if ($settings{debug});
}

1;
