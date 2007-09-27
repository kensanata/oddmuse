# Copyright (C) 2006, 2007  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 13;
clear_pages();

add_module('permanent-anchors.pl');

# define permanent anchor
test_page(update_page('Jack_DeJohnette', 'A friend of [::Gary Peacock]'),
	  'A friend of',
	  'Gary Peacock',
	  'name="Gary_Peacock"',
	  'class="definition"',
	  'title="Click to search for references to this permanent anchor"');
# link to a permanent anchor
test_page(update_page('Keith_Jarret', 'Plays with [[Gary Peacock]]'),
	  'Plays with',
	  'wiki.pl/Jack_DeJohnette#Gary_Peacock',
	  'Keith Jarret',
	  'Gary Peacock');
test_page(get_page('Gary_Peacock'),
	  'Status: 302',
	  'Location: .*wiki.pl/Jack_DeJohnette#Gary_Peacock');
# undefine permanent anchor
test_page(update_page('Jack_DeJohnette', 'A friend of Gary Peacock.'),
	  'A friend of Gary Peacock.');
# verify that the link to it turns into an edit link
test_page(get_page('Keith_Jarret'),
	  'wiki.pl\?action=edit;id=Gary_Peacock');
