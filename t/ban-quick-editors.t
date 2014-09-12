# Copyright (C) 2013-2014  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 4;

clear_pages();

# switch it back on again
AppendStringToFile($ConfigFile, "\$SurgeProtection = 1;\n");
# make sure the visitors.log is filled
$ENV{'REMOTE_ADDR'} = '127.0.0.1';

add_module('ban-quick-editors.pl');

get_page('Test');
test_page(update_page('Test', 'cannot edit'),
	  'This page is empty');
test_page($redirect, 'Editing not allowed',
	  'fast editing spam bot');
sleep 5;
test_page(update_page('Test', 'edit succeeded'),
	  'edit succeeded');
