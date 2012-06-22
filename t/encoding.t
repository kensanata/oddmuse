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
use Test::More tests => 35;
use utf8; # tests contain UTF-8 characters and it matters

clear_pages();

# ASCII basics

$page = update_page('Aal', 'aal');
test_page($page, '<h1><a .*>Aal</a></h1>', '<p>aal</p>');
xpath_test($page, '//h1/a[text()="Aal"]', '//p[text()="aal"]');

$page = get_page('Aal');
test_page($page, '<h1><a .*>Aal</a></h1>', '<p>aal</p>');
xpath_test($page, '//h1/a[text()="Aal"]', '//p[text()="aal"]');

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

# rc

test_page(get_page('action=rc raw=1'),
	  'title: Öl', 'description: öl');

# diff

update_page('Öl', 'Ähren');
xpath_test(get_page('action=browse id=Öl diff=1'),
	   '//div[@class="old"]/p/strong[@class="changes"][text()="öl"]',
	   '//div[@class="new"]/p/strong[@class="changes"][text()="Ähren"]');

# search

# testing with non-ASCII is important on a Mac

# ASCII
$page = get_page('search=aal raw=1');
test_page($page, 'title: Search for: aal', 'title: Aal');

# matching page name does not involve grep working
$page = get_page('search=öl raw=1');
test_page($page, 'title: Search for: öl', 'title: Öl');

# this fails with grep on a Mac, thus testing if mac.pl
# managed to switch of the use of grep
test_page(get_page('search=ähren raw=1'),
	  'title: Search for: ähren', 'title: Öl');

# the username keeps getting reported as changed
test_page(get_page('action=browse id=Möglich username=Schr%C3%B6der'),
	  'Set-Cookie: Wiki=username%251eSchr%C3%B6der',
	  'username=Schröder');

# verify that non-ASCII parameters work as intended
AppendStringToFile($ConfigFile, "use utf8;\n\$CookieParameters{ärger} = 1;\n");
test_page(get_page('action=browse id=Test %C3%A4rger=hallo'),
	  'Set-Cookie: Wiki=%C3%A4rger%251ehallo');

# this causes wide character in print somehow? otherwise harmless
test_page(update_page("Russian", "Русский Hello"),
	  "Русский");

# with toc.pl, however, a problem: Русский is corrupted
add_module('toc.pl');
test_page(update_page("Russian", "Русский Hello again"),
	  "Русский");
