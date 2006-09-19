require 't/test.pl';
package OddMuse;
use Test::More tests => 5;
clear_pages();

AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

get_page('title=Yadda', 'aftertext=This%20is%20my%20comment.', 'username=Alex');
test_page(get_page('Yadda'), 'Describe the new page');

get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20my%20comment.', 'username=Alex');
test_page(get_page('Comments_on_Yadda'), 'This is my comment\.', '-- Alex');

get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20another%20comment.',
	 'username=Alex', 'homepage=http%3a%2f%2fwww%2eoddmuse%2eorg%2f');
xpath_test(get_page('Comments_on_Yadda'),
	   '//p[contains(text(),"This is my comment.")]',
	   '//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="Alex"]');
