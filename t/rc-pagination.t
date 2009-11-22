# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 42;

clear_pages();

$RcDefault = 7;
AppendStringToFile($ConfigFile, "\$RcDefault = $RcDefault;\n");

my $now = time - 10;
my $day = 24*60*60;
for my $i (reverse 0 .. 20, 50 .. 60) {
  my $ts = $now - $i * $day;
  AppendStringToFile($RcFile, "$ts${FS}test$i${FS}${FS}test$i${FS}${FS}${FS}1${FS}${FS}\n");
}

# default page lists correct number of pages
my $rc = get_page('action=rc');

xpath_test($rc, map { "//a[text()='test$_']" } (0..6));
# 7 is exactly 7 * 24h + 10 seconds in the past, ie. it should not show up
negative_xpath_test($rc, map { "//a[text()='test$_']" } (7..10));

# at least one line
xpath_test($rc, '//div[@class="rc"]');

# find "more" link
my $url = xpath_test($rc, '//a[text()="More..."][@class="more"]/attribute::href');
my ($from, $upto) = $url =~ /from=(\d+);upto=(\d+)/;
is($from + $RcDefault * $day, $upto, "upto param set to 7d after from param");
ok(abs($now+10 - $RcDefault * $day - $upto) <= 2,
   "upto param really close to 7d before present");

# get second page
$rc = get_page("action=rc from=$from upto=$upto");
negative_xpath_test($rc, map { "//a[text()='test$_']" } (3..6));
xpath_test($rc, map { "//a[text()='test$_']" } (7..13));
negative_xpath_test($rc, map { "//a[text()='test$_']" } (14..17));

# get a page far in the past
$from = $now - 100 * $day;
$upto = $from + $RcDefault * $day;
$rc = get_page("action=rc from=$from upto=$upto");

# there should be no links
xpath_test($rc, '//div[@class="rc"]');
negative_xpath_test($rc, '//ul/li/span[@class="time"]');

# get a page with some links
$from = $now - 52 * $day;
$upto = $from + $RcDefault * $day;
$rc = get_page("action=rc from=$from upto=$upto");

# there should be links from 50 .. 52
negative_xpath_test($rc, map { "//a[text()='test$_']" } (45 .. 49));
xpath_test($rc, map { "//a[text()='test$_']" } (50 .. 52));
negative_xpath_test($rc, map { "//a[text()='test$_']" } (53 .. 54));
