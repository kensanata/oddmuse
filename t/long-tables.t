# Copyright (C) 2006, 2007, 2008  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 23;
clear_pages();

add_module('tables-long.pl');

test_page(update_page('2008-10-26', "<table a,b>\na=alex\nb=berta\na=one\nb=two"),
	  '<th>alex</th>', '<th>berta</th>', '<td>one</td>', '<td>two</td>');
test_page(update_page('Diary', "This is the land of the crab-men.\n\n<journal>"),
	  'This is the land of the crab-men.',
	  '<th>alex</th>', '<th>berta</th>', '<td>one</td>', '<td>two</td>');

run_tests(split('\n',<<'EOT'));
<table a,b>\na=a\nb=b\na=one\nb=two
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td>two</td></tr></table>
<table a,b>\na=a\nb=b\na=one\nb=two\n----
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td>two</td></tr></table>
<table a,b>\na=a\nb=b\na=one\nb=two\n----\n\nDone.
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td>two</td></tr></table><p>Done.</p>
Here is a table:\n<table a,b>\na=a\nb=b\na=one\ntwo\nand a half\nb=three\na=foo\nb=bar\n----\n\nDone.\n<table foo,bar>\nfoo=test\nbar=test as well\nfoo=what we test\n----\nthe end.
Here is a table: <table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one two and a half</td><td>three</td></tr><tr><td>foo</td><td>bar</td></tr></table><p>Done. </p><table class="user long"><tr><th>test</th><th>test as well</th></tr><tr><td colspan="2">what we test</td></tr></table><p>the end.</p>
<table a,b>\na=a\nb=b\na=one\nb/2=odd\na=three
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td rowspan="2">odd</td></tr><tr><td>three</td></tr></table>
<table a,b,c>\na=a\nb=b\nc=c\na=one\nb/2=odd\nc=two\na=three\nc=four
<table class="user long"><tr><th>a</th><th>b</th><th>c</th></tr><tr><td>one</td><td rowspan="2">odd</td><td>two</td></tr><tr><td>three</td><td>four</td></tr></table>
<table a,b,c>\na=a\nb=b\nc=c\na=one\nb=two\nc/2=numbers\na=three\n
<table class="user long"><tr><th>a</th><th>b</th><th>c</th></tr><tr><td>one</td><td>two</td><td rowspan="2">numbers</td></tr><tr><td colspan="2">three</td></tr></table>
<table a, b, c>\na:0\nb:1\nc:00\n----\n
<table class="user long"><tr><th>0</th><th>1</th><th>00</th></tr></table>
EOT

add_module('portrait-support.pl');

xpath_test(update_page('portrait', "[new]\nparagraph\n<table a, b>\n"
		       . "a: first heading\n" . "b: second heading\n"
		       . "a: first cell\n" . "b: second cell\n"
		       . "----\n"
		       . "new paragraph"),
	   '//p[text()=" paragraph "]',
	   '//table/tr/th[text()="first heading"]',
	   '//table/tr/th[text()="second heading"]',
	   '//table/tr/td[text()="first cell"]',
	   '//table/tr/td[text()="second cell"]',
	   '//p[text()="new paragraph"]', );
