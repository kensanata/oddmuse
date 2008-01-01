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
use Test::More tests => 25;
clear_pages();

add_module('permanent-anchors.pl');

# define permanent anchor
test_page(update_page('Jack_DeJohnette', 'A friend of [::Gary Peacock]'),
	  'A friend of',
	  'Gary Peacock',
	  'name="Gary_Peacock"',
	  'class="definition"',
	  'title="Click to search for references to this permanent anchor"');
# get the page again to trigger a dirty/cache error
negative_xpath_test(get_page('Jack_DeJohnette'),
		    '//a[@class="definition"]/following-sibling::a[@class="definition"]');

# link to a permanent anchor
test_page(update_page('Keith_Jarret', 'Plays with [[Gary Peacock]]'),
	  'Plays with',
	  'wiki.pl/Jack_DeJohnette#Gary_Peacock',
	  'Keith Jarret',
	  'Gary Peacock');
# verify that the link target redirects to the permanent anchor
test_page(get_page('Gary_Peacock'),
	  'Status: 302',
	  'Location: .*wiki.pl/Jack_DeJohnette#Gary_Peacock');
# undefine the permanent anchor
test_page(update_page('Jack_DeJohnette', 'A friend of Gary Peacock.'),
	  'A friend of Gary Peacock.');
# verify that the link to it turns into an edit link
test_page(get_page('Keith_Jarret'),
	  'wiki.pl\?action=edit;id=Gary_Peacock');
# repeat with an existing page
test_page(update_page('Thelonius_Mönk', 'first revision', 'start here'),
	  'first revision');
test_page(update_page('Thelonius_Mönk', 'second revision', 'this is next'),
	  'second revision');
# check warning message for existing page
$page = update_page('Keith_Jarret', 'plays unlike [::Thelonius Mönk]');
like($page, qr(the page (.*?) also exists), 'the page ... also exists');
$page =~ qr(the page (.*?) also exists);
$link = $1;
xpath_test($link, Encode::encode_utf8('//a[@class="local"][@href="http://localhost/wiki.pl?action=browse;anchor=0;id=Thelonius_M%c3%b6nk"][text()="Thelonius Mönk"]'));
# verify that the redirection works
test_page(get_page('action=browse id=Thelonius_Mönk'),
	  'Status: 302',
	  'Location: .*wiki.pl/Keith_Jarret#Thelonius_M%c3%b6nk');
# verify that the anchor=0 parameter has the desired effect
test_page(get_page('action=browse anchor=0 id=Thelonius_Mönk'),
	  'second revision');
# verify that the history page uses anchor=0 for its links
xpath_test(get_page('action=history id=Thelonius_Mönk'),
	   '//a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;anchor=0;id=Thelonius_M%c3%b6nk;revision=1"][text()="Revision 1"]',
	   # not sure whether it makes sure to have the class "local" here!
	   '//a[@class="local"][@href="http://localhost/wiki.pl?action=browse;anchor=0;id=Thelonius_M%c3%b6nk"][text()="Revision 2"]');
# verify that the history page of ordinary pages remains unaffected
xpath_test(get_page('action=history id=Jack_DeJohnette'),
	   '//a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=Jack_DeJohnette;revision=1"][text()="Revision 1"]',
	   # not sure whether it makes sure to have the class "local" here!
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Jack_DeJohnette"][text()="Revision 2"]');

# create an anchored object
update_page('TheGame', qq{The game has rules and props. [::TheRules] Simple and elegant. [::TheProps] Expensive and brittle.\n----\nThat's how not to do it!});
update_page('TheTest', qq{The rules are supposed to be\n<include "TheRules">});
