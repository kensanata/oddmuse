# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 10;
use utf8; # tests contain UTF-8 characters and it matters

clear_pages();

update_page('HomePage', 'Das ist ein Ei.');
ok(-f GetPageFile('HomePage'), 'page file');

update_page('HomePage', 'This is an egg.');
ok(-f GetKeepFile('HomePage', 1), 'keep file');

update_page('ホームページ', 'これが卵です。');
ok(-f GetPageFile('ホームページ'), 'Japanese page file');

update_page($StyleSheetPage, '/* nothing to see */', '', 0, 1);
ok(-f GetPageFile($StyleSheetPage), 'locked page file');
ok(-f GetLockedPageFile($StyleSheetPage), 'page lock');

add_module('balanced-page-directories.pl');

test_page(get_page('HomePage'), 'This is an egg.');
ok(-f GetKeepFile('HomePage', 1), 'keep file');
test_page(get_page('ホームページ'), 'これが卵です。');
ok(-f GetLockedPageFile($StyleSheetPage), 'page lock');

# create a new page
test_page(update_page('サイトマップ', '日本語ユーザーに向けて'),
	  '日本語ユーザーに向けて');
