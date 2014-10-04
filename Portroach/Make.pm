#------------------------------------------------------------------------------
# Copyright (C) 2006-2011, Shaun Amott <shaun@inerd.com>
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

package Portroach::Make;

use strict;

require 5.006;


#------------------------------------------------------------------------------
# Globals
#------------------------------------------------------------------------------

my $root_dir;
my $make_cache;

my $debug = 0;

my %wanted = ();

my $qfail = 0;


#------------------------------------------------------------------------------
# Func: new()
# Desc: Constructor - does nothing useful.
#
# Args: n/a
#
# Retn: $self
#------------------------------------------------------------------------------

sub new
{
	my $self  = {};
	my $class = shift;

	bless ($self, $class);
	return $self;
}


#------------------------------------------------------------------------------
# Accessor functions
#------------------------------------------------------------------------------

sub Root
{
	my $self = shift;

	if (@_) {
		$root_dir = shift;
		$root_dir =~ s/^(.+)\/$/$1/;
	}

	return $root_dir;
}

sub Wanted
{
	my $self = shift;

	%wanted = ();

	while (my $k = shift) {
		$wanted{$k} = 1
	}
}

sub Debug
{
	my $self = shift;

	$debug = shift if (@_);

	return $debug;
}


#------------------------------------------------------------------------------
# Func: Make()
# Desc: Ask make(1) to expand and return values for specified variables
#
# Args: $dir      - Directory to execute make in. Appends $root_dir
#                   if there's no leading slash.
#       @vars     - List of variables. (optional)
#
# Retn: [results] - Ref. to hash of results - unless there was only
#                   one variable, in which case return a string.
#------------------------------------------------------------------------------

sub Make
{
	my $self = shift;

	my ($force_show, $dir, @vars) = @_;

	my (%results, @outp, $list, $cache, $lb, $doshow);

	$cache = $make_cache ? $make_cache : '';

	$dir = "$root_dir/$dir" if ($dir !~ /^\//);

	@vars = keys %wanted if (scalar @vars == 0);

	# For a single variable just use -V, unless requested otherwise.
	if ($#vars > 1 || $force_show) {
		$doshow = 1;
	}

	if ($doshow) {
		$list = join('\\ ', @vars);
	} else {
		$list = join(' ', @vars);
	}

	# Ensure we aren't affected by locally installed stuff
	$lb = 'LOCALBASE=/nonexistent';

	# Undo list of variable annotation
	$list =~ s,\'\$\{,,g; $list =~ s,\}\',,g;
	if ($doshow) {
		#print("make show=${list} in ${dir}\n") if $debug;
		@outp = split /\n/, qx(cd $dir && make show=$list);
	} else {
		#print("make -V ${list} in ${dir}\n") if $debug;
		@outp = split /\n/, qx(cd $dir && make -V $list);
	}

	if ($?) {
		warn "make failed for $dir";
		return;
	}

	if ($#vars == 0) {
	    # Return first element if only a single variable was requested,
	    # unless we have a lot more results.
	    if ($#outp == 0) {
		return $outp[0];
	    } else {
		return @outp;
	    }
	}

	foreach (@vars) {
		$results{$_} = shift @outp;
	}

	return \%results;
}


#------------------------------------------------------------------------------
# Func: InitCache()
# Desc: Prepare a cache of make(1) variables for Make(). This essentially
#       saves a dozen forks each time make is invoked, saving us precious
#       time while populating the database.
#
# Args: @vars    - List of variables to cache.
#
# Retn: $success - true/false
#------------------------------------------------------------------------------

sub InitCache
{
	my $self = shift;

	my (@vars) = @_;

	my ($mv, $list);

	$make_cache = '';

	return 0 if (!$root_dir || !@vars);

	$mv = $self->Make($root_dir, @vars);

	if ($#vars == 0) {
		$make_cache = "$vars[0]=$mv";
		return 1;
	}

	$make_cache .= "$_=". ($mv->{$_} || '')
		foreach (keys %$mv);

	return 1;
}

1;
