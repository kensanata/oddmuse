# Copyright (C) 2017  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 13;

add_module('banned-regexps.pl');

## Edit banned regexps as a normal user should fail

test_page(update_page('BannedRegexps', "Voldemort # he must not be named\n",
		      'no naming'),
	  'This page does not exist');

## Edit banned regexps as admin should succeed

test_page(update_page('BannedRegexps', "Voldemort # he must not be named\n",
		      'no naming', 0, 1),
	  "Voldemort");

# Voldemort must not be named
test_page(update_page('Test', 'Voldemort', 'one banned word'),
	  'This page does not exist');

# error message is shown
test_page($redirect,
	  'banned text',
	  'wiki administrator',
	  'matched',
	  'See .*BannedRegexps.* for more information',
	  'Reason: he must not be named');

# Voldemort may be named by admins
test_page(update_page('Test', 'Voldemort', 'one banned word', 0, 1),
	  'Voldemort');

# Rename the page
AppendStringToFile($ConfigFile, "\$BannedRegexps = 'Local_Banned_Regexps';\n");

test_page(update_page('Local_Banned_Regexps', "Harry # he must not be named\n",
		      'no naming', 0, 1),
	  "Harry");

# Now Harry may not be named
test_page(update_page('Test2', 'Harry', 'one banned word'),
	  'This page does not exist');

# Voldemort may now be named
test_page(update_page('Test2', 'Voldemort', 'one banned word'),
	  'Voldemort');

# Make sure the underscores don't show up in the page link
test_page(get_page('action=admin'), 'Local Banned Regexps');
