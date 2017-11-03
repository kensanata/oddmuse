# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 6;
use utf8;

# This is a page whose HTML will change when we install the Markup Extension.
test_page(update_page('Test', 'This is *bold*.'), '\*bold\*');

# This is a page whose HTML will not change.
update_page('Boring', 'This is just text.');

# New markup module installed but HTML returned is cached.
add_module('markup.pl');
test_page(get_page('Test'), '\*bold\*');

# We can get the new HTML using cache=0.
test_page(get_page('Test?cache=0'), '<b>bold</b>');

# Install Preview Extension.
add_module('preview.pl');
test_page(get_page('action=admin'), 'action=preview');

# See whether Test is listed and Boring is not.
$page = get_page('action=preview');
test_page($page, 'Test');
test_page_negative($page, 'Boring');
