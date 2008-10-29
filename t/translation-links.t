# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 22;
clear_pages();

add_module('translation-links.pl');

AppendStringToFile($ConfigFile, q{
%Languages = ('de' => '\b(der|die|das|und|oder)\b',
              'en' => '\b(the|he|she|that|this)\b');
$Translate{de} = 'Deutsch';
$Translate{en} = 'English';
});

$page = update_page('HomePage', 'This is the homepage. [[de:HauptSeite]] [[fr:PagePrincipale]]');
# the page is not autoidentified as English, therefore English must be missing!
test_page($page, 'This is the homepage.', 'fr:PagePrincipale',
	  'action=translate;id=HomePage;missing=en', 'Add Translation');
test_page_negative($page, 'de:HauptSeite');
xpath_test($page, '//div[@class="footer"]/span[@class="translation bar"]/a[@class="translation de"][@href="http://localhost/wiki.pl/HauptSeite"][text()="Deutsch"]');

AppendStringToFile($ConfigFile, q{
%Languages = ('de' => '\b(der|die|das|und|oder)\b',
              'fr' => '\b(le|la|un|une|de|en)\b',
              'en' => '\b(the|he|she|that|this)\b');
$Translate{de} = 'Deutsch';
$Translate{fr} = 'Français';
$Translate{en} = 'English';
});

xpath_test(update_page('HomePage', 'Simple test. [[de:HauptSeite]]'),
	   '//div[@class="footer"]/span[@class="translation bar"]/a[@class="translation new"][text()="Add Translation"][@href="http://localhost/wiki.pl?action=translate;id=HomePage;missing=en_fr"]');

$page = get_page('action=translate id=HomePage missing=en_fr');
test_page($page, 'Français', 'English', 'a translation of HomePage',
	  'the translation of HomePage');
test_page_negative($page, 'Deutsch');

# the page is now autoidentified as English, therefore French is the only one that is missing!
xpath_test(update_page('HomePage', 'The the the the test. [[de:HauptSeite]]'),
	   '//div[@class="footer"]/span[@class="translation bar"]/a[@class="translation new"][text()="Add Translation"][@href="http://localhost/wiki.pl?action=translate;id=HomePage;missing=fr"]');

test_page(get_page('action=translate id=HomePage target=PagePrincipale translation=fr'),
	  'Editing PagePrincipale');

test_page(get_page('action=browse raw=1 id=HomePage'),
	  '\[\[de:HauptSeite\]\]', '\[\[fr:PagePrincipale\]\]');

test_page_negative(get_page('HomePage'), 'Translate');

test_page(get_page('action=translate id=HomePage target= translation=fr'),
	  'Translate HomePage', 'Page name is missing');

test_page(get_page('action=translate id=HomePage target=a:b translation=fr'),
	  'Invalid Page a:b');

test_page(get_page('action=translate id=HomePage target=abc'),
	  'Language is missing');

test_page(get_page('action=translate id=HomePage target=abc translation=fr'),
	  'Editing abc');
