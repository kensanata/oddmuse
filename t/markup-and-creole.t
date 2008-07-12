# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 5;
clear_pages();

add_module('creole.pl');
add_module('markup.pl');
InitVariables(); # need to call MarkupInit!

run_tests(split('\n',<<'EOT'));
* foo
<ul><li>foo</li></ul>
*foo* bar
<b>foo</b> bar
* foo *bar*
<ul><li>foo <b>bar</b></li></ul>
*foo bar*
<b>foo bar</b>
*foo *bar*
<ul><li>foo <b>bar</b></li></ul>
EOT
