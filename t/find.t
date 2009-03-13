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
use Test::More tests => 18;

clear_pages();

add_module('find.pl');

update_page('Alex', 'He is a man.');
update_page('Berta', 'She is a woman.');

$page = get_page('action=find');
test_page($page, 'Alex', 'Berta');
test_page_negative($page, '\bman\.');

$page = get_page('action=find query=alex');
test_page($page, 'Alex', 'man');
test_page_negative($page, 'Berta', 'woman');

$page = get_page('action=find query=berta');
test_page($page, 'Berta', 'woman');
test_page_negative($page, 'Alex', '\bman');

$page = get_page('action=find query=man');
test_page($page,
	  'Alex', 'is a <strong>man</strong>',
	  'Berta', 'is a wo<strong>man</strong>');

$page = get_page('action=find query=man context=0');
test_page($page, 'Alex', 'Berta');
test_page_negative($page, 'woman');
