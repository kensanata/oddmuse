require 't/test.pl';
package OddMuse;
use Test::More tests => 5;

clear_pages();

CreateDir($NearDir);
WriteStringToFile("$NearDir/EmacsWiki", "AlexSchroeder\nFooBar\n");

update_page('InterMap', " EmacsWiki http://www.emacswiki.org/cgi-bin/wiki/%s\n",
	    'required', 0, 1);
update_page('NearMap', " EmacsWiki"
	    . " http://www.emacswiki.org/cgi-bin/emacs?action=index;raw=1"
	    . " http://www.emacswiki.org/cgi-bin/emacs?search=%s;raw=1;near=0\n",
	    'required', 0, 1);

xpath_test(update_page('FooBaz', "Try FooBar instead!\n"),
	   '//a[@class="near"][@title="EmacsWiki"][@href="http://www.emacswiki.org/cgi-bin/wiki/FooBar"][text()="FooBar"]',
	   '//div[@class="near"]/p/a[@class="local"][@href="http://localhost/wiki.pl/EditNearLinks"][text()="EditNearLinks"]/following-sibling::text()[string()=": "]/following-sibling::a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=FooBar"][text()="FooBar"]');

xpath_test(update_page('FooBar', "Test by AlexSchroeder!\n"),
	  '//div[@class="sister"]/p/a[@title="EmacsWiki:FooBar"][@href="http://www.emacswiki.org/cgi-bin/wiki/FooBar"]/img[@src="file:///tmp/oddmuse/EmacsWiki.png"][@alt="EmacsWiki:FooBar"]');

xpath_test(get_page('search=alexschroeder'),
	   '//p[text()="Near pages:"]',
	   '//a[@class="near"][@title="EmacsWiki"][@href="http://www.emacswiki.org/cgi-bin/wiki/AlexSchroeder"][text()="AlexSchroeder"]');
