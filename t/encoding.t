# Copyright (C) 2012  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 32;
use utf8; # tests contain UTF-8 characters and it matters

clear_pages();

# ASCII basics

$page = update_page('Aal', 'aal');
test_page($page, '<h1><a .*>Aal</a></h1>', '<p>aal</p>');
xpath_test($page, '//h1/a[text()="Aal"]', '//p[text()="aal"]');

$page = get_page('Aal');
test_page($page, '<h1><a .*>Aal</a></h1>', '<p>aal</p>');
xpath_test($page, '//h1/a[text()="Aal"]', '//p[text()="aal"]');

$page = get_page('search=aal raw=1');
test_page($page, 'title: Search for: aal', 'title: Aal');

# non-ASCII

$page = update_page('Öl', 'öl');
test_page($page, '<h1><a .*>Öl</a></h1>', '<p>öl</p>');
xpath_test($page, '//h1/a[text()="Öl"]', '//p[text()="öl"]');

$page = get_page('Öl');
test_page($page, '<h1><a .*>Öl</a></h1>', '<p>öl</p>');
xpath_test($page, '//h1/a[text()="Öl"]', '//p[text()="öl"]');

$page = get_page('action=index raw=1');
test_page($page, 'Aal', 'Öl');

test_page(get_page('Aal'), 'aal');
test_page(get_page('Öl'), 'öl');

$page = get_page('search=öl raw=1');
test_page($page, 'title: Search for: öl', 'title: Öl');

# rc

test_page(get_page('action=rc raw=1'),
	  'title: Öl', 'description: öl');

# diff

update_page('Öl', 'Ähren');
xpath_test(get_page('action=browse id=Öl diff=1'),
	   '//div[@class="old"]/p/strong[@class="changes"][text()="öl"]',
	   '//div[@class="new"]/p/strong[@class="changes"][text()="Ähren"]');

# search body without using grep

test_page(get_page('search=ähren raw=1 grep=0'),
	  'title: Search for: ähren', 'title: Öl');

# search body with grep

test_page(get_page('search=ähren raw=1'),
	  'title: Search for: ähren', 'title: Öl');
