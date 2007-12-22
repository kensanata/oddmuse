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
use Test::More tests => 18;

clear_pages();

# Create a sample page, and test for regular expressions in the output

$page = update_page('SandBox', 'This is a test.', 'first test');
test_page($page, 'SandBox', 'This is a test.');
xpath_test($page, '//h1/a[@title="Click to search for references to this page"][@href="http://localhost/wiki.pl?search=%22SandBox%22"][text()="SandBox"]');

# Test RecentChanges

test_page(get_page('action=rc'), 'RecentChanges', 'first test');

# Updated the page

test_page(update_page('SandBox', 'This is another test.', 'second test'),
	  'RecentChanges', 'This is another test.');

# Test RecentChanges

test_page(get_page('action=rc'), 'RecentChanges', 'second test');

# Attempt to create InterMap page as normal user

test_page(update_page('InterMap',
		      " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n",
		      'required'),
	  'This page is empty');

# Create InterMap page as admin

test_page(update_page('InterMap',
		      " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n PlanetMath http://planetmath.org/encyclopedia/%s.html",
		      'required', 0, 1),
	  split('\n',<<'EOT'));
OddMuse
http://www\.emacswiki\.org/cgi-bin/oddmuse\.pl
PlanetMath
http://planetmath\.org/encyclopedia/\%s\.html
EOT

# Verify the InterMap stayed locked

test_page(update_page('InterMap', "All your edits are blong to us!\n",
		      'required'),
	  'OddMuse');

# Try to unlock the InterMap page as ordinary user

test_page(get_page('action=pagelock set=0 id=InterMap'),
	  'This operation is restricted to administrators');

# Unlock the InterMap page as admin

test_page(get_page('action=pagelock set=0 id=InterMap pwd=foo'),
	  'Lock for .*InterMap.* removed');

# # Attempt to create InterMap page as normal user

test_page(update_page('InterMap',
		      " Wikipedia http://de.wikipedia.org/wiki/\n"),
	  'Wikipedia');
