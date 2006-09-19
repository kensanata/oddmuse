require 't/test.pl';
package OddMuse;
use Test::More tests => 30;

SKIP: {
  eval { require Search::FreeText };
  skip ("Search::FreeText not installed", 30) if $@;

  clear_pages();
  AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");
  add_module('search-freetext.pl');

  update_page('Search (and replace)', 'Muu, or moo. [[tag:test]] [[tag:Öl]]');
  update_page('To be, or not to be', 'That is the question. (Right?) [[tag:test]] [[tag:BE3]]');
  update_page('alex pic', "#FILE image/png\niVBORw0KGgoAAAA");

  get_page('action=buildindex pwd=foo');

  test_page_negative(get_page('search=AAA raw=1'), 'alex_pic');
  test_page(get_page('search=alex raw=1'), 'alex_pic', 'image/png');
  test_page(get_page('search=png raw=1'), 'alex_pic', 'image/png');
  get_page('action=retag id=alex_pic tags=drink%20food');
  xpath_test(get_page('alex_pic'),
	     '//div[@class="tags"]/p/a[@rel="tag"]',
	     '//a[@class="outside tag"][@rel="tag"][@title="Tag"][@href="http://technorati.com/tag/drink"][text()="drink"]',
	     '//a[@class="outside tag"][@rel="tag"][@title="Tag"][@href="http://technorati.com/tag/food"][text()="food"]',
	    );
  xpath_test(get_page('action=edit id=alex_pic'),
	     '//div[@class="edit tags"]/form/p/textarea[text()="drink food"]',
	    );

  # index the retagging and test journal with search
  get_page('action=buildindex pwd=foo');
  # uses iso date regexp on page titles by default
  test_page(update_page('JournalTest', '<journal search tag:drink>'),
	    '<div class="content browse"></div>');
  xpath_test(update_page('JournalTest', '<journal "." search tag:drink>'),
	     '//div[@class="content browse"]/div[@class="journal"]/div[@class="page"]/h1/a[@class="local"][text()="alex pic"]',
	     '//div[@class="content browse"]/div[@class="journal"]/div[@class="page"]/p/img[@class="upload"][@alt="alex pic"][@src="http://localhost/wiki.pl/download/alex_pic"]');
  xpath_test(update_page('JournalTest', '<journal "." search tag:"drink">'),
	     '//div[@class="content browse"]/div[@class="journal"]/div[@class="page"]/h1/a[@class="local"][text()="alex pic"]',
	     '//div[@class="content browse"]/div[@class="journal"]/div[@class="page"]/p/img[@class="upload"][@alt="alex pic"][@src="http://localhost/wiki.pl/download/alex_pic"]');

  test_page(get_page('search=Search+replace raw=1'),
	    quotemeta('Search_(and_replace)'));
  test_page(get_page('search=search raw=1'),
	    quotemeta('Search_(and_replace)'));
  test_page(get_page('search=SEARCH raw=1'),
	    quotemeta('Search_(and_replace)'));
  test_page(get_page('search=Search\+%5c\(and\+replace%5c\) raw=1'),
	    quotemeta('Search_(and_replace)'));
  test_page(get_page('search=%22Search\+%5c\(and\+replace%5c\)%22 raw=1'),
	    quotemeta('Search_(and_replace)'));
  test_page(get_page('search=moo+foo raw=1'),
	    quotemeta('Search_(and_replace)'));
  test_page(get_page('search=To+be%2c+or+not+to+be raw=1'),
	    quotemeta('To_be,_or_not_to_be'));
  test_page(get_page('search=%22To+be%2c+or+not+to+be%22 raw=1'),
	    quotemeta('To_be,_or_not_to_be'));
  test_page(get_page('search="%22(Right%3F)%22" raw=1'),
	    quotemeta('To_be,_or_not_to_be'));
  test_page(get_page('search=tag:test raw=1'),
	    quotemeta('To_be,_or_not_to_be'), quotemeta('Search_(and_replace)'));
  test_page(get_page('search=tag:be3 raw=1'),
	    quotemeta('To_be,_or_not_to_be'));
  test_page(get_page('search=tag:%c3%96l raw=1'),
	    quotemeta('Search_(and_replace)'));
  test_page(get_page('action=cloud'),
	    'search=tag:%c3%96l', 'search=tag:test', 'search=tag:be3');
}
