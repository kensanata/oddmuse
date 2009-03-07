# Copyright (C) 2008, 2009  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 48;
clear_pages();

add_module('journal-rss.pl');

# summaries eq page content since no summaries are provided
update_page('2008-09-21', 'first page');
update_page('2008-09-22', 'second page'); # major
sleep(1);
update_page('2008-09-22', 'third edit', 'third edit', 1); # minor
update_page('unrelated', 'wrong page');

my $page = get_page('action=journal');
test_page($page,
	  '2008-09-21', 'first page',
	  # ignore minor edits are ignored: show last major edit
	  # instead
	  '2008-09-22', 'second page',
	  # reverse sort is the default
	  '2008-09-22(.*\n)+.*2008-09-21');

# make sure unrelated pages and minor edits don't show up
test_page_negative($page, 'unrelated', 'wrong page',
		   'third edit');

# verify the order of pages
test_page(get_page('action=journal'),
	  '2008-09-22(.*\n)+.*2008-09-21');

# reverse the order
test_page(get_page('action=journal reverse=1'),
	  '2008-09-21(.*\n)+.*2008-09-22');

# match parameter
$page = get_page('action=journal match=21');
test_page($page, '2008-09-21', 'first page');
test_page_negative($page, '2008-09-22', 'second page');

# search parameter
$page = get_page('action=journal search=second');

# no pages found, since this is for an old revision!
test_page_negative($page,
		   '2008-09-21', 'first page',
		   '2008-09-22', 'second page',
		   'third edit');

# strange but true: search returns a page based on the minor edit but
# shows the latest major revision that doesn't actually match.
$page = get_page('action=journal search=third');
test_page($page, '2008-09-22', 'second page');
test_page_negative($page, '2008-09-21', 'first page', 'third edit');

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

$page = get_page('action=journal rsslimit=all');
test_page($page, '2008-09-22', '2008-09-05');

# Now let's show that we're using the timestamp of the last major
# change if possible.

my @dates = get_page('action=rss showedit=1 all=1 match=2008-09-22')
  =~ m!<pubDate>(.*?)</pubDate>!g;
# $dates[0] is the channel pubDate
my $date2 = $dates[1]; # revision 2 comes first
my $date1 = $dates[2]; # revision 1 comes second
my ($item) = $page =~ m!(<item>\n<title>2008-09-22</title>\n(.*\n)+?</item>\n)!;
test_page($item, "<pubDate>$date1</pubDate>");
test_page_negative($item, "<pubDate>$date2</pubDate>");
