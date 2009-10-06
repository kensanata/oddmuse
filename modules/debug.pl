#! /usr/bin/perl
# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>

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

package OddMuse;

@Debugging = (\&DebugInterLinks);

sub DebugInterLinks {
  print $q->h2(T('Inter links:')) . $q->p(join(', ', sort keys %InterSite))
    if %InterSite;
}

*OldPrintFooter = *PrintFooter;
*PrintFooter = *NewPrintFooter;

sub NewPrintFooter {
  OldPrintFooter(@_);
  print "Debug Info: $DebugInfo";
}
