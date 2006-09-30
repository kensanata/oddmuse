# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

require 't/test.pl';
package OddMuse;
use Test::More tests => 26;
clear_pages();

AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

# $EditAllowed

xpath_test(get_page('Test'),
	   '//a[@class="comment local"][@href="http://localhost/wiki.pl/Comments_on_Test"][text()="Comments on Test"]',
	   '//a[@class="edit"][@href="http://localhost/wiki.pl?action=edit;id=Test"][text()="Edit this page"]');
xpath_test(get_page('Comments_on_Test'),
	   '//a[@class="original local"][@href="http://localhost/wiki.pl/Test"][text()="Test"]',
	   '//a[@class="edit"][@href="http://localhost/wiki.pl?action=edit;id=Comments_on_Test"][text()="Edit this page"]',
	   '//textarea[@name="aftertext"]');

AppendStringToFile($ConfigFile, "\$EditAllowed = 0;\n");

xpath_test(get_page('Test'),
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
$page = get_page('Comments_on_Test');
xpath_test($page,
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
negative_xpath_test($page, '//textarea[@name="aftertext"]');

AppendStringToFile($ConfigFile, "\$EditAllowed = 2;\n");

xpath_test(get_page('Test'),
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
xpath_test(get_page('Comments_on_Test'),
	   '//a[@class="original local"][@href="http://localhost/wiki.pl/Test"][text()="Test"]',
	   '//a[@class="edit"][@href="http://localhost/wiki.pl?action=edit;id=Comments_on_Test"][text()="Edit this page"]',
	   '//textarea[@name="aftertext"]');

AppendStringToFile($ConfigFile, "\$EditAllowed = 3;\n");

xpath_test(get_page('Test'),
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
xpath_test(get_page('Comments_on_Test'),
	   '//a[@class="original local"][@href="http://localhost/wiki.pl/Test"][text()="Test"]',
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]',
	   '//textarea[@name="aftertext"]');

# Other tests

AppendStringToFile($ConfigFile, "\$EditAllowed = 1;\n");

get_page('title=Yadda', 'aftertext=This%20is%20my%20comment.', 'username=Alex');
test_page(get_page('Yadda'), 'Describe the new page');

get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20my%20comment.', 'username=Alex');
test_page(get_page('Comments_on_Yadda'), 'This is my comment\.', '-- Alex');
test_page(get_page('action=rc raw=1'), 'title: Comments on Yadda',
	  'description: This is my comment.', 'generator: Alex');

get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20another%20comment.',
	 'username=Alex', 'homepage=http%3a%2f%2fwww%2eoddmuse%2eorg%2f');
xpath_test(get_page('Comments_on_Yadda'),
	   '//p[contains(text(),"This is my comment.")]',
	   '//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="Alex"]');

my $textarea = '//textarea[@name="aftertext"][@id="aftertext"]';
xpath_test(get_page('Comments_on_Yadda'), $textarea);
get_page('action=pagelock set=1 id=Comments_on_Yadda pwd=foo');
negative_xpath_test(get_page('Comments_on_Yadda'), $textarea);
