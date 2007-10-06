# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

add_module('strange-spam.pl');

update_page('StrangeBannedContent', "XXX\n", undef, undef, 1);
test_page(update_page('pr0n', 'some XXX movies'),
	  'This page is empty');
test_page($redirect,
	  'banned text', 'wiki administrator', 'matched',
	  'See .*BannedContent.* for more information',
	  'Reason unknown');
test_page(update_page('pr0n', 'some XXX movies', undef, undef, 1),
	  'some XXX movies');

add_module('despam.pl');

test_page(get_page('action=spam'), 'pr0n');
test_page(get_page('action=despam'), 'pr0n.*Marked as DeletedPage');
test_page_negative(get_page('action=spam'), 'pr0n');
