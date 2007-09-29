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
use Test::More tests => 3;
clear_pages();

xpath_test(get_page('Thelonius_M%c3%b6nk'),
	   Encode::encode_utf8('//a[@class="admin"][@href="http://localhost/wiki.pl?action=admin;id=Thelonius_M%c3%b6nk"][text()="Administration"]'),
	   Encode::encode_utf8('//a[@class="edit"][@accesskey="e"][@href="http://localhost/wiki.pl?action=edit;id=Thelonius_M%c3%b6nk"][@title="Click to edit this page"][text()="Edit this page"]'),
	   Encode::encode_utf8('//a[@href="http://localhost/wiki.pl?action=history;id=Thelonius_M%c3%b6nk"][@class="history"][text()="View other revisions"]'));
