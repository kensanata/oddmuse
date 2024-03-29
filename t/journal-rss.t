# Copyright (C) 2008-2021  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require './t/test.pl';
package OddMuse;
use Test::More tests => 45;

add_module('journal-rss.pl');

update_page('2008-09-21', 'first page', '', 1); # minor
update_page('2008-09-22', 'second page'); # major

OpenPage('2008-09-22');
my $ts1 = $Page{ts};

sleep(1);

update_page('2008-09-22', 'third edit content', 'third edit summary', 1); # minor

$OpenPageName = ''; # force OpenPage to reopen the page
OpenPage('2008-09-22');
my $ts2 = $Page{ts};

isnt($ts1, $ts2, "timestamps are different");

update_page('unrelated', 'wrong page');

my $page = get_page('action=journal');
test_page($page,
	  # make sure pages with only minor edits get shown as well
	  '2008-09-21', 'first page',
	  # make sure we're showing full page content, not summaries
	  '2008-09-22', 'third edit content',
	  # reverse sort is the default
	  '2008-09-22(.*\n)+.*2008-09-21');

# make sure unrelated pages don't show up
test_page_negative($page, 'unrelated', 'wrong page');

# make sure the minor change doesn't affect the timestamp
my $date = quotemeta("<pubDate>" . TimeToRFC822($ts1) . "</pubDate>");
like($page, qr/$date/, "minor don't change the timestamp");

# reverse the order
test_page(get_page('action=journal reverse=1'),
	  '2008-09-21(.*\n)+.*2008-09-22');

# match parameter
$page = get_page('action=journal match=21');
test_page($page, '2008-09-21', 'first page');
test_page_negative($page, '2008-09-22', 'second page');

# testing the limit default
update_page('2008-09-05', 'page');
update_page('2008-09-06', 'page');
update_page('2008-09-07', 'page');
update_page('2008-09-08', 'page');
update_page('2008-09-09', 'page');
update_page('2008-09-10', 'page');
update_page('2008-09-11', 'page');
update_page('2008-09-12', 'page');
update_page('2008-09-13', 'page');
update_page('2008-09-14', 'page');
update_page('2008-09-15', 'page');
update_page('2008-09-16', 'page');
update_page('2008-09-17', 'page');
update_page('2008-09-18', 'page');
update_page('2008-09-19', 'page');
update_page('2008-09-20', 'page');

$page = get_page('action=journal');
test_page($page, '2008-09-22', '2008-09-21', '2008-09-20', '2008-09-19',
	  '2008-09-18', '2008-09-17', '2008-09-16', '2008-09-15',
	  '2008-09-14', '2008-09-13');
test_page_negative($page, '2008-09-12', '2008-09-11', '2008-09-10',
		   '2008-09-09', '2008-09-08', '2008-09-07',
		   '2008-09-06', '2008-09-05');

# testing the rss limit parameter
$page = get_page('action=journal rsslimit=1');
test_page($page, '2008-09-22');
test_page_negative($page, '2008-09-21');

# make sure we start from a well-known point in time
AppendStringToFile($ConfigFile, "push(\@MyInitVariables, sub { \$Now = '$Now' });\n");

# check default RSS
xpath_test(get_page('action=journal'),
	   '//atom:link[@rel="self"][@href="http://localhost/wiki.pl?action=journal"]',
	   '//atom:link[@rel="last"][@href="http://localhost/wiki.pl?action=journal"]',
	   '//atom:link[@rel="previous"][@href="http://localhost/wiki.pl?action=journal;offset=10"]');

# check next page
xpath_test(get_page('action=journal offset=10'),
	   '//atom:link[@rel="self"][@href="http://localhost/wiki.pl?action=journal;offset=10"]',
	   '//atom:link[@rel="last"][@href="http://localhost/wiki.pl?action=journal"]',
	   '//atom:link[@rel="previous"][@href="http://localhost/wiki.pl?action=journal;offset=20"]');

# check next page but with a tag search
xpath_test(get_page('action=journal search=tag:oddmuse'),
	   '//atom:link[@rel="self"][@href="http://localhost/wiki.pl?action=journal;search=tag%3aoddmuse"]',
	   '//atom:link[@rel="last"][@href="http://localhost/wiki.pl?action=journal;search=tag%3aoddmuse"]',
	   '//atom:link[@rel="previous"][@href="http://localhost/wiki.pl?action=journal;offset=10;search=tag%3aoddmuse"]');

# check raw
$page = get_page('action=journal raw=1 rsslimit=1');
test_page($page, 'generator: Oddmuse', 'title: 2008-09-22');
