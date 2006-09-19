require 't/test.pl';
package OddMuse;
use Test::More tests => 15;

clear_pages();

## Create a sample page, and test for regular expressions in the output

$page = update_page('SandBox', 'This is a test.', 'first test');
test_page($page, 'SandBox', 'This is a test.');
xpath_test($page, '//h1/a[@title="Click to search for references to this page"][@href="http://localhost/wiki.pl?search=%22SandBox%22"][text()="SandBox"]');

## Test RecentChanges

test_page(get_page('action=rc'), 'RecentChanges', 'first test');

## Updated the page

test_page(update_page('SandBox', 'This is another test.', 'second test'),
	  'RecentChanges', 'This is another test.');

## Test RecentChanges

test_page(get_page('action=rc'),
	  'RecentChanges',
	  'second test');

## Attempt to create InterMap page as normal user

test_page(update_page('InterMap',
		      " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n",
		      'required'),
	  'Describe the new page here');

## Create InterMap page as admin

test_page(update_page('InterMap',
		      " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n PlanetMath http://planetmath.org/encyclopedia/%s.html",
		      'required', 0, 1),
	  split('\n',<<'EOT'));
OddMuse
http://www\.emacswiki\.org/cgi-bin/oddmuse\.pl
PlanetMath
http://planetmath\.org/encyclopedia/\%s\.html
EOT

## Verify the InterMap stayed locked

test_page(update_page('InterMap', "All your edits are blong to us!\n",
		      'required'),
	  'OddMuse');
