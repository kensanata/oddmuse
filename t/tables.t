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
use Test::More tests => 10;

clear_pages();

add_module('tables.pl');

InitVariables();

run_tests(split('\n',<<'EOT'));
||one||
<table class="user"><tr class="odd first"><td>one</td></tr></table>
||one|| 
<table class="user"><tr class="odd first"><td>one</td><td align="left"> </td></tr></table>
|| one two ||
<table class="user"><tr class="odd first"><td align="center">one two </td></tr></table>
introduction\n\n||one||two||three||\n||||one two||three||
introduction<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table>
||one||two||three||\n||||one two||three||\n\nfooter
<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
||one||two||three||\n||||one two||three||\n\nfooter
<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
|| one|| two|| three||\n|||| one two|| three||\n\nfooter
<table class="user"><tr class="odd first"><td align="right">one</td><td align="right">two</td><td align="right">three</td></tr><tr class="even"><td colspan="2" align="right">one two</td><td align="right">three</td></tr></table><p>footer</p>
||one ||two ||three ||\n||||one two ||three ||\n\nfooter
<table class="user"><tr class="odd first"><td align="left">one </td><td align="left">two </td><td align="left">three </td></tr><tr class="even"><td colspan="2" align="left">one two </td><td align="left">three </td></tr></table><p>footer</p>
|| one || two || three ||\n|||| one two || three ||\n\nfooter
<table class="user"><tr class="odd first"><td align="center">one </td><td align="center">two </td><td align="center">three </td></tr><tr class="even"><td colspan="2" align="center">one two </td><td align="center">three </td></tr></table><p>footer</p>
introduction\n\n||one||two||three||\n||||one two||three||\n\nfooter
introduction<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
EOT
