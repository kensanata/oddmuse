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
use Test::More tests => 8;

clear_pages();

update_page('2009-08-14', 'this is the first page');
update_page('2009-08-15', 'this is the second page');
update_page('Archive', '<search second>');
# erste Seite ist ok
$page = get_page('2009-08-14');
test_page($page, 'first');
test_page_negative($page, 'second');
# Archiv Seite ist ok
$page = get_page('Archive');
xpath_test($page, '//a[text()="2009-08-15"]');
negative_xpath_test($page, '//a[text()="2009-08-14"]');
# erste Seite ist immer noch ok
$page = get_page('2009-08-14');
test_page($page, 'first');
test_page_negative($page, 'second');
# zweite Seite ist immer noch ok
$page = get_page('2009-08-15');
test_page($page, 'second');
test_page_negative($page, 'first');
