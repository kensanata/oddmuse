#! /usr/bin/perl -w

# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 Anonymize oldrc.log Files

This script will read your oldrc.log file and replace the host field
with 'Anonymous'. This is what the main script started doing
2013-11-30.

When you run this script, it sets the main lock to prevent maintenance
from running. You can therefore run it on a live system.

=cut

use strict;

sub verify_setup {
  if (not -f 'oldrc.log') {
    die "Run this script in your data directory.\n"
      . "The oldrc.log file should be in the same directory.\n";
  }
  if (not -d 'temp') {
    die "Run this script in your data directory.\n"
      . "The temp directory should be in the same directory.\n";
  }
}

sub request_lock {
  if (-d 'temp/lockmain') {
    die "The wiki is currently locked.\n"
      . "Rerun this script later.\n";
  }
  mkdir('temp/lockmain') or die "Could not create 'temp/lockmain'.\n"
    . "You probably don't have the file permissions necessary.\n";
}

sub release_lock {
  rmdir('temp/lockmain') or die "Could not remove 'temp/lockmain'.\n"
}

sub anonymize {
  open(F, 'oldrc.log') or die "Could not open 'oldrc.log' for reading.\n";
  open(B, '>oldrc.log~') or die "Could not open 'oldrc.log~' for writing.\n"
    . "I will not continue without having a backup available.\n";
  my $FS  = "\x1e"; # The FS character is the RECORD SEPARATOR control char
  my @lines = ();
  while (my $line = <F>) {
    my ($ts, $id, $minor, $summary, $host, @rest) = split(/$FS/o, $line);
    if ($id eq '[[rollback]]') {
      # rollback markers are very different
      push(@lines, $line);
    } else {
      # anonymize
      push(@lines, join($FS, $ts, $id, $minor, $summary, 'Anonymous', @rest));
    }
    print B $line;
  }
  close(F);
  open(F, '>', 'oldrc.log') or die "Could not open 'oldrc.log' for writing.\n";
  for my $line (@lines) {
    print F $line; # @rest ends with a newline
  }
  close(F);
  print "Wrote anonymized 'oldrc.log'.\n";
  print "Saved a backup as 'oldrc.log~'\n";
}

sub main {
  verify_setup();
  request_lock();
  anonymize();
  release_lock();
}

main();
