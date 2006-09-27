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
use Test::More tests => 15;
clear_pages();

# No draft button by default
test_page_negative(get_page('action=edit id=HomePage'),
		   'Save Draft');

# Adding the module adds button to edit page; no draft saved
add_module('drafts.pl');
$page = get_page('action=edit id=HomePage');
test_page($page, 'Save Draft');
test_page_negative($page, 'action=draft');

# Saving draft uses 204 No Content status
test_page(get_page('title=HomePage text=foo username=Alex Draft=1'),
	  'Status: 204');

# Visiting the main page now shows a draft available, if the username
# matches
test_page_negative(get_page('FooBar'), 'action=draft', 'Recover Draft');
test_page(get_page('action=browse id=FooBar username=Alex'),
	  'action=draft', 'Recover Draft');

# No username, no draft
test_page(get_page('action=draft'), 'No draft available to recover',
	  'Status: 404');

# Recover draft shows original content with username
test_page(get_page('action=draft username=Alex'), 'Preview', 'foo', 'HomePage');

# Another recover draft shows nothing
test_page(get_page('action=draft username=Alex'), 'No draft available to recover',
	  'Status: 404');

