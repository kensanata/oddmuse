# Copyright (C) 2006–2017  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require './t/test.pl';
package OddMuse;
use Test::More tests => 44;

AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

# $EditAllowed

test_page(get_page('Comments_on_Test'),
          'There are no comments, yet. Be the first to leave a comment!');
$page = update_page('Test', 'Can edit page by default');
test_page($page, 'Can edit page by default');
xpath_test($page,
	   '//a[@class="comment local"][@href="http://localhost/wiki.pl/Comments_on_Test"][text()="Comments on Test"]',
	   '//a[@class="edit"][@href="http://localhost/wiki.pl?action=edit;id=Test"][text()="Edit this page"]');
$page = update_page('Comments_on_Test', 'Can edit comment by default');
test_page($page, 'Can edit comment by default');
xpath_test($page,
	   '//a[@class="original local"][@href="http://localhost/wiki.pl/Test"][text()="Test"]',
	   '//a[@class="edit"][@href="http://localhost/wiki.pl?action=edit;id=Comments_on_Test"][text()="Edit this page"]',
	   '//textarea[@name="aftertext"]');

# There used to be a bug where we returned status 200 for a non-existing comment
# page if the corresponding page existed. The bug meant that we browsed a page
# with no title.
update_page('Yes', 'test');
test_page(get_page('Comments_on_Yes'),
          'There are no comments, yet. Be the first to leave a comment!');

AppendStringToFile($ConfigFile, "\$EditAllowed = 0;\n");

$page = update_page('Test', 'Cannot edit page with edit allowed eq 0');
test_page($page, 'Can edit page by default');
xpath_test($page,
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
$page = update_page('Comments_on_Test', 'Cannot edit comments with edit allowed eq 0');
test_page($page, 'Can edit comment by default');
xpath_test($page,
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
negative_xpath_test($page, '//textarea[@name="aftertext"]');

AppendStringToFile($ConfigFile, "\$EditAllowed = 2;\n");

$page = update_page('Test', 'Cannot edit page with edit allowed eq 2');
test_page($page, 'Can edit page by default');
xpath_test($page,
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
$page = update_page('Comments_on_Test', 'Can edit comments with edit allowed eq 2');
test_page($page, 'Can edit comments with edit allowed eq 2');
xpath_test($page,
	   '//a[@class="original local"][@href="http://localhost/wiki.pl/Test"][text()="Test"]',
	   '//a[@class="edit"][@href="http://localhost/wiki.pl?action=edit;id=Comments_on_Test"][text()="Edit this page"]',
	   '//textarea[@name="aftertext"]');

AppendStringToFile($ConfigFile, "\$EditAllowed = 3;\n");

$page = update_page('Test', 'Cannot edit page with edit allowed = 3');
test_page($page, 'Can edit page by default');
xpath_test($page,
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]');
$page = update_page('Comments_on_Test', 'Can edit comments with edit allowed eq 3');
test_page($page, 'Can edit comments with edit allowed eq 2');
xpath_test($page,
	   '//a[@class="original local"][@href="http://localhost/wiki.pl/Test"][text()="Test"]',
	   '//a[@class="password"][@href="http://localhost/wiki.pl?action=password"][text()="This page is read-only"]',
	   '//textarea[@name="aftertext"]');
$page = update_page('Comments_on_Test', '', '', 1, '', 'aftertext=Cannot%20add%20minor%20comments%20with%20edit%20allowed%20eq%203');
test_page_negative($page, 'Cannot add minor comments with edit allowed eq 3');
$page = update_page('Comments_on_Test', '', '', '', '', 'aftertext=Can%20add%20comments%20with%20edit%20allowed%20eq%203');
test_page($page, 'Can add comments with edit allowed eq 3');

# Other tests

AppendStringToFile($ConfigFile, "\$EditAllowed = 1;\n");

get_page('title=Yadda', 'aftertext=This%20is%20my%20comment%20on%20an%20ordinary%20page.', 'username=Alex');
test_page(get_page('Yadda'), 'This is my comment on an ordinary page\.');

get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20my%20comment%20on%20a%20comment%20page.', 'username=Alex');
test_page(get_page('Comments_on_Yadda'), 'This is my comment on a comment page\.', '-- Alex');
test_page(get_page('action=rc raw=1'), 'title: Comments on Yadda',
	  'description: This is my comment on a comment page\.', 'generator: Alex');

# No wiping with empty comment

get_page('title=Comments_on_Yadda', 'aftertext=', 'username=Berta');
$page = get_page('Comments_on_Yadda');
test_page($page, 'This is my comment on a comment page\.');
test_page_negative('Berta');

# No wiping with a comment that evaluates to false

get_page('title=Comments_on_Yadda', 'aftertext=0', 'username=Berta');
test_page(get_page('Comments_on_Yadda'),
	  'This is my comment on a comment page\.',
	  '<p>0</p>',
	  'Berta');

# homepage
get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20another%20comment.',
	 'username=Alex', 'homepage=http%3a%2f%2fwww%2eoddmuse%2eorg%2f');
xpath_test(get_page('Comments_on_Yadda'),
	   '//p[contains(text(),"This is my comment on a comment page.")]', # not wiped
	   '//p[contains(text(),"This is another comment.")]', # not wiped
	   '//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="Alex"]');

# variant without protocol
get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20yet%20another%20comment.',
	 'username=Berta', 'homepage=alexschroeder%2ech');
xpath_test(get_page('Comments_on_Yadda'),
	   '//a[@class="url http outside"][@href="http://alexschroeder.ch"][text()="Berta"]');

my $textarea = '//textarea[@name="aftertext"][@id="aftertext"]';
xpath_test(get_page('Comments_on_Yadda'), $textarea);
get_page('action=pagelock set=1 id=Comments_on_Yadda pwd=foo');
negative_xpath_test(get_page('Comments_on_Yadda'), $textarea);
