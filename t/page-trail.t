# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 9;
clear_pages();

add_module('page-trail.pl');

my $page = get_page('FirstPage');

xpath_test($page,
	   '//div[@class="header"]/span[@class="gotobar bar"]/following-sibling::span[@class="trail"]',
	  '//span[@class="trail"][contains(text(),"Trail: ")]/br',
	  '//span[@class="trail"]/a[@class="local"][@href="http://localhost/wiki.pl/FirstPage"][text()="FirstPage"]');

# verify cookie
test_page($page, 'Set-Cookie: Wiki=trail%251eFirstPage');

# fake cookie and grow trail
$page = get_page('action=browse id=SecondPage trail=FirstPage');
# verify HTML
xpath_test($page, '//span[@class="trail"]/a[text()="FirstPage"]/following-sibling::a[text()="SecondPage"]');
# verify cookie
test_page($page, 'Set-Cookie: Wiki=trail%251eSecondPage%20FirstPage');

# fake cookie and grow trail (unit separator US is x1f)
$page = get_page('action=browse id=ThirdPage trail=SecondPage%20FirstPage');
# verify HTML
xpath_test($page, '//span[@class="trail"]/a[text()="FirstPage"]/following-sibling::a[text()="SecondPage"]/following-sibling::a[text()="ThirdPage"]');

# verify cookie
test_page($page, 'Set-Cookie: Wiki=trail%251eThirdPage%20SecondPage%20FirstPage');

AppendStringToFile($ConfigFile, "\$PageTrailLength = 3;\n");

# verify truncation of the trail
$page = get_page('action=browse id=FourthPage trail=ThirdPage%20SecondPage%20FirstPage');

xpath_test($page, '//span[@class="trail"]/a[position()=1][text()="SecondPage"]/following-sibling::a[text()="ThirdPage"]/following-sibling::a[text()="FourthPage"]');
