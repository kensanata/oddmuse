# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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
use Test::More tests => 9;

add_module('rename-pages.pl');

test_page(update_page('A', 'Alpha'), 'Alpha');
test_page(get_page('action=rename-page'), 'Page name is missing');
test_page(get_page('action=rename-page id=X to=Y'), 'Source page does not exist');
test_page(get_page('action=rename-page id=A to=A'), 'Target page already exists');
test_page(get_page('action=rename-page id=A to=B'),
	  'Status: 302',
	  'Location: .*wiki.pl/B');
test_page(get_page('A'),
	  'Status: 302',
	  'Location: .*wiki.pl\?action=browse;oldid=A;id=B');
test_page(get_page('B'), 'Alpha');
