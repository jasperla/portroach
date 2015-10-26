#------------------------------------------------------------------------------
# Copyright (C) 2015, Jasper Lievisse Adriaanse <jasper@openbsd.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
#------------------------------------------------------------------------------

package Portroach::SiteHandler::Launchpad;

use JSON qw(decode_json);
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

	$self->{name} = 'Launchpad';

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

	return ($url =~ /launchpad\.net/);
}


#------------------------------------------------------------------------------
# Func: GetFiles()
# Desc:
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

	my ($gems_host, $gem, $resp, $query, $ua);
	# $lp . "zeitgeist/releases"
	my $lp = 'https://api.launchpad.net/1.0/';
	my $project;

	# Strip all the digits at the end to keep the project name.
	if ($port->{distname} =~ /(.*?)-(\d+)/) {
	    $project = $1;
	}

	$query = $lp . $project . "/releases";

	_debug("GET $query");
	$ua = LWP::UserAgent->new;
	$ua->agent(USER_AGENT);
	$resp = $ua->request(HTTP::Request->new(GET => $query));

	if ($resp->is_success) {
	    my %entries = %{decode_json($resp->decoded_content)};

	    # 'entries' is a singleton array, where the first element
	    # contains hashes with the actual entries
	    foreach my $e (keys($entries{entries})) {
		my $files_collection_link = $entries{entries}[$e]->{files_collection_link};

		# Now that we have the files_collection_link, retrieve that so
		# we can properly build the files array.
		my $fcl_ua = LWP::UserAgent->new;
		$fcl_ua->agent(USER_AGENT);
		my $fcl_resp = $fcl_ua->request(HTTP::Request->new(GET => $files_collection_link));

		if ($fcl_resp->is_success) {
		    my %entries_fcl = %{decode_json($fcl_resp->decoded_content)};

		    foreach my $ef (keys($entries_fcl{entries})) {
			my $self_link = $entries_fcl{entries}[$ef]->{self_link};
			push @$files, $self_link;
		    }
		} else {
		    _debug("GET failed: " . $fcl_resp);
		    return 0;
		}
	    }
	} else {
	    _debug("GET failed: " . $resp->code);
	    return 0;
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
