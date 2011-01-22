# Copyright (C) 2010  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
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

clear_pages();

xpath_test(update_page('Start', '[[Hello?]]'),
	   '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=Hello%3f"][text()="?"]');
xpath_test(update_page('Hello?', 'Test'),
	   '//h1/a[text()="Hello?"]',
	   '//div[@class="content browse"]/p[text()="Test"]');
xpath_test(get_page('Start'),
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Hello%3f"][text()="Hello?"]');
xpath_test(update_page('Start', '[[image:Hello?]]'),
	   '//img[@class="upload"][@alt="Hello?"][@src="http://localhost/wiki.pl/download/Hello%3f"]');
