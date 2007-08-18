# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 6;
clear_pages();

add_module('searchtags.pl');

$page = update_page('One', "This is the text\n\nTags: Two Words, Foo");
xpath_test($page,
	   '//div[@class="taglist"]/a[text()="Foo"]',
	   '//div[@class="taglist"]/a[text()="Two Words"]');
$result = xpath_test($page, '//div[@class="taglist"]/a[text()="Two Words"]/@href');
$result =~ m/(search=.*)/;
$action = $1;

test_page(get_page("'$action' raw=1 context=0"), "\nOne\n");

# Make sure subsets such as "Words" vs. "Two Words" are not found.

$page = update_page('Two', "This is the text\n\nTags: Words");
$result = xpath_test($page, '//div[@class="taglist"]/a[text()="Words"]/@href');
$result =~ m/(search=.*)/;
$action = $1;

test_page(get_page("'$action' raw=1 context=0"), "\nTwo");
