# Copyright (C) 2017  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 19;
use utf8; # tests contain UTF-8 characters and it matters

xpath_test(update_page('Start', '[[Help!]]'),
	   '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=Help!"][text()="?"]');
xpath_test(get_page('action=rc'),
	   '//strong[text()="Help!"]');

xpath_test(update_page('Help!', 'Test', 'Testing is great!'),
	   '//h1/a[text()="Help!"]',
	   '//div[@class="content browse"]/p[text()="Test"]');
xpath_test(get_page('Start'),
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Help!"][text()="Help!"]');
xpath_test(get_page('action=rc'),
	   '//strong[text()="Testing is great!"]');

xpath_test(update_page('Start', '[[image:Help!]]'),
	   '//img[@class="upload"][@alt="Help!"][@src="http://localhost/wiki.pl/download/Help!"]');

xpath_run_tests(split('\n',<<'EOT'));
[http://example.org/ example!]
//a[@class="url http outside"][@href="http://example.org/"][text()="example!"]
EOT

# Test von RSS 3.0
test_page(get_page('action=rc raw=1'), 'title: Help!');

add_module('creole.pl');

# same test as before
xpath_test(get_page('Start'),
	   '//img[@class="upload"][@alt="Help!"][@src="http://localhost/wiki.pl/download/Help!"]');
# revert and run the previous test as well
xpath_test(update_page('Start', '[[Help!]]'),
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Help!"][text()="Help!"]');

# Journal test
update_page('2011-11-20 No Testing Today!', 'This is the page itself.');
test_page(update_page('Journal', '<journal>'),
	  '2011-11-20 No Testing Today!');

# the following was copied from creole.pl

update_page('InterMap', " Ohana http://www.wikiohana.org/\n", 0, 0, 1);
update_page('link!', 'test');
update_page('pic!', 'test');
ReInit();

xpath_run_tests(split('\n',<<'EOT'));
[[link!]]
//a[text()="link!"]
[[link!|Go to my page]]
//a[@class="local"][@href="http://localhost/test.pl/link!"][text()="Go to my page"]
{{pic!}}
//a[@class="image"][@href="http://localhost/test.pl/pic!"][img[@class="upload"][@src="http://localhost/test.pl/download/pic!"][@alt="pic!"]]
[[link!|{{pic!}}]]
//a[@class="image"][@href="http://localhost/test.pl/link!"][img[@class="upload"][@src="http://localhost/test.pl/download/pic!"][@alt="link!"]]
[[link!|{{http://example.com/q?a=1&b=2}}]]
//a[@class="image"][@href="http://localhost/test.pl/link!"][img[@class="url outside"][@src="http://example.com/q?a=1&b=2"][@alt="link!"]]
[[http://example.com/q?a=1&b=2|{{pic!}}]]
//a[@class="image outside"][@href="http://example.com/q?a=1&b=2"][img[@class="upload"][@src="http://localhost/test.pl/download/pic!"][@alt="http://example.com/q?a=1&b=2"]]
[[link!|{{pic!|text!}}]]
//a[@class="image"][@href="http://localhost/test.pl/link!"][img[@class="upload"][@src="http://localhost/test.pl/download/pic!"][@alt="text!"]]
EOT
