# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 3;

# simple, single page rollback

# ($ts, $id, $minor, $summary, $host, $username, $revision, $languages, $cluster)
# ($ts, '[[rollback]]', $to, $page)

clear_pages();
WriteStringToFile ($RcFile, "1Aone1\n"); # original
AppendStringToFile($RcFile, "2Atwo2\n"); # to be rolled back
AppendStringToFile($RcFile, "3A0one3\n"); # back to the original
AppendStringToFile($RcFile, "3[[rollback]]1A\n"); # rollback marker

local $/ = "\n"; # undef in test.pl

my @lines = GetRcLines(1);
is(scalar(@lines), 1, "starting situation contains just one line");
is($lines[0][0], 3, "simple rollback starts with 3");

AppendStringToFile($RcFile, "4Athree4\n");

# print "GetRcLines\n";
# for my $line (GetRcLines(1)) {
#   my ($ts, $id, $minor, $summary) = @$line;
#   print "$ts, $id, $minor, $summary\n";
# }

SetParam('all', 1);
my @lines = GetRcLines(1);
is(scalar(@lines), 4, "using all=1, see all four major revisions");


# This could be an interesting test framework.

