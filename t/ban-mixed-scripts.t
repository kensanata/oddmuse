# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 4;
use utf8; # tests contain UTF-8 characters and it matters

add_module('ban-mixed-scripts.pl');

# ordinary page editing still works
test_page(update_page('Test', 'This is a test'),
	  'This is a test');
test_page(update_page('Test', '🙇🏽‍ 本当にごめんね – I am really sorry.'),
	  'I am really sorry');

# mixed scripts are not ok
test_page(update_page('Test', "It's diffіcult to find knowledgeable people on this topic, but youu sound like you know wgat you're taⅼkіng аboսt!"),
	  'I am really sorry');

# error message is shown
test_page($redirect, "Mixed scripts");
