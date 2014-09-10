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

## Test revision and diff stuff

update_page('KeptRevisions', 'first');
update_page('KeptRevisions', 'second');
update_page('KeptRevisions', 'third');
update_page('KeptRevisions', 'fourth', '', 1);
update_page('KeptRevisions', 'fifth', '', 1);

# Show the current revision

test_page(get_page(KeptRevisions),
	  'KeptRevisions',
	  'fifth');

# Show the other revision

test_page(get_page('action=browse revision=2 id=KeptRevisions'),
	  'Showing revision 2',
	  'second');

test_page(get_page('action=browse revision=1 id=KeptRevisions'),
	 'Showing revision 1',
	  'first');

# Show the current revision if an inexisting revision is asked for

test_page(get_page('action=browse revision=9 id=KeptRevisions'),
	  'Revision 9 not available \(showing current revision instead\)',
	  'fifth');

# Disable cache and request the correct last major diff
test_page(get_page('action=browse diff=1 id=KeptRevisions cache=0'),
	  'Difference between revision 2 and revision 3',
	  'second',
	  'third');

# Show a diff from the history page comparing two specific revisions
test_page(get_page('action=browse diff=1 revision=4 diffrevision=2 id=KeptRevisions'),
	  'Difference between revision 2 and revision 4',
	  'second',
	  'fourth');

# Show no difference
update_page('KeptRevisions', 'second');
test_page(get_page('action=browse diff=1 revision=6 diffrevision=2 id=KeptRevisions'),
	  'Difference between revision 2 and revision 6',
	  'The two revisions are the same');
