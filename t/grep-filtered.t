# Copyright (C) 2006–2020  Alex Schroeder <alex@gnu.org>
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

# These tests were copied from search.t...

require './t/test.pl';
package OddMuse;
use Test::More;
use utf8; # tests contain UTF-8 characters and it matters

add_module('grep-filtered.pl');

# Search for broken regular expressions

test_page(get_page('search=%2Btest'), 'Search for: \+test');

# Test search, make sure ordinary users don't see the replacement form

update_page('SearchAndReplace', 'This is fooz and this is barz.', '', 1);
$page = get_page('search=fooz');
test_page($page,
	  '<h1>Search for: fooz</h1>',
	  '<p class="result">1 pages found.</p>',
	  'This is <strong>fooz</strong> and this is barz.');
xpath_test($page, '//span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/SearchAndReplace"][text()="SearchAndReplace"]');
test_page_negative($page, 'Replace:');

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

test_page(get_page('search=foo pwd=foo'),
	  'Replace:');

test_page(get_page('search=foo replace=bar'),
	  'This operation is restricted to administrators only...');

# Preview simple replacement operation

test_page(get_page('search=fooz replace=fuuz preview=1 pwd=foo'), split('\n',<<'EOT'));
<h1>Preview: fooz &#x2192; fuuz</h1>
<p class="result">1 pages found.</p>
<div class="old"><p>&lt; This is <strong class="changes">fooz</strong> and this is barz.
<div class="new"><p>&gt; This is <strong class="changes">fuuz</strong> and this is barz.
EOT

# Verify that the change has not been made

test_page(get_page('SearchAndReplace'), 'This is fooz and this is barz.');

# Simple replace where the replacement pattern is found

test_page(get_page('search=fooz replace=fuuz pwd=foo'), split('\n',<<'EOT'));
<h1>Replaced: fooz &#x2192; fuuz</h1>
<p class="result">1 pages found.</p>
This is <strong>fuuz</strong> and this is barz.
EOT

# Verify that the change has been made

test_page(get_page('SearchAndReplace'), 'This is fuuz and this is barz.');

# Replace with empty string

test_page(get_page('search=this%20is%20 replace= pwd=foo delete=1'), split('\n',<<'EOT'));
<h1>Replaced: this is  &#x2192; </h1>
<p class="result">1 pages found.</p>
fuuz and barz.
EOT

test_page(get_page('SearchAndReplace'), '<p>fuuz and barz.');

# Creating 12 pages
for my $i ('A' .. 'M') {
  OpenPage("Page_$i");
  Save("Page_$i", 'Something');
}

# Testing default pagination (10 pages)

$page = get_page('search=Something replace=Other preview=1 pwd=foo');
test_page($page, split('\n',<<'EOT'));
<h1>Preview: Something &#x2192; Other</h1>
<p class="result">13 pages found.</p>
<div class="old"><p>&lt; <strong class="changes">Something</strong>
<div class="new"><p>&gt; <strong class="changes">Other</strong>
EOT

test_page($page, map { "Page_$_" } ('A' .. 'J'));
test_page_negative($page, map { "Page_$_" } ('K' .. 'M'));
xpath_test($page, '//a[@class="more"][@href="http://localhost/wiki.pl?search=Something;preview=1;offset=10;num=10;replace=Other"]');

# Next page

$page = get_page('search=Something preview=1 offset=10 num=10 replace=Other pwd=foo');
test_page($page, map { "Page_$_" } ('K' .. 'M'));

# Now do the replacement

$page = get_page('search=Something replace=Other pwd=foo');
test_page($page, 'Replaced: Something &#x2192; Other', '13 pages found',
	  map { "Page_$_" } ('A' .. 'M'));

# Verify that the change has been made

test_page(get_page('search=Other'), 'Search for: Other', '13 pages found');


# Replace with backreferences, where the replacement pattern is no longer found.
# Take 'fuuz and barz.' and replace ([a-z]+)z with x$1 results in 'xfuu and xbar.'
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
test_page(get_page('SearchAndReplace'), '\{\{fuu\}\} and \[xa\]bar.');

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

xpath_test(get_page('search=Schröder'),
	   '//input[@name="search"][@value="Schröder"]');

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

# Search for quoted strings

update_page("Tugend", "Ein wirklich tugendhafter Mensch
bemüht sich nicht um seine Tugend,
darum ist er tugendhaft.");
update_page("Laster", "Ein scheinbar tugendhafter Mensch
bemüht sich dauernd um seine Tugend,
darum ist er nicht wirklich tugendhaft.");

# unordered words
test_page(get_page('search="darum ist er tugendhaft" raw=1'),
          'title: Tugend', 'title: Laster');

# in order
$page = get_page('search="\"darum ist er tugendhaft\"" raw=1');
test_page($page, 'title: Tugend');
test_page_negative($page, 'title: Laster');

done_testing;
