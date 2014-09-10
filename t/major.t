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
use Test::More tests => 64;

clear_pages();

# start with minor
update_page('bar', 'one', '', 1); # lastmajor is undef
test_page(get_page('action=browse id=bar diff=1'), 'No diff available', 'one', 'Last major edit',
	  'diff=1;id=bar;diffrevision=1');
test_page(get_page('action=browse id=bar diff=2'), 'No diff available', 'one', 'Last edit');
update_page('bar', 'two', '', 1); # lastmajor is undef
test_page(get_page('action=browse id=bar diff=1'), 'No diff available', 'two', 'Last major edit',
	  'diff=1;id=bar;diffrevision=1');
test_page(get_page('action=browse id=bar diff=2'), 'one', 'two', 'Last edit');
update_page('bar', 'three'); # lastmajor is 3
test_page(get_page('action=browse id=bar diff=1'), 'two', 'three', 'Last edit');
test_page(get_page('action=browse id=bar diff=2'), 'two', 'three', 'Last edit');
update_page('bar', 'four'); # lastmajor is 4
test_page(get_page('action=browse id=bar diff=1'), 'three', 'four', 'Last edit');
test_page(get_page('action=browse id=bar diff=2'), 'three', 'four', 'Last edit');
# start with major

clear_pages();

update_page('bla', 'one'); # lastmajor is 1
test_page(get_page('action=browse id=bla diff=1'), 'No diff available', 'one', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'No diff available', 'one', 'Last edit');
update_page('bla', 'two', '', 1); # lastmajor is 1
test_page(get_page('action=browse id=bla diff=1'), 'No diff available', 'two', 'Last major edit',
	  'diff=1;id=bla;diffrevision=1');
test_page(get_page('action=browse id=bla diff=2'), 'one', 'two', 'Last edit');
update_page('bla', 'three'); # lastmajor is 3
test_page(get_page('action=browse id=bla diff=1'), 'two', 'three', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'two', 'three', 'Last edit');
update_page('bla', 'four', '', 1); # lastmajor is 3
test_page(get_page('action=browse id=bla diff=1'), 'two', 'three', 'Last major edit',
	  'diff=1;id=bla;diffrevision=3');
test_page(get_page('action=browse id=bla diff=2'), 'three', 'four', 'Last edit');
update_page('bla', 'five'); # lastmajor is 5
test_page(get_page('action=browse id=bla diff=1'), 'four', 'five', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'four', 'five', 'Last edit');
update_page('bla', 'six'); # lastmajor is 6
test_page(get_page('action=browse id=bla diff=1'), 'five', 'six', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'five', 'six', 'Last edit');
