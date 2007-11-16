# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 12;

clear_pages();

add_module('strange-spam.pl');

update_page('StrangeBannedContent', "XXX\n", undef, undef, 1);
test_page(update_page('pr0n', 'some XXX movies'),
	  'This page is empty');
test_page($redirect,
	  'banned text', 'wiki administrator', 'matched',
	  'See .*BannedContent.* for more information',
	  'Reason unknown');
test_page(update_page('pr0n', 'some XXX movies', undef, undef, 1),
	  'some XXX movies');

add_module('despam.pl');

test_page(get_page('action=spam'), 'pr0n');
test_page(get_page('action=despam'), 'pr0n.*Marked as DeletedPage');
test_page_negative(get_page('action=spam'), 'pr0n');

# Make sure that the symbol table fiddling has not confused the admin
# page
xpath_test(get_page('action=admin'), '//li/a[@href="http://localhost/wiki.pl?action=edit;id=BannedContent"]');
AppendStringToFile($ConfigFile, "\$BannedContent = 'MyBannedContent';\n");
xpath_test(get_page('action=admin'), '//li/a[@href="http://localhost/wiki.pl?action=edit;id=MyBannedContent"]');
