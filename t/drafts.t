# Copyright (C) 2006, 2012  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 26;
use utf8;

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

# Saving second draft
get_page('title=HomePage text=foo username=Alex Draft=1');
get_page('title=HomePage text=foo username=.berta Draft=1');

# Ordinary maintenance deletes nothing
$page = get_page('action=maintain');
test_page($page, 'was kept');
test_page_negative($page, 'was deleted');

# Date back one file
utime($Now-1300000, $Now-1300000, "$DraftDir/.berta");
# Second maintenance requires admin password and deletes one draft
$page = get_page('action=maintain pwd=foo');
test_page($page, 'Alex was last modified [^<>]* and was kept');
test_page($page, '.berta was last modified [^<>]* and was deleted');
ok(-f "$DraftDir/Alex", "$DraftDir/Alex is still there");
ok(! -f "$DraftDir/.berta", "$DraftDir/.berta is gone");

# Date back the other file
utime($Now-1300000, $Now-1300000, "$DraftDir/Alex");

# Second maintenance requires admin password and deletes one draft
test_page(get_page('action=maintain pwd=foo'), 'Alex was last modified [^<>]* ago and was deleted');
ok(! -f "$DraftDir/.berta", "$DraftDir/Alex is gone");

# Testing UTF-8
# Saving draft uses 204 No Content status
test_page(get_page('title=HomePage text=foo username=Schröder Draft=1'),
	 'Status: 204', 'username%251eSchr%C3%B6der');
test_page(get_page('action=maintain pwd=foo'),
	  'Schröder was last modified [^<>]* and was kept');
