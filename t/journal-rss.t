# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 16;
clear_pages();

add_module('journal-rss.pl');

# summaries eq page content since no summaries are provided
update_page('2008-09-21', 'first page');
update_page('2008-09-22', 'second page', undef, 1); # minor
update_page('unrelated', 'wrong page');

my $page = get_page('action=journal');
test_page($page,
	  '2008-09-21', 'first page',
	  '2008-09-22', 'second page',
	  # reverse sort is the default
	  '2008-09-22(.*\n)+.*2008-09-21');
test_page_negative($page, 'unrelated', 'wrong page');

test_page(get_page('action=journal reverse=1'),
	  '2008-09-21(.*\n)+.*2008-09-22');

my $page = get_page('action=journal match=21');
test_page($page, '2008-09-21', 'first page');
test_page_negative($page, '2008-09-22', 'second page');

my $page = get_page('action=journal search=second');
test_page($page, '2008-09-22', 'second page');
test_page_negative($page, '2008-09-21', 'first page');
