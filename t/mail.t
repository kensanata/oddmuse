# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 45;

clear_pages();

AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

add_module('mail.pl');

# edit page
$page = get_page('Comments_on_Foo');
xpath_test($page,
	   '//label[@for="mail"][contains(text(), "Email")]',
	   '//input[@name="mail"]',
	   '//input[@type="checkbox"][@name="notify"][@value="1"]');
# verify that the email address was stored in the cookie
test_page(get_page('title=Comments_on_Foo aftertext=test username=Alex '
		 . 'mail=alex@example.com notify=1'),
	  'Set-Cookie:.*mail%251ealex%40example.com');
# subscribe to a page (second comment page)
get_page('title=Comments_on_Bar aftertext=test username=Alex '
	 . 'mail=alex@example.com notify=1');
# subscribe to a page (does not work for non-comment pages)
get_page('title=Quux text=test username=Alex '
	 . 'mail=alex@example.com notify=1');
# subscribe to a page (does not work for non-existing pages)
get_page('action=browse id=Comment_on_Baz username=Alex '
	 . 'mail=alex@example.com notify=1');
# check for link in admin page with and without admin permission
$page = get_page('action=admin');
xpath_test($page, '//a[@class="subscriptions"][@href="http://localhost/wiki.pl?action=subscriptions"][text()="Your mail subscriptions"]');
test_page_negative($page, 'All mail subscriptions');
$page = get_page('action=admin pwd=foo');
test_page($page, 'Your mail subscriptions');
xpath_test($page, '//a[@class="subscriptionlist"][@href="http://localhost/wiki.pl?action=subscriptionlist"][text()="All mail subscriptions"]');
# check the list of subscriptions without email
xpath_test(get_page('action=subscriptions'),
	   '//label[@for="mail"][text()="Email: "]',
	   '//input[@type="text"][@name="mail"]');
# check the list of subscriptions with email
$page = get_page('action=subscriptions mail=alex@example.com');
negative_xpath_test($page,
		    '//label[@for="mail"]',
		    '//input[@name="mail"]');
test_page($page,
	  'Subscriptions for alex@example.com',
	  'Comments on Foo', 'Comments on Bar');
test_page_negative($page, 'Comment on Baz', 'Quux');
xpath_test($page,
	   '//p/input[@type="checkbox"][@name="pages"][@value="Comments_on_Foo"]',
	   '//p/input[@type="checkbox"][@name="pages"][@value="Comments_on_Bar"]');
# check the debugging option
test_page(get_page('action=subscriptionlist pwd=foo raw=1'),
	  'Comments_on_Foo alex@example.com',
	  'Comments_on_Bar alex@example.com',
	  'alex@example.com Comments_on_Bar Comments_on_Foo');
# verify mass unsubscribe link
$page = get_page('action=unsubscribe mail=alex@example.com pages=Comments_on_Foo pages=Comments_on_Bar');
test_page($page,
	  '<h1>Subscriptions</h1>',
	  'Unsubscribed alex@example.com from the following');
xpath_test($page,
	   '//li/a[@class="local"][@href="http://localhost/wiki.pl/Comments_on_Foo"][text()="Comments on Foo"]',
	   '//li/a[@class="local"][@href="http://localhost/wiki.pl/Comments_on_Bar"][text()="Comments on Bar"]');
# check that it worked
test_page_negative(get_page('action=subscriptionlist pwd=foo'),
		   'Comments_on_Foo',
		   'Comments_on_Bar',
		   'alex@example.com');
# test for subscribe checkbox on comment page
$page = get_page('action=browse id=Comments_on_Foo mail=alex@example.com');
xpath_test($page,
	   '//label[@for="mail"][contains(text(), "Email")]',
	   '//input[@name="mail"][@value="alex@example.com"]',
	   '//input[@type="checkbox"][@name="notify"][@value="1"]',
	   '//a[@class="subscribe"][@href="http://localhost/wiki.pl?action=subscribe;pages=Comments_on_Foo"][text()="subscribe"]');
# test subscribe action
$page = get_page('action=subscribe mail=alex@example.com pages=Comments_on_Foo pages=Comments_on_Bar pages=Fail');
test_page($page,
	  'Subscribed alex@example.com to the following pages',
	  'The remaining pages do not exist');
xpath_test($page,
	   '//li/a[@class="local"][@href="http://localhost/wiki.pl/Comments_on_Foo"][text()="Comments on Foo"]',
	   '//li/a[@class="local"][@href="http://localhost/wiki.pl/Comments_on_Bar"][text()="Comments on Bar"]');
# test for unsubscribe link on comment page
$page = get_page('action=browse id=Comments_on_Foo mail=alex@example.com');
xpath_test($page,
	   '//label[@for="mail"][contains(text(), "Email")]',
	   '//input[@name="mail"][@value="alex@example.com"]',
	   '//a[@class="unsubscribe"][@href="http://localhost/wiki.pl?action=unsubscribe;pages=Comments_on_Foo"][text()="unsubscribe"]');
negative_xpath_test($page, '//input[@type="checkbox"][@name="notify"]');

# interaction with local names
add_module('localnames.pl');
AppendStringToFile($ConfigFile, "\$LocalNamesCollect = 1;\n");

# Fake a comment on an ordinary page without actually setting the
# $CommentsPrefix such that a local name is also defined.
get_page('title=MyPage aftertext="This is an [http://www.example.com/ Example]."'
	 . ' mail=alex@example.com notify=1');
xpath_test(get_page('MyPage'),
	   '//a[@class="url http outside"][@href="http://www.example.com/"][text()="Example"]');
xpath_test(get_page('LocalNames'),
	   '//ul/li/a[@class="url http outside"][@href="http://www.example.com/"][text()="Example"]');
$page = get_page('action=subscriptions mail=alex@example.com');
test_page($page, 'MyPage');
test_page_negative($page, 'LocalNames');
