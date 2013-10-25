# Copyright (C) 2012–2013  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 20;
use utf8; # tests contain UTF-8 characters and it matters

clear_pages();
add_module('fix-encoding.pl');

# make sure no menu shows if no page is provided

test_page_negative(get_page('action=admin'), 'action=fix-encoding');

# make sure no menu shows up if the page does not exists

test_page(get_page('action=admin id=foo'),
	  'action=fix-encoding;id=foo',
	  'action=fix-escaping;id=foo');

# make sure nothing is saved if the page does not exist

test_page(get_page('action=fix-encoding id=Example'),
	  'Location: http://localhost/wiki.pl/Example');

test_page(get_page('action=fix-escaping id=Example'),
	  'Location: http://localhost/wiki.pl/Example');

test_page_negative(get_page('action=rc all=1 showedit=1'), 'fix');

# make sure nothing is saved if there is no change

test_page(update_page('Example', 'Pilgerstätte für die Göttin'),
	  'Pilgerstätte für die Göttin');

test_page(get_page('action=fix-encoding id=Example'),
	  'Location: http://localhost/wiki.pl/Example');

test_page(get_page('action=fix-escaping id=Example'),
	  'Location: http://localhost/wiki.pl/Example');

test_page_negative(get_page('action=rc all=1 showedit=1'),
		   'Fix Character encoding');

# the menu shows up if the page exists

test_page(get_page('action=admin id=Example'),
	  'action=fix-encoding;id=Example',
	  'action=fix-escaping;id=Example');

# here is an actual page with a character encoding error you need to fix

test_page(update_page('Example', 'PilgerstÃ¤tte fÃ¼r die GÃ¶ttin',
		      'borked encoding'),
	  'PilgerstÃ¤tte fÃ¼r die GÃ¶ttin');

test_page(get_page('action=fix-encoding id=Example'),
	  'Location: http://localhost/wiki.pl/Example');

test_page(get_page('Example'),
	  'Pilgerstätte für die Göttin');

test_page(get_page('action=rc showedit=1'),
	  'Fix character encoding');

# here is an actual page with an HTML escaping error you need to fix

test_page(update_page('Example', '&amp;lt;b&amp;gt;bold&amp;lt;/b&amp;gt;',
		      'borked escaping'),
	  '&amp;lt;b&amp;gt;bold&amp;lt;/b&amp;gt;');

test_page(get_page('action=fix-escaping id=Example'),
	  'Location: http://localhost/wiki.pl/Example');

test_page(get_page('Example'),
	  '&lt;b&gt;bold&lt;/b&gt;');

test_page(get_page('action=rc showedit=1'),
	  'Fix HTML escapes');
