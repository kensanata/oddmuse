# Copyright (C) 2006–2015  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 23;

## Test revision and diff stuff

update_page('KeptRevisions', 'first');
#sleep 120; # TODO implement fake time!
update_page('KeptRevisions', 'second', '', 0, 0, 'username=BestContributorEver');
#sleep 120; # TODO implement fake time!
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

my ($ts2) = get_page('action=browse revision=2 id=KeptRevisions') =~ /edited (.*?) diff/ix;
my ($ts3) = get_page('action=browse revision=3 id=KeptRevisions') =~ /edited (.*?) diff/ix;
ok($ts2 ne $ts3, 'Revision timestamp or author is different');

# Request the correct last major diff
xpath_test(get_page('action=browse diff=1 id=KeptRevisions'),
	   '//div[@class="diff"]/p/b[contains(text(), "Last major edit")]',
	   '//div[@class="diff"]/p/b/a[contains(text(), "later minor edits")]',
	   '//div[@class="diff"]/p/b/a[@href="http://localhost/wiki.pl?action=browse;diff=2;id=KeptRevisions;diffrevision=3"]',
	   '//div[@class="diff"]/div[@class="old"]/p/strong[contains(text(), "second")]',
	   '//div[@class="diff"]/div[@class="new"]/p/strong[contains(text(), "third")]',
	   '//div[@class="content browse"]/p[contains(text(), "fifth")]');

# Look at the remaining differences
test_page(get_page('action=browse diff=2 id=KeptRevisions diffrevision=3'),
	  'Difference between revision 3 and current revision',
	  'third',
	  'fifth');

# Show a diff from the history page comparing two specific revisions
test_page(get_page('action=browse diff=1 revision=4 diffrevision=2 id=KeptRevisions'),
	  'Difference between revision 2 and revision 4',
	  'second',
	  'fourth');

# Show no difference
update_page('KeptRevisions', 'second');
test_page(get_page('action=browse diff=1 revision=6 diffrevision=2 id=KeptRevisions'),
	  'Difference between revision 2 and current revision',
	  'The two revisions are the same');
