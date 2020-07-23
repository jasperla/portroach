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

package Portroach::SiteHandler::GitHub;

use JSON qw(decode_json);
use LWP::UserAgent;
use URI;

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

	$self->{name} = 'GitHub';

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

	return ($url =~ /https:\/\/github\.com\//);
}


#------------------------------------------------------------------------------
# Func: GetFiles()
# Desc: Extract a list of files from the given URL. In the case of GitHub,
#       we are actually pulling the files from the project's Atom feed and
#       extract the release url, containing the tag it was based on.
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
	my $projname;

	if ($url =~ /https:\/\/github\.com\/(.*?)\/archive\//) {
		$projname = $1;
	} elsif ($url =~ /https:\/\/github.com\/downloads\/(.*)\//) {
		$projname = $1;
	} elsif ($url =~ /https:\/\/github.com\/(.*?)\/releases\//) {
		$projname = $1;
	}

	if ($projname) {
		my ($query, $ua, $response, $items, $json);

		# First check if there's a latest releases endpoint
		$query = 'https://api.github.com/repos/' . $projname . '/releases/latest';

		_debug("GET $query");
		$ua = LWP::UserAgent->new;
		$ua->agent(USER_AGENT);
		$ua->timeout($settings{http_timeout});

		my $request;

		if ($settings{github_token}) {
			#$req->authorization_basic('token', $settings{github_token});
			my $auth_header = HTTP::Headers->new ('Authorization' => "Token $settings{github_token}");
			$request = HTTP::Request->new(GET => $query, $auth_header);
		} else {
			$request = HTTP::Request->new(GET => $query);
		}

		$response = $ua->request($request);

		if ($response->is_success) {
			$json = decode_json($response->decoded_content);

			my $filename = (URI->new($json->{tarball_url})->path_segments)[-1];
			_debug("  -> " . $filename);
			$filename =~ s/^v//;
			$projname =~ m/.*?\/(.*)/;

			# In some cases the project name (read: repository) is part of the tagname.
			# For example: 'heimdal-7.3.0' is the full tagname. Therefore remove the
			# repository name from the filename just in case.
			my ($account, $repo) = split('/', $projname);
			$filename =~ s/^${repo}-//;

			# Use '%%' as a placeholder for easier splitting in FindNewestFile().
			_debug("pushing: " . $repo . "%%" . $filename . ".tar.gz with projname:${projname} account:${account} repo:${repo} filename:${filename}");
			push(@$files, $repo . "%%" . $filename . ".tar.gz");
		} else {
			if ($response->header('x-ratelimit-remaining') == 0) {
				print STDERR ("Error: API rate limit exceeded, please set 'github token' in portroach.conf\n");
			}
			_debug('GET failed for /latest: ' . $response->status_line);
			# Project didn't do any releases, so let's try tags instead.
			$query = 'https://api.github.com/repos/' . $projname . '/tags';
			_debug("GET $query");
			$ua = LWP::UserAgent->new;
			$ua->agent(USER_AGENT);
			$ua->timeout($settings{http_timeout});

			$response = $ua->request(HTTP::Request->new(GET => $query));

			if (!$response->is_success || $response->status_line !~ /^2/) {
				_debug('GET failed: ' . $response->status_line);
				return 0;
			}

			$json = decode_json($response->decoded_content);
			foreach my $tag (@$json) {
				my $tag_url = $tag->{tarball_url};
				_debug("  -> $tag_url");
				push(@$files, $tag_url);
			}
		}
		_debug('Found ' . scalar @$files . ' files');
	} else {
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
