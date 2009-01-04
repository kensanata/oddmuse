# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 14;
clear_pages();

AppendStringToFile($ConfigFile, "\$SurgeProtection = 1;\n");

# check surge protection
for (1..$SurgeProtectionViews) {
  test_page(get_page('action=browse id=HomePage username=Alex'),
	    'Status: 404 NOT FOUND');
}
test_page(get_page('action=browse id=HomePage username=Alex'),
	  'Status: 503 SERVICE UNAVAILABLE',
	  'Too many connections by Alex',
	  "Please do not fetch more than $SurgeProtectionViews pages in $SurgeProtectionTime seconds.");
sleep($SurgeProtectionTime);
test_page(get_page('action=browse id=HomePage username=Alex'),
	  'Status: 404 NOT FOUND');
