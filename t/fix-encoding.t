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
use Test::More tests => 5;
use utf8; # tests contain UTF-8 characters and it matters

clear_pages();
add_module('fix-encoding.pl');

test_page_negative(get_page('action=admin'), 'action=fix-encoding');
test_page(get_page('action=admin id=foo'), 'action=fix-encoding;id=foo');

test_page(update_page('Example', 'PilgerstÃ¤tte fÃ¼r die GÃ¶ttin'),
	  'PilgerstÃ¤tte fÃ¼r die GÃ¶ttin');

test_page(get_page('action=fix-encoding id=Example'),
	  'Location: http://localhost/wiki.pl/Example');

test_page(get_page('Example'),
	  'Pilgerstätte für die Göttin');
