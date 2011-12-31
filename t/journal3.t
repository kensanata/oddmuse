# Copyright (C) 2011  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 34;

clear_pages();

update_page('2011-12-17', "today");
update_page('2011-12-16', "yesterday");
update_page('2011-12-15', "before yesterday");
update_page('2011-12-14', "this Wednesday");
update_page('2011-12-13', "this Tuesday");

update_page('2011-12-12', "this Monday");
update_page('2011-12-11', "last Sunday");
update_page('2011-12-10', "last Saturday");
update_page('2011-12-09', "last Friday");
update_page('2011-12-08', "Thursday a week ago");

# check that the limit is taken into account
$page = update_page('Summary', "This is my journal:\n\n<journal 5>");

test_page($page, '2011-12-17', '2011-12-16', '2011-12-15',
	  '2011-12-14', '2011-12-13');
test_page_negative($page, '2011-12-12', '2011-12-11', '2011-12-10',
	  '2011-12-09', '2011-12-08');

xpath_test($page, '//a[@href="http://localhost/wiki.pl?action=more;num=5;regexp=^\d\d\d\d-\d\d-\d\d;search=;mode=;offset=5"][text()="More..."]');

# check that the link for more actually works

$page = get_page("action=more num=5 offset=5 ");

test_page_negative($page, '2011-12-17', '2011-12-16', '2011-12-15',
	  '2011-12-14', '2011-12-13');
test_page($page, '2011-12-12', '2011-12-11', '2011-12-10',
	  '2011-12-09', '2011-12-08');
xpath_test_negative($page, '//a[text()="More..."]');

# check that the link for more appears correctly

$page = get_page("action=more num=5 offset=4 ");

test_page_negative($page, '2011-12-17', '2011-12-16', '2011-12-15',
	  '2011-12-14', '2011-12-08');
test_page($page, '2011-12-13', '2011-12-12', '2011-12-11',
	  '2011-12-10', '2011-12-09');
xpath_test($page, '//a[text()="More..."]');

# one las check

xpath_test_negative(get_page("action=more num=5 offset=6 "),
		    '//a[text()="More..."]');
