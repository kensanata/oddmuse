# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
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
use utf8;
use Test::More tests => 2;
clear_pages();
add_module('google-plus-one.pl');

# Unfortunately, we cannot test Javascript! For now, test that it runs and that
# the admin action exists.

test_page(get_page('action=admin'),
          'Google \+1 Buttons');
test_page(get_page('action=plusone'),
          'All Pages \+1');
