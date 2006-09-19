require 't/test.pl';
package OddMuse;
use Test::More tests => 6;
clear_pages();

add_module('all.pl');

update_page('foo', 'link to [[bar]].');
update_page('bar', 'link to [[baz]].');
test_page(get_page('action=all'), 'restricted to administrators');
xpath_test(get_page('action=all pwd=foo'),
	   '//p/a[@href="#HomePage"][text()="HomePage"]',
	   '//h1/a[@name="foo"][text()="foo"]',
	   '//a[@class="local"][@href="#bar"][text()="bar"]',
	   '//h1/a[@name="bar"][text()="bar"]',
	   '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=baz"][text()="?"]',
	  );
