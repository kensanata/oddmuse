# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 5;

add_module('checkbox.pl');

my $text = q{
There's some stuff I want to work on:

[[ :something to do]]
[[x:something done]]
[[save:update the list]]

Let's do this!
};

$page = update_page('TODO', $text, 'saving it');

xpath_test(
  $page,
  '//p[text()="There\'s some stuff I want to work on:"]',
  '//form[@class="checkboxes"]/p/label/input[@type="checkbox"][@name="something_to_do"]/following-sibling::text()[string()="something to do"]',
  '//form[@class="checkboxes"]/p/label/input[@type="checkbox"][@name="something_done"][@checked="checked"]/following-sibling::text()[string()="something done"]',
  '//form[@class="checkboxes"]/p/input[@type="submit"][@name="update the list"]',
  '//p[text()="Let\'s do this!"]',);
