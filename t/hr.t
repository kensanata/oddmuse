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
use Test::More tests => 8;

clear_pages();

# without portrait-support

# nothing
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'), 'one ---- two');

# usemod only
add_module('usemod.pl');
update_page('hr', "one\n----\nthree\n");
test_page(get_page('hr'),
	  '<div class="content browse"><p>one </p><hr /><p>three</p></div>');
remove_rule(\&UsemodRule);

# headers only
add_module('headers.pl');
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'),
	  '<div class="content browse"><h3>one</h3><p>two</p></div>');

update_page('hr', "one\n\n----\nthree\n");
test_page(get_page('hr'),
	  '<div class="content browse"><p>one</p><hr /><p>three</p></div>');
remove_rule(\&HeadersRule);

# with portrait support

clear_pages();

# just portrait-support
add_module('portrait-support.pl');
update_page('hr', "[new]one\n----\ntwo\n");
test_page(get_page('hr'),
	  '<div class="content browse"><div class="color one level0"><p>one </p></div><hr /><p>two</p></div>');

# usemod and portrait-support
add_module('usemod.pl');
update_page('hr', "one\n----\nthree\n");
test_page(get_page('hr'),
	  '<div class="content browse"><p>one </p><hr /><p>three</p></div>');
remove_rule(\&UsemodRule);

# headers and portrait-support
add_module('headers.pl');
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'), '<div class="content browse"><h3>one</h3><p>two</p></div>');

update_page('hr', "one\n\n----\nthree\n");
test_page(get_page('hr'), '<div class="content browse"><p>one</p><hr /><p>three</p></div>');
