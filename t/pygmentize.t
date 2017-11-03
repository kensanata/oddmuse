# Copyright (C) 2015-2016  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require './t/test.pl';
package OddMuse;
use Test::More tests => 2;

add_module('pygmentize.pl');

 SKIP: {
   if (qx(pygmentize -V) !~ /Pygments version/) {
     skip "pygmentize not found", 2;
   }

   $ENV{PATH} = '.'; # pygmentize is not installed in the current directory
   $page = apply_rules(newlines('{{{\ntest\n}}}\n'));
   test_page($page,
	     '\bsh\b.*\bpygmentize\b.*\bnot found\b',
	     '<pre>test</pre>');
}
