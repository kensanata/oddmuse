# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
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

AppendStringToFile($ConfigFile, "push(\@MyMacros, sub{s/foo/bar/g});\n");

# page preview
test_page(get_page('title=Macros', 'text=foo%20is%20metasyntactical',
		   'Preview=1'),
	  'Preview:',
	  'bar is metasyntactical');
# page save
test_page(update_page('Macros', 'foo is metasyntactical'),
	  'bar is metasyntactical');
# comment preview
test_page(get_page('title=Comments_on_Macros', 'aftertext=This%20is%20my%20foo%20comment.',
		   'Preview=1'),
	  'Preview:',
	  'This is my bar comment.',
	  '-- Anonymous');
# comment save
get_page('title=Comments_on_Macros', 'aftertext=This%20is%20my%20foo%20comment.');
my $page = get_page('Comments_on_Macros');
test_page($page, 'This is my bar comment.', '-- Anonymous');
test_page_negative($page, 'Preview:');
