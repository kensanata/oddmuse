# Copyright (C) 2008, 2009  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 3;
clear_pages();

add_module('google-custom-search.pl');

$page = update_page('the page');
xpath_test($page,
	   '//h1/a[text()="the page"][@rel="nofollow"][contains(@href,"q=%22the%20page%22")][@title="Click to search for references to this page"]');
negative_xpath_test($page, '//h1/a[contains(@href,"localhost")]');

add_module('permanent-anchors.pl');

xpath_test(update_page('the page', '[::foo bar]'),
	   '//a[text()="foo bar"][@class="definition"][@name="foo_bar"][@rel="nofollow"][contains(@href,"q=%22foo%20bar%22")][@title="Click to search for references to this permanent anchor"]');
