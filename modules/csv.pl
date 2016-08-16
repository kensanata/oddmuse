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

use strict;
use v5.10;

AddModuleDescription('csv.pl', 'Comments on Long Table Markup Extension');

our ($bol, @MyRules);

push(@MyRules, \&CsvRule);

my $RowCount;

sub CsvRule {
  # tables using <csv> -- the first row of a table
  if ($bol && m/\G&lt;csv&gt;\n/cg) {
    $RowCount = 1;
    return OpenHtmlEnvironment('table',1,'user csv')
      . AddHtmlEnvironment('tr', 'class="odd first"')
      . AddHtmlEnvironment('td');
  }
  # end of the row and beginning of the next row
  elsif (InElement('td') && m/\G[ \t]*\n([ \t]*)/cg) {
    my $type = ++$RowCount % 2 ? 'odd' : 'even';
    return qq{</td></tr><tr class="$type"><td>};
  }
  # an ordinary table cell
  elsif (InElement('td') && m/\G[ \t]*,[ \t]*/cg) {
    return "</td><td>";
  }
  # an empty line will end the table automatically; no closing tag is required
  return;
}
