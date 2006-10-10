# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 8;

clear_pages();

do 'modules/anchors.pl';
do 'modules/link-all.pl'; # check compatibility

xpath_run_tests(split('\n',<<'EOT'));
This is a [:day for fun and laughter].
//a[@class="anchor"][@name="day_for_fun_and_laughter"]
[[#day for fun and laughter]].
//a[@class="local anchor"][@href="#day_for_fun_and_laughter"][text()="day for fun and laughter"]
[[2004-08-17#day for fun and laughter]].
//a[@class="local anchor"][@href="http://localhost/test.pl/2004-08-17#day_for_fun_and_laughter"][text()="2004-08-17#day for fun and laughter"]
[[[#day for fun and laughter]]].
//text()[string()="["]/following-sibling::a[@class="local anchor"][@href="#day_for_fun_and_laughter"][text()="day for fun and laughter"]/following-sibling::text()[string()="]."]
[[[2004-08-17#day for fun and laughter]]].
//a[@class="local anchor number"][@title="2004-08-17#day_for_fun_and_laughter"][@href="http://localhost/test.pl/2004-08-17#day_for_fun_and_laughter"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
[[2004-08-17#day for fun and laughter|boo]].
//a[@class="local anchor"][@href="http://localhost/test.pl/2004-08-17#day_for_fun_and_laughter"][text()="boo"]
EOT

$BracketWiki = 0;

run_tests(split('\n',<<'EOT'));
[[#day for fun and laughter|boo]].
[[#day for fun and laughter|boo]].
[[2004-08-17#day for fun and laughter|boo]].
[[2004-08-17#day for fun and laughter|boo]].
EOT
