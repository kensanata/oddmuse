# Copyright (C) 2006, 2007, 2008, 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 63;
clear_pages();

add_module('namespaces.pl');

test_page_negative(get_page('/Test?username=alex'), 'Wiki Test: Test');

# editing pages
test_page(get_page('Test'),
	  '<title>Wiki: Test</title>',
	  'Status: 404 NOT FOUND');
test_page(update_page('Test', 'Muuu!', 'main ns', undef, undef,
		      'username=Alex'),
	  '<p>Muuu!</p>');
test_page(get_page('action=browse id=Test ns=Muu'),
	  '<title>Wiki Muu: Test</title>',
	  'Status: 404 NOT FOUND');
test_page(update_page('Test', 'Mooo!', 'muu ns', undef, undef,
		      'ns=Muu', 'username=Berta'),
	  '<title>Wiki Muu: Test</title>',
	  '<p>Mooo!</p>');
test_page(get_page('action=browse id=Test ns=Muu'),
	  '<title>Wiki Muu: Test</title>',
	  '<p>Mooo!</p>');

# search
$page = get_page('/Muu?search=Mooo raw=1');
test_page($page, 'description: Mooo!');
test_page_negative($page, 'description: Muuu!');

$page = get_page('search=Muuu raw=1');
test_page_negative($page, 'description: Mooo!');
test_page($page, 'description: Muuu!');

# recent changes
test_page(get_page('action=rc raw=1'),
	  'generator: Alex',
	  'generator: Muu:Berta');
xpath_test(get_page('action=rc'),
	  '//a[@class="author"][text()="Alex"][@href="http://localhost/wiki.pl/Alex"]',
	  '//a[@class="author"][text()="Muu:Berta"][@href="http://localhost/wiki.pl/Muu/Berta"]');

# redirect from Main:Mu to Muu:Mu
update_page('Mu', '#REDIRECT Muu:Mu');
test_page(get_page('action=browse id=Mu'),
	  'Status: 302',
	  'Location: http://localhost/wiki.pl\?action=browse;ns=Muu;oldid=Main:Mu;id=Mu');
# check the edit link
xpath_test(get_page('action=browse id=Mu ns=Muu oldid=Main:Mu'),
	  '//div[@class="message"]/p[contains(text(),"redirected from")]/a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=Mu"][text()="Main:Mu"]');
# redirect from Muu:Mu
update_page('Mu', '#REDIRECT Ford:Goo', undef, undef, undef, 'ns=Muu');
test_page(get_page('action=browse id=Mu ns=Muu'),
	  'Status: 302',
	   'Location: http://localhost/wiki.pl\?action=browse;ns=Ford;oldid=Muu:Mu;id=Goo');
# check the edit link
xpath_test(get_page('action=browse id=Goo ns=Ford oldid=Muu:Mu'),
	  '//div[@class="message"]/p[contains(text(),"redirected from")]/a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl/Muu?action=edit;id=Mu"][text()="Muu:Mu"]');
# check Main:Mu and verify that only a single redirection hop is allowed
xpath_test(get_page('action=browse id=Mu ns=Muu oldid=Main:Mu'),
	   '//div/p[contains(text(),"#REDIRECT")]/a[@href="http://localhost/wiki.pl/Ford/Goo"][@class="inter Ford"]/span[@class="site"][text()="Ford"]/following-sibling::span[@class="page"][text()="Goo"]');
# redirecting back to the Main namespace is different, so test separately
test_page(update_page('BackHome', '#REDIRECT Main:HomePage', undef, undef, undef, 'ns=Muu'),
	  'Status: 302',
	  'Location: http://localhost/wiki.pl\?action=browse;ns=Main;oldid=Muu:BackHome;id=HomePage');
# check the edit link
xpath_test(get_page('action=browse id=HomePage ns=Main oldid=Muu:BackHome'),
	  '//div[@class="message"]/p[contains(text(),"redirected from")]/a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl/Muu?action=edit;id=BackHome"][text()="Muu:BackHome"]');
# continue with regular tests
test_page(get_page('action=browse id=Test ns=Main'),
	  '<title>Wiki: Test</title>',
	  '<p>Muuu!</p>');
test_page(get_page('action=rc raw=1'),
	  'description: main ns',
	  'description: muu ns');
test_page_negative(get_page('action=rc raw=1 local=1'),
	  'description: muu ns');
test_page(get_page('action=rc raw=1 ns=Muu'),
	  'description: muu ns');
test_page_negative(get_page('action=rc raw=1 ns=Muu'),
	  'description: main ns');
# add two more edits so that RC will show diff links
update_page('Test', 'Another Muuu!', 'main ns');
update_page('Test', 'Another Mooo!', 'muu ns', undef, undef, 'ns=Muu');
xpath_test(get_page('action=rc'),
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Test"][text()="Test"]',
	   '//a[@class="history"][@href="http://localhost/wiki.pl?action=history;id=Test"][text()="history"]',
	   '//a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=1;id=Test"][text()="diff"]',
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Muu/Test"][text()="Muu:Test"]',
	   '//a[@class="history"][@href="http://localhost/wiki.pl/Muu?action=history;id=Test"][text()="history"]',
	   '//a[@class="diff"][@href="http://localhost/wiki.pl/Muu?action=browse;diff=1;id=Test"][text()="diff"]',
	  );
test_page(get_page('action=rss'),
	  '<title>Muu:Mu</title>',
	  '<link>http://localhost/wiki.pl/Muu/Mu</link>',
	  '<wiki:history>http://localhost/wiki.pl/Muu\?action=history;id=Mu</wiki:history>',
	  '<wiki:diff>http://localhost/wiki.pl/Muu\?action=browse;diff=1;id=Mu</wiki:diff>');
# Test non-ASCII characters in namespaces
test_page(update_page('Umlaute', 'namespace mit umlaut',
		      'wo steckt das ü', undef, undef,
		      'ns=Zürich'), 'namespace mit umlaut');
xpath_test(get_page('action=rc'),
	   # the exact result depends on filesystem encoding!
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Zu%cc%88rich/Umlaute"'
	   . ' or @href="http://localhost/wiki.pl/Zu%fcrich/Umlaute"'
	   . ' or @href="http://localhost/wiki.pl/Z%c3%bcrich/Umlaute"]');

# Test rollbacks
test_page(get_page('action=browse ns=Muu id=Test'),
	  'Another Mooo!');
# find first (and only rollback link) for Muu/Test
$to = xpath_test(get_page('action=history id=Test ns=Muu username=Alex'),
		 '//input[@value="rollback"]/attribute::name');
$to =~ /rollback-([0-9]+)/;
$to = $1;
ok($to > 0, 'found rollback link for Muu/Test');
# do the rollback
test_page(get_page("action=rollback ns=Muu id=Test to=$to username=Alex"),
	  'Rolling back changes', 'Test</a> rolled back');
$page = get_page('action=browse ns=Muu id=Test');
test_page_negative($page, 'Another Mooo!');
test_page($page, 'Mooo!');
# verify that local RecentChanges doesn't show anything
test_page_negative(get_page('action=rc ns=Muu raw=1'), 'Rollback');
# verify that global RecentChanges doesn't show anything
test_page_negative(get_page('action=rc raw=1'), 'Rollback');

# test oldrc.log reading
ok(rename("$DataDir/Muu/rc.log", "$DataDir/Muu/oldrc.log"),
   "renamed $RcFile to $RcOldFile in the Muu namespace");
test_page(get_page('action=rc ns=Muu raw=1'), 'title: Wiki Muu',
	  'title: BackHome', 'title: Test');
test_page(get_page('action=rc raw=1'), 'title: Wiki',
	  'title: Muu:BackHome', 'title: Muu:Test');
