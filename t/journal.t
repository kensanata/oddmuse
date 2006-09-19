require 't/test.pl';
package OddMuse;
use Test::More tests => 26;

clear_pages();

update_page('2003-06-13', "Freitag");
update_page('2003-06-14', "Samstag");
update_page('2003-06-15', "Sonntag");

@Test = split('\n',<<'EOT');
This is my journal
2003-06-15
Sonntag
2003-06-14
Samstag
EOT

test_page(update_page('Summary', "This is my journal:\n\n<journal 2>"), @Test);
test_page(update_page('2003-01-01', "This is my journal -- recursive:\n\n<journal>"), @Test);
push @Test, 'journal';
test_page(update_page('2003-01-01', "This is my journal -- truly recursive:\n\n<journal>"), @Test);

test_page(update_page('Summary', "Counting down:\n\n<journal 2>"),
	  '2003-06-15(.|\n)*2003-06-14');

test_page(update_page('Summary', "Counting up:\n\n<journal 3 reverse>"),
	  '2003-01-01(.|\n)*2003-06-13(.|\n)*2003-06-14');

$page = update_page('Summary', "Counting down:\n\n<journal>");
test_page($page, '2003-06-15(.|\n)*2003-06-14(.|\n)*2003-06-13(.|\n)*2003-01-01');
negative_xpath_test($page, '//h1/a[not(text())]');

test_page(update_page('Summary', "Counting up:\n\n<journal reverse>"),
	  '2003-01-01(.|\n)*2003-06-13(.|\n)*2003-06-14(.|\n)*2003-06-15');

AppendStringToFile($ConfigFile, "\$JournalLimit = 2;\n\$ComentsPrefix = 'Talk about ';\n");

$page = update_page('Summary', "Testing the limit of two:\n\n<journal>");
test_page($page, '2003-06-15', '2003-06-14');
test_page_negative($page, '2003-06-13', '2003-01-01');

test_page(get_page('action=browse id=Summary pwd=foo'),
	  '2003-06-15(.|\n)*2003-06-14(.|\n)*2003-06-13(.|\n)*2003-01-01');
