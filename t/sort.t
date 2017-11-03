# Copyright (C) 2016  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 6;

add_module('sort.pl');

$page = get_page('search=first');
test_page($page, 'Sort by last update');
test_page_negative($page, 'Sort by creation date');

add_module('creationdate.pl');

$page = get_page('search=first');
test_page($page, 'Sort by creation date');

# by name: A B C
# by creation: C B A (oldest first)
# by update: B A C (last update first)

update_page('C', 'the first one by creation date');
sleep 2;
update_page('B', 'this page will get updated later');
sleep 2;
update_page('A', 'the first one by name');
sleep 2;
update_page('B', 'the first one by update date');
sleep 2;
update_page('D', 'this page is not searched for');

test_page(join(', ', grep(/^title: /, split(/\n/, get_page('search=first raw=1')))),
	  'title: A, title: B, title: C');
test_page(join(', ', grep(/^title: /, split(/\n/, get_page('search=first sort=update raw=1')))),
	  'title: B, title: A, title: C');
test_page(join(', ', grep(/^title: /, split(/\n/, get_page('search=first sort=creation raw=1')))),
	  'title: C, title: B, title: A');
