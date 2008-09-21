# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 3;
clear_pages();

add_module('listlocked.pl');

update_page('test', 'test');

test_page(get_page('action=listlocked'),
	  '<div class="content list locked"><p></p></div>');

get_page('action=pagelock id=test set=1 pwd=foo');

test_page(get_page('action=listlocked raw=1'),
	  "\ntest\n");

xpath_test(get_page('action=listlocked'),
	   '//div/p/a[text()="test"]');
