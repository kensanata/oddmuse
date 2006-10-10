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
use Test::More tests => 4;

clear_pages();

update_page('.dotfile', 'old content', 'older summary');
update_page('.dotfile', 'some content', 'some summary');
test_page(get_page('.dotfile'), 'some content');
test_page(get_page('action=browse id=.dotfile revision=1'), 'old content');
test_page(get_page('action=history id=.dotfile'), 'older summary', 'some summary');
