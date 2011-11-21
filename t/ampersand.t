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
use Test::More tests => 39;

clear_pages();

xpath_test(update_page('Start', '[[D&D]]'),
	   '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=D%26D"][text()="?"]');
xpath_test(get_page('action=rc'),
	   '//strong[text()="D&D"]');

xpath_test(update_page('D%26D', 'Test', 'Test&Deliver'),
	   '//h1/a[text()="D&D"]',
	   '//div[@class="content browse"]/p[text()="Test"]');
xpath_test(get_page('Start'),
	   '//a[@class="local"][@href="http://localhost/wiki.pl/D%26D"][text()="D&D"]');
xpath_test(get_page('action=rc'),
	   '//strong[text()="Test&Deliver"]');

xpath_test(update_page('Start', '[[image:D&D]]'),
	   '//img[@class="upload"][@alt="D&D"][@src="http://localhost/wiki.pl/download/D%26D"]');

xpath_run_tests(split('\n',<<'EOT'));
[http://example.org/ this & that]
//a[@class="url http outside"][@href="http://example.org/"][text()="this & that"]
EOT

# Seite zum Testen von Kommentaren
test_page(update_page('Änderungen', 'Veränderung'),
	  'Änderungen', 'Veränderung');
# redirect auf die richtige Seite
test_page(get_page('title=Änderungen aftertext=Öffnung'),
	  'Location:', UrlEncode('Änderungen'));
# Test von Original und Kommentar
test_page(get_page('Änderungen'),
	  'Veränderung', 'Öffnung');

add_module('creole.pl');

# same test as before
xpath_test(get_page('Start'),
	   '//img[@class="upload"][@alt="D&D"][@src="http://localhost/wiki.pl/download/D%26D"]');
# revert and run the previous test as well
xpath_test(update_page('Start', '[[D&D]]'),
	   '//a[@class="local"][@href="http://localhost/wiki.pl/D%26D"][text()="D&D"]');

# Journal test
update_page('2011-11-20 No D%26D Today', 'This is the page itself.');
test_page(update_page('Journal', '<journal>'),
	  '2011-11-20 No D&amp;D Today');

# the following was copied from creole.pl

update_page('InterMap', " Ohana http://www.wikiohana.org/\n", 0, 0, 1);
update_page('link_&_link', 'test');
update_page('pic_&_pic', 'test');
ReInit();

xpath_run_tests(split('\n',<<'EOT'));
[[http://www.wikicreole.org/|Visit the **WikiCreole** website]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the "][strong[text()="WikiCreole"]][text()=" website"]
[[http://www.wikicreole.org/|//Visit the\nWikiCreole website//]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][em[text()="Visit the WikiCreole website"]]
[[http://www.wikicreole.org/ | Visit the WikiCreole website]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the WikiCreole website"]
[[link & link]]
//a[text()="link & link"]
[[link & link|Go to my page]]
//a[@class="local"][@href="http://localhost/test.pl/link_%26_link"][text()="Go to my page"]
[[link & link|Go to\nmy page]]
//a[@class="local"][@href="http://localhost/test.pl/link_%26_link"][text()="Go to my page"]
{{pic & pic}}
//a[@class="image"][@href="http://localhost/test.pl/pic_%26_pic"][img[@class="upload"][@src="http://localhost/test.pl/download/pic_%26_pic"][@alt="pic & pic"]]
[[link & link|{{pic & pic}}]]
//a[@class="image"][@href="http://localhost/test.pl/link_%26_link"][img[@class="upload"][@src="http://localhost/test.pl/download/pic_%26_pic"][@alt="link & link"]]
[[link & link|{{http://example.com/q?a=1&b=2}}]]
//a[@class="image"][@href="http://localhost/test.pl/link_%26_link"][img[@class="url outside"][@src="http://example.com/q?a=1&b=2"][@alt="link & link"]]
[[http://example.com/q?a=1&b=2|{{pic & pic}}]]
//a[@class="image outside"][@href="http://example.com/q?a=1&b=2"][img[@class="upload"][@src="http://localhost/test.pl/download/pic_%26_pic"][@alt="http://example.com/q?a=1&b=2"]]
{{http://example.com/q?a=1&b=2}}
//a[@class="image outside"][@href="http://example.com/q?a=1&b=2"][img[@class="url outside"][@src="http://example.com/q?a=1&b=2"]]
[[http://example.com/q?a=1&b=2|{{http://mu.org/q?a=1&b=2}}]]
//a[@class="image outside"][@href="http://example.com/q?a=1&b=2"][img[@class="url outside"][@src="http://mu.org/q?a=1&b=2"]]
{{pic & pic|text & description}}
//a[@class="image"][@href="http://localhost/test.pl/pic_%26_pic"][img[@class="upload"][@src="http://localhost/test.pl/download/pic_%26_pic"][@alt="text & description"]]
[[link & link|{{pic & pic|text & description}}]]
//a[@class="image"][@href="http://localhost/test.pl/link_%26_link"][img[@class="upload"][@src="http://localhost/test.pl/download/pic_%26_pic"][@alt="text & description"]]
[[link & link|{{http://example.com/q?a=1&b=2|text &  description}}]]
//a[@class="image"][@href="http://localhost/test.pl/link_%26_link"][img[@class="url outside"][@src="http://example.com/q?a=1&b=2"][@alt="text &  description"]]
[[http://example.com/q?a=1&b=2|{{pic & pic|text & description}}]]
//a[@class="image outside"][@href="http://example.com/q?a=1&b=2"][img[@class="upload"][@src="http://localhost/test.pl/download/pic_%26_pic"][@alt="text & description"]]
{{http://example.com/q?a=1&b=2|text & description}}
//a[@class="image outside"][@href="http://example.com/q?a=1&b=2"][img[@class="url outside"][@src="http://example.com/q?a=1&b=2"][@alt="text & description"]]
[[http://example.com/q?a=1&b=2|{{http://mu.org/q?a=1&b=2|text & description}}]]
//a[@class="image outside"][@href="http://example.com/q?a=1&b=2"][img[@class="url outside"][@src="http://mu.org/q?a=1&b=2"][@alt="text & description"]]
EOT

$UseQuestionmark = 0;

xpath_run_tests(split('\n',<<'EOT'));
[[miss & miss]]
//a[text()="miss & miss"]
[[[miss & miss]]]
//a[text()="[miss & miss]"]
[[image:miss & miss]]
//a[text()="miss & miss"]
[[image:pic & pic]]
//a[@class="image"][@href="http://localhost/test.pl/pic_%26_pic"][img[@class="upload"][@src="http://localhost/test.pl/download/pic_%26_pic"][@alt="pic & pic"]]
EOT
