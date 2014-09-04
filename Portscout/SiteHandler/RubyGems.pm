#------------------------------------------------------------------------------
# Copyright (C) 2014, Jasper Lievisse Adriaanse <jasper@openbsd.org>
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

package Portscout::SiteHandler::RubyGems;

use JSON qw(decode_json);
use LWP::UserAgent;

use Portscout::Const;
use Portscout::Config;

use strict;

require 5.006;


#------------------------------------------------------------------------------
# Globals
#------------------------------------------------------------------------------

push @Portscout::SiteHandler::sitehandlers, __PACKAGE__;

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

	$self->{name} = 'RubyGems';

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

	return ($url =~ /http:\/\/rubygems\.org\/downloads\//);
}


#------------------------------------------------------------------------------
# Func: GetFiles()
# Desc: Extract a list of files from the given URL. For RubyGems.org we query
#        the API for all available versions and iteratively store them.
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

	my ($api_url, $gem, $resp, $ua);
	my $gems_host = 'https://rubygems.org/api/v1/versions/';

	# Strip all the digits at the end to keep the stem of the Gem.
	if ($port->{distname} =~ /(.*?)-(\d+)/) {
	    $gem = $1;
	}

	$api_url = $gems_host . $gem . '.json';

	_debug("GET $api_url");
	$ua = LWP::UserAgent->new;
	$resp = $ua->request(HTTP::Request->new(GET => $api_url));

	if ($resp->is_success) {
	    my @releases = @{decode_json($resp->decoded_content)};
	    foreach my $release (@releases) {
		my $gem_url = $url . $gem . '-' . $release->{number} . '.gem';
	        push @$files, $gem_url;
	    }
	} else {
	    my $code = $resp->code;
	    _debug("GET failed: $code");
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

	print STDERR "(SiteHandler::RubyGems) $msg\n"
		if ($settings{debug});
}


1;
