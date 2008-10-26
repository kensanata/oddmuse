# Copyright (C) 2006, 2007, 2008  Alex Schroeder <alex@gnu.org>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 61;

SKIP: {
  eval { require Search::FreeText };
  skip ("Search::FreeText not installed", 61) if $@;

  clear_pages();

  add_module('search-freetext.pl');

  # Test uploaded pictures, too.
  AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");

  # Basic journal page test
  test_page(update_page('2007-10-10', 'ordinary page'), 'ordinary');
  test_page(get_page('action=more'), 'ordinary');

  # Test delta indexes as we're not reindexing the pages: Create two
  # pages; one should be part of the journal, the other should not.
  update_page('2007-10-11', 'page tagged [[tag:foo]]');
  test_page(update_page('Diary', '<journal>'),
	    '2007-10-10', 'ordinary', '2007-10-11', 'tagged');
  $page = update_page('Diary', '<journal search tag:foo>');
  test_page_negative($page, 'ordinary page');
  test_page($page, 'page tagged');
  $page = update_page('Diary', '<journal search -tag:foo>');
  test_page($page, 'ordinary page');
  test_page_negative($page, 'page tagged');

  # Test tags containing spaces
  xpath_test(update_page('2008-10-24', 'this page is [[tag:foo bar]]'),
	   '//a[@href="http://technorati.com/tag/%22foo%20bar%22"]');
  $page = get_page('action=more search=tag%3a%22foo+bar%22');
  test_page($page, 'this page is');
  test_page_negative($page, 'page tagged'); # simple foo tag not included
  $page = get_page('search=tag%3a%22foo+bar%22');
  test_page($page, 'this page is');
  test_page_negative($page, 'page tagged'); # simple foo tag not included
  $page = get_page('search=tag%3afoo');
  test_page($page, 'page tagged');
  test_page_negative($page, 'this page is'); # without composite foo bar tag

  # Mandatory matches using tags and double quotes.
  update_page('2008-10-26', 'two tags [[tag:foo]] [[tag:baz]]');
  $page = get_page('action=more search=tag:foo+tag:baz');
  test_page($page, '2007-10-11', '2008-10-26'); # page tagged foo is included
  test_page_negative($page, '2007-10-10', '2008-10-24');
  $page = get_page('action=more search=tag%3afoo%20tag%3a%22baz%22');
  test_page($page, '2008-10-26'); # page tagged foo is no longer included
  test_page_negative($page, '2007-10-11', '2007-10-10', '2008-10-24');

  # uploads, strange characters in the names and so on
  update_page('Search (and replace)', 'Muu, or moo. [[tag:test]] [[tag:Öl]]');
  update_page('To be, or not to be', 'That is the question. (Right?) [[tag:test]] [[tag:BE3]]');
  update_page('alex pic', "#FILE image/png\niVBORw0KGgoAAAA");

  get_page('action=buildindex pwd=foo');

  # first, let's update an existing page and make sure it doesn't show
  # up twice!
  update_page('2007-10-11', 'the same page tagged [[tag:foo]]');
  $page = get_page('search=tag:foo');
  xpath_test($page, '//p/span[@class="result"]/a[text()="2007-10-11"]');
  negative_xpath_test($page, '//p[span[@class="result"]/a[text()="2007-10-11"]]/following-sibling::p[span[@class="result"]/a[text()="2007-10-11"]]');

  # image search
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
	    quotemeta('title: Search_(and_replace)'));
  test_page(get_page('search=SEARCH raw=1 context=0'),
	    "\n" . quotemeta('Search_(and_replace)') . "\n");
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
	    'search=tag:%c3%96l', 'search=tag:test', 'search=tag:be3',
	    'search=tag:foo_bar');
  test_page_negative(get_page('search=-tag:%c3%96l raw=1'),
		     quotemeta('Search_(and_replace)'));
  test_page(get_page('search=-tag:test raw=1'),
	    quotemeta('alex_pic'));
}
