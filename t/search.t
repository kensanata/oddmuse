# Copyright (C) 2006, 2007, 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 38;

clear_pages();

add_module('mac.pl');

# Search for broken regular expressions

test_page(get_page('search=%2Btest'),
	  '<h1>Malformed regular expression in \+test</h1>');

# Test search

update_page('SearchAndReplace', 'This is fooz and this is barz.', '', 1);
$page = get_page('search=fooz');
test_page($page,
	  '<h1>Search for: fooz</h1>',
	  '<p class="result">1 pages found.</p>',
	  'This is <strong>fooz</strong> and this is barz.');
xpath_test($page, '//span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/SearchAndReplace"][text()="SearchAndReplace"]');

# Search page name
$page = get_page('search=andreplace');
test_page($page,
	  '<h1>Search for: andreplace</h1>',
	  '<p class="result">1 pages found.</p>');
	  # FIXME: Not sure this should work... 'Search<strong>AndReplace</strong>'
xpath_test($page, '//span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/SearchAndReplace"][text()="SearchAndReplace"]');

# Brackets in the page name

test_page(update_page('Search (and replace)', 'Muu'),
	  'search=%22Search\+%5c\(and\+replace%5c\)%22');

# Make sure only admins can replace

test_page(get_page('search=foo replace=bar'),
	  'This operation is restricted to administrators only...');

# Simple replace where the replacement pattern is found

test_page(get_page('search=fooz replace=fuuz pwd=foo'), split('\n',<<'EOT'));
<h1>Replaced: fooz &#x2192; fuuz</h1>
<p class="result">1 pages found.</p>
This is <strong>fuuz</strong> and this is barz.
EOT

# Replace with empty string

test_page(get_page('search=this%20is%20 replace= pwd=foo delete=1'), split('\n',<<'EOT'));
<h1>Replaced: this is  &#x2192; </h1>
<p class="result">1 pages found.</p>
fuuz and barz.
EOT

# Replace with backreferences, where the replacement pattern is no longer found

test_page(get_page('"search=([a-z]%2b)z" replace=x%241 pwd=foo'), '1 pages found');
test_page(get_page('SearchAndReplace'), 'xfuu and xbar.');

# Create an extra page that should not be found
update_page('NegativeSearchTest', 'this page contains an ab');
update_page('NegativeSearchTestTwo', 'this page contains another ab');
test_page(get_page('search=xb replace=[xa]b pwd=foo'), '1 pages found'); # not two ab!
test_page(get_page('SearchAndReplace'), 'xfuu and \[xa\]bar.');

# Handle quoting
test_page(get_page('search=xfuu replace=/fuu/ pwd=foo'), '1 pages found'); # not two ab!
test_page(get_page('SearchAndReplace'), '/fuu/ and \[xa\]bar.');
test_page(get_page('search=/fuu/ replace={{fuu}} pwd=foo'), '1 pages found');
test_page(get_page('SearchAndReplace'), '{{fuu}} and \[xa\]bar.');

# Check headers especially the quoting of non-ASCII characters.

$page = update_page("Alexander_Schröder", "Edit [[Alexander Schröder]]!");
xpath_test($page,
	   '//h1/a[@title="Click to search for references to this page"][@href="http://localhost/wiki.pl?search=%22Alexander+Schr%c3%b6der%22"][text()="Alexander Schröder" or text()="' . Encode::encode_utf8('Alexander Schröder') . '"]',
	   '//a[@class="local"][@href="http://localhost/wiki.pl/Alexander_Schr%c3%b6der"][text()="Alexander Schröder" or text()="' . Encode::encode_utf8('Alexander Schröder') . '"]');

xpath_test(update_page('IncludeSearch',
		       "first line\n<search \"ab\">\nlast line"),
	   '//p[text()="first line "]', # note the NL -> SPC
	   '//div[@class="search"]/p/span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/NegativeSearchTest"][text()="NegativeSearchTest"]',
	   '//div[@class="search"]/p/span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/NegativeSearchTestTwo"][text()="NegativeSearchTestTwo"]',
	  '//p[text()=" last line"]'); # note the NL -> SPC

# Search for zero

update_page("Zero", "This is about 0 and the empty string ''.");
test_page(get_page('search=0'),
	  '<h1>Search for: 0</h1>',
	  '<p class="result">1 pages found.</p>',
	  "This is about <strong>0</strong> and the empty string ''.",
	  'meta name="robots" content="NOINDEX,FOLLOW"');

# Search for tags

update_page("Tag", "This is <b>bold</b>.");
test_page(get_page('search="<b>"'),
	  '<h1>Search for: &lt;b&gt;</h1>',
	  '<p class="result">1 pages found.</p>',
	  "This is <strong>&lt;b&gt;</strong>.");

# Test fallback when grep is unavailable

TODO: {
  local $TODO = "Don't get a decent error when opening the grep pipe";
  AppendStringToFile($ConfigFile, "\$ENV{PATH} = '';\n");
  test_page(get_page('search=empty'),
	    "1 pages found");
}
