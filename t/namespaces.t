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
use Test::More tests => 16;
clear_pages();

add_module('namespaces.pl');

test_page(get_page('Test'),
	  '<title>Wiki: Test</title>',
	  'Status: 404 NOT FOUND');
test_page(update_page('Test', 'Muuu!', 'main ns'),
	  '<p>Muuu!</p>');
test_page(get_page('action=browse id=Test ns=Muu'),
	  '<title>Wiki Muu: Test</title>',
	  'Status: 404 NOT FOUND');
test_page(update_page('Test', 'Mooo!', 'muu ns', undef, undef, 'ns=Muu'),
	  '<title>Wiki Muu: Test</title>',
	  '<p>Mooo!</p>');
test_page(get_page('action=browse id=Test ns=Muu'),
	  '<title>Wiki Muu: Test</title>',
	  '<p>Mooo!</p>');
test_page(get_page('action=browse id=Test ns=Main'),
	  '<title>Wiki: Test</title>',
	  '<p>Muuu!</p>');
test_page(get_page('action=rc raw=1'),
	  'description: main ns',
	  'description: muu ns');
test_page_negative(get_page('action=rc raw=1 local=1'),
	  'description: muu ns');
test_page(get_page('action=rc raw=1 ns=Muu'),
	  'description: muu ns');
test_page_negative(get_page('action=rc raw=1 ns=Muu'),
	  'description: main ns');
