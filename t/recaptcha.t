# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 5;
use utf8; # test data is UTF-8 and it matters

clear_pages();
$ENV{'REMOTE_ADDR'}='127.0.0.1';
add_module('recaptcha.pl');

# The recaptcha module used to corrupt UTF-8 encoding and HTML
# escaping.

# non-existing page and no permission
test_page(get_page('title=SandBox text="<b>K%C3%BChlschrank</b>"'),
	  'Status: 403',
	  '&lt;b&gt;Kühlschrank&lt;/b&gt;');
# update it as an admin
test_page(update_page('SandBox', '<b>Kühlschrank</b>', undef, undef, 1),
	  '&lt;b&gt;Kühlschrank&lt;/b&gt;');
# existing page and no permission
test_page(get_page('title=SandBox text="<b>K%C3%BChlschrank-test</b>"'),
	  'Status: 403',
	  '&lt;b&gt;Kühlschrank-test&lt;/b&gt;');
