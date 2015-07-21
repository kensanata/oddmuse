#! /usr/bin/perl

# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

=head1 mimedecode.pl

This script opens all files given as parameters on the command line
and destructively converts them to binary files.

Something similar could be achieved using command line tools.
Unfortunately, they are not always available. If Perl's MIME library
is available instead, you can use this script.

This particular version preserves the file's mtime in order to play
nice with raw.pl which relies on mtime.

=cut

use MIME::Base64;

local $/;
while (<>) {
  close ARGV;
  if (substr($_,0,6) eq '#FILE ') {
    print "decoding $ARGV\n";
    my $ts = (stat($ARGV))[9];
    s/^.*\n//;
    my $bytes = decode_base64($_);
    open(F, "> $ARGV");
    print F $bytes;
    close F;
    # restore mtime to collaborate with raw.pl
    utime $ts, $ts, $ARGV;
  }
}
