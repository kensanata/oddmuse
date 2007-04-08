# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

require 't/test.pl';
package OddMuse;
use Test::More tests => 12;
clear_pages();

my ($sec, $min, $hour, $mday, $mon, $year) = localtime($Now);
$mon++;
$year += 1900;
my $year_next = $year +1;
my $year_prev = $year -1;
my $today = sprintf("%d-%02d-%02d", $year, $mon, $mday);
$oday = $mday -1;
$oday += 2 if $oday < 1;
my $otherday = sprintf("%d-%02d-%02d", $year, $mon, $oday);

add_module('calendar.pl');

test_page(update_page("with_cal", "zulu\n\ncalendar:2006\n\nwarrior\n"),
	  '<p>zulu</p><p class="nav">',
	  '</pre></div><p>warrior</p></div><div class="wrapper close"></div></div><div class="footer">');

test_page(update_page("with_cal", "zulu\n\nmonth:2006-09\n\nwarrior\n"),
	  '<p>zulu</p><div class="cal month"><pre>',
	  '</pre></div><p>warrior</p></div><div class="wrapper close"></div></div><div class="footer">');

test_page(update_page("with_cal", "zulu\n\nmonth:+0\n\nwarrior\n"),
	  '<p>zulu</p><div class="cal month"><pre>',
	  '</pre></div><p>warrior</p></div><div class="wrapper close"></div></div><div class="footer">');

xpath_test(get_page('action=calendar'),
	   # yearly navigation
	  '//div[@class="content cal year"]/p[@class="nav"]/a[@href="http://localhost/wiki.pl?action=calendar;year=' . $year_prev . '"][text()="Previous"]/following-sibling::text()[string()=" | "]/following-sibling::a[@href="http://localhost/wiki.pl?action=calendar;year=' . $year_next . '"][text()="Next"]',
	   # monthly collection
	  '//div[@class="cal month"]/pre/span[@class="title"]/a[@class="local collection month"][@href="http://localhost/wiki.pl?action=collect;match=%5e' . sprintf("%d-%02d", $year, $mon)  . '"]',
	  # today day edit
	  '//a[@class="edit today"][@href="http://localhost/wiki.pl?action=edit;id=' . $today . '"][normalize-space(text())="' . $mday . '"]',
	  # other day edit
	  '//a[@class="edit"][@href="http://localhost/wiki.pl?action=edit;id=' . $otherday . '"][normalize-space(text())="' . $oday . '"]',
	  );

update_page($today, "yadda");

xpath_test(get_page('action=calendar'),
	   # day exact match
	   '//a[@class="local exact today"][@href="http://localhost/wiki.pl/' . $today . '"][normalize-space(text())="' . $mday . '"]');

update_page("${today}_more", "more yadda");

xpath_test(get_page('action=calendar'),
	  # today exact match
	  '//a[@class="local collection today"][@href="http://localhost/wiki.pl?action=collect;match=%5e' . $today . '"][normalize-space(text())="' . $mday . '"]');
