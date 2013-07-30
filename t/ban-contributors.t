# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 7;

clear_pages();

add_module('ban-contributors.pl');
$localhost = 'pyrobombus';
$ENV{'REMOTE_ADDR'} = $localhost;

update_page('Test', 'insults');
test_page_negative(get_page('action=admin id=Test'), 'Ban contributors');
test_page(get_page('action=admin id=Test pwd=foo'), 'Ban contributors');
test_page(get_page('action=ban id=Test pwd=foo'), 'pyrobombus', 'Ban!');
test_page(get_page('action=ban id=Test host=pyrobombus pwd=foo'),
	  'Location: http://localhost/wiki.pl/BannedHosts');
test_page(get_page('BannedHosts'), 'pyrobombus', 'Test');
