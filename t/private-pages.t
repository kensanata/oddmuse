# Copyright (C) 2012  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 27;

clear_pages();
add_module('private-pages.pl');

# create password protected page: can't read it without password!
test_page(update_page('Privat', "#PASSWORD foo\nSo many secrets remain untold.\n"),
	  'This page is password protected');

# can't update password protected page
update_page('Privat', "#PASSWORD foo\nCats have secrets.\n");
test_page($redirect, 'Status: 403');

# use password foo to update protected page: can't read it without password!
test_page_negative(update_page('Privat', "#PASSWORD foo\nCats have secrets.\n", undef, undef, 1),
		   'Cats have secrets');
test_page($redirect, 'Status: 302');

# read it with password
my $page = get_page('action=browse id=Privat pwd=foo');
test_page_negative($page, 'This page is password protected');
test_page($page, 'Cats have secrets');

# a keep file was created as well
ok(-f GetKeepFile('Privat', 1), 'Keep file exists');

# can't read old revisions without a password
test_page_negative(get_page('action=browse id=Privat revision=1'),
		   'Cats have secrets');

# read old revisions with password
test_page(get_page('action=browse id=Privat revision=1 pwd=foo'),
	  'So many secrets remain untold');

# can't see secrets when printing raw pages
my $page = get_page('action=browse raw=1 id=Privat pwd=foo');
test_page_negative($page, 'This page is password protected');
test_page($page, 'Cats have secrets');

# can't see summaries with secrets
my $page = get_page('action=rc raw=1 all=1');
test_page($page, 'Privat');
test_page_negative($page, 'secret');

# can't search for secrets without a password
my $page = get_page('search=cats');
test_page($page, '0 pages found');
test_page_negative($page, "Privat");

# search finds secrets with password
my $page = get_page('search=cats pwd=foo');
test_page($page, '1 pages? found',
	  'Privat', '<strong>Cats</strong> have secrets');

# can't edit a private page without a password
my $page = get_page('action=edit id=Privat');
test_page($page, 'Editing not allowed');
test_page_negative($page, 'Cats have secrets');

# can edit a private page with a password
my $page = get_page('action=edit id=Privat pwd=foo');
test_page_negative($page, 'This page is password protected');
test_page($page, 'Cats have secrets');

# can't edit an old revision of a private page without a password
my $page = get_page('action=edit id=Privat revision=1');
test_page($page, 'Editing not allowed');
test_page_negative($page, 'secret');

# can't just post changes to a private page without a password
my $page = get_page('title=Privat text=YaddaYadda revision=1');
test_page($page, 'Editing not allowed');
test_page_negative($page, 'secret');

# can't include them
test_page_negative(update_page('Publik', '<include "Privat">'),
		   'Cats have secrets');
