# Copyright (C) 2006, 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 12;

clear_pages();

test_page(update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA"), 'This page is empty');

AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");

test_page(update_page('Logo', "#FILE image/foo\niVBORw0KGgoAAAA"), 'This page is empty');

$page = update_page('alex pic', "#FILE image/png\niVBORw0KGgoAAAA");
test_page($page, 'This page contains an uploaded file:');
xpath_test($page, '//img[@class="upload"][@src="http://localhost/wiki.pl/download/alex_pic"][@alt="alex pic"]');
test_page_negative($page, 'AAAA');
test_page_negative(get_page('search=AAA raw=1'), 'alex_pic');
test_page(get_page('search=alex raw=1'), 'alex_pic', 'image/png');
test_page(get_page('search=png raw=1'), 'alex_pic', 'image/png');

test_page(update_page('MimeTest', "#FILE foo/bar\niVBORw0KGgoAAAA"), 'This page is empty');
test_page($redirect, '<h1>Files of type foo/bar are not allowed.</h1>');
