# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More;

add_module('definition-lists.pl');

run_tests(split('\n',<<'EOT'));
this is a test\n\na test!
this is a test<p>a test!</p>
test\n: some definition
<dl><dt>test</dt><dd>some definition</dd></dl>
test\n: some definition\nand some text
<dl><dt>test</dt><dd>some definition and some text</dd></dl>
test\n: some definition\n\nbut this is not
<dl><dt>test</dt><dd>some definition</dd></dl><p>but this is not</p>
an introduction\n\ntest\n: some definition
an introduction<dl><dt>test</dt><dd>some definition</dd></dl>
test\n: some definition\nand this\n: is another definition
<dl><dt>test</dt><dd>some definition</dd><dt>and this</dt><dd>is another definition</dd></dl>
test\n: some definition\n: another definition
<dl><dt>test</dt><dd>some definition</dd><dd>another definition</dd></dl>
test\n: some definition\n\nand this\n: is another definition
<dl><dt>test</dt><dd>some definition</dd><dt>and this</dt><dd>is another definition</dd></dl>
EOT

done_testing();
