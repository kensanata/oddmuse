#!/usr/bin/perl -w

# Copyright 2005  Alex Schroeder <alex@emacswiki.org>

# Based on commit-email.pl, which is part of Subversion.
# ====================================================================
# Copyright (c) 2000-2004 CollabNet.  All rights reserved.
#
# This software is licensed as described in the file COPYING, which
# you should have received as part of this distribution.  The terms
# are also available at http://subversion.tigris.org/license-1.html.
# If newer versions of this license are posted there, you may use a
# newer version instead, at your option.
#
# This software consists of voluntary contributions made by many
# individuals.  For exact contribution history, see the revision
# history and logs, available at http://subversion.tigris.org/.
# ====================================================================

# Turn on warnings the best way depending on the Perl version.
BEGIN {
  if ( $] >= 5.006_000)
    { require warnings; import warnings; }
  else
    { $^W = 1; }
}

use strict;
use Carp;
use File::Basename;
use LWP::UserAgent;

######################################################################
# Configuration section.

# Svnlook path.
my $svnlook = "/usr/bin/svnlook";

# End of Configuration section.
######################################################################

# Since the path to svnlook depends upon the local installation
# preferences, check that the required programs exist to insure that
# the administrator has set up the script properly.
{
  my $ok = 1;
  foreach my $program ($svnlook)
    {
      if (-e $program)
        {
          unless (-x $program)
            {
              warn "$0: required program `$program' is not executable, ",
                   "edit $0.\n";
              $ok = 0;
            }
        }
      else
        {
          warn "$0: required program `$program' does not exist, edit $0.\n";
          $ok = 0;
        }
    }
  exit 1 unless $ok;
}


######################################################################
# Initial setup/command-line handling.

# repository path, revision number, and url to post to
my ($repos, $rev, $url) = @ARGV;

# If the last argument is undefined, then there were not enough
# command line arguments.
&usage("$0: too few arguments.") unless defined $url;

# Check the validity of the command line arguments.  Check that the
# revision is an integer greater than 0 and that the repository
# directory exists.
unless ($rev =~ /^\d+/ and $rev > 0)
  {
    &usage("$0: revision number `$rev' must be an integer > 0.");
  }
unless (-e $repos)
  {
    &usage("$0: repos directory `$repos' does not exist.");
  }
unless (-d _)
  {
    &usage("$0: repos directory `$repos' is not a directory.");
  }
unless ($url =~ m!http://!)
  {
    &usage("$0: wiki url `$url' is not an URL.");
  }

######################################################################
# Harvest data using svnlook.

# Get the author, date, and log from svnlook.
my @svnlooklines = &read_from_process($svnlook, 'info', $repos, '-r', $rev);
my $author = shift @svnlooklines;
my $date = shift @svnlooklines;
shift @svnlooklines;
my @log = @svnlooklines;

# Figure out what files have changed using svnlook.
@svnlooklines = &read_from_process($svnlook, 'changed', $repos, '-r', $rev);

# Parse the changed nodes.
my @paths = ();
foreach my $line (@svnlooklines)
  {
    # Split the line up into the modification code and path, ignoring
    # property modifications.
    if ($line =~ /^(.).  (.*)$/)
      {
	push(@paths, $2);
      }
  }

######################################################################
# Post to the wiki

foreach my $path (@paths) {
  my $id = basename($path);
  my $log = join("\n", @log);
  my @data = &read_from_process($svnlook, 'cat', $repos, $path, '-r', $rev);
  my $data = join("\n", @data);
  my $ua = LWP::UserAgent->new;
  $ua->post($url, { title=>$id,
		    username=>$author,
		    summary=>$log,
		    text=>$data});
}

exit 0;

sub usage
{
  warn "@_\n" if @_;
  die "usage: $0 REPOS REVNUM URL\n";
}

# Start a child process safely without using /bin/sh.
sub safe_read_from_pipe
{
  unless (@_)
    {
      croak "$0: safe_read_from_pipe passed no arguments.\n";
    }

  my $pid = open(SAFE_READ, '-|');
  unless (defined $pid)
    {
      die "$0: cannot fork: $!\n";
    }
  unless ($pid)
    {
      open(STDERR, ">&STDOUT")
        or die "$0: cannot dup STDOUT: $!\n";
      exec(@_)
        or die "$0: cannot exec `@_': $!\n";
    }
  my @output;
  while (<SAFE_READ>)
    {
      s/[\r\n]+$//;
      push(@output, $_);
    }
  close(SAFE_READ);
  my $result = $?;
  my $exit   = $result >> 8;
  my $signal = $result & 127;
  my $cd     = $result & 128 ? "with core dump" : "";
  if ($signal or $cd)
    {
      warn "$0: pipe from `@_' failed $cd: exit=$exit signal=$signal\n";
    }
  if (wantarray)
    {
      return ($result, @output);
    }
  else
    {
      return $result;
    }
}

# Use safe_read_from_pipe to start a child process safely and return
# the output if it succeeded or an error message followed by the output
# if it failed.
sub read_from_process
{
  unless (@_)
    {
      croak "$0: read_from_process passed no arguments.\n";
    }
  my ($status, @output) = &safe_read_from_pipe(@_);
  if ($status)
    {
      return ("$0: `@_' failed with this output:", @output);
    }
  else
    {
      return @output;
    }
}


