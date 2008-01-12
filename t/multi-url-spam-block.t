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
use Test::More tests => 10;

clear_pages();

AppendStringToFile($ConfigFile, "\$BannedContent = 'MyBannedContent';\n");
AppendStringToFile($ConfigFile, "\$MultiUrlWhiteList = 'MyWhitelist';\n");

add_module('multi-url-spam-block.pl');

$text = "http://some.example.com\n" x 10;

update_page('spam', $text);
test_page($redirect, 'Status: 302');

# another external link but a different domain
update_page('spam', $text . "http://some.example.org\n");
test_page($redirect, 'Status: 302');

# another external link but the same domain
update_page('spam', $text . "http://other.example.com\n");
test_page($redirect, 'Status: 403',
	  'linked more than 10 times to the same domain');

# Test interaction with localnames.pl
update_page('LocalNames', $text . "http://other.example.com\n");
test_page($redirect, 'Status: 403',
	  'linked more than 10 times to the same domain');
add_module('localnames.pl');
update_page('LocalNames', $text . "http://other.example.com\n");
test_page($redirect, 'Status: 302');

# Make sure that the symbol table fiddling has not confused the admin
# page
test_page(get_page('action=admin'), 'MyBannedContent', 'MyWhitelist');

# Test whitelist
update_page('MyWhitelist', 'example.com # test');

update_page('spam', $text . "http://other.example.com\n");
test_page($redirect, 'Status: 302');
