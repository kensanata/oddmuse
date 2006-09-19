require 't/test.pl';
package OddMuse;
use Test::More tests => 23;

clear_pages();

add_module('mac.pl');

# Test search

update_page('SearchAndReplace', 'This is fooz and this is barz.', '', 1);
$page = get_page('search=fooz');
test_page($page,
	  '<h1>Search for: fooz</h1>',
	  '<p class="result">1 pages found.</p>',
	  'This is <strong>fooz</strong> and this is barz.');
xpath_test($page, '//span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/SearchAndReplace"][text()="SearchAndReplace"]');

# Brackets in the page name

test_page(update_page('Search (and replace)', 'Muu'),
	  'search=%22Search\+%5c\(and\+replace%5c\)%22');

# Make sure only admins can replace

test_page(get_page('search=foo replace=bar'),
	  'This operation is restricted to administrators only...');

# Simple replace where the replacement pattern is found

test_page(get_page('search=fooz replace=fuuz pwd=foo'), split('\n',<<'EOT'));
<h1>Replaced: fooz -&gt; fuuz</h1>
<p class="result">1 pages found.</p>
This is <strong>fuuz</strong> and this is barz.
EOT

# Replace with backreferences, where the replacement pattern is no longer found

test_page(get_page('search=([a-z]%2b)z replace=x%241 pwd=foo'), '0 pages found');
test_page(get_page('SearchAndReplace'), 'This is xfuu and this is xbar.');

# Create an extra page that should not be found
update_page('NegativeSearchTest', 'this page contains an ab');
update_page('NegativeSearchTestTwo', 'this page contains another ab');
test_page(get_page('search=xb replace=[xa]b pwd=foo'), '1 pages found'); # not two ab!
test_page(get_page('SearchAndReplace'), 'This is xfuu and this is \[xa\]bar.');

# Handle quoting
test_page(get_page('search=xfuu replace=/fuu/ pwd=foo'), '1 pages found'); # not two ab!
test_page(get_page('SearchAndReplace'), 'This is /fuu/ and this is \[xa\]bar.');
test_page(get_page('search=/fuu/ replace={{fuu}} pwd=foo'), '1 pages found');
test_page(get_page('SearchAndReplace'), 'This is {{fuu}} and this is \[xa\]bar.');

## Check headers especially the quoting of non-ASCII characters.

$page = update_page("Alexander_Schröder", "Edit [[Alexander Schröder]]!");
xpath_test($page,
	   Encode::encode_utf8('//h1/a[@title="Click to search for references to this page"][@href="http://localhost/wiki.pl?search=%22Alexander+Schr%c3%b6der%22"][text()="Alexander Schröder"]'),
	   Encode::encode_utf8('//a[@class="local"][@href="http://localhost/wiki.pl/Alexander_Schr%c3%b6der"][text()="Alexander Schröder"]'));

xpath_test(update_page('IncludeSearch',
		       "first line\n<search \"ab\">\nlast line"),
	   '//p[text()="first line "]', # note the NL -> SPC
	   '//div[@class="search"]/p/span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/NegativeSearchTest"][text()="NegativeSearchTest"]',
	   '//div[@class="search"]/p/span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/NegativeSearchTestTwo"][text()="NegativeSearchTestTwo"]',
	  '//p[text()=" last line"]'); # note the NL -> SPC
