# Copyright (C) 2006, 2007, 2008, 2009  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 83;

clear_pages();

# First, make sure it handles empty log files and very old log files
# with nothing appropriate in them.

test_page(get_page('action=rc raw=1'), 'title: Wiki');
WriteStringToFile($RcFile, "1${FS}test${FS}${FS}test${FS}${FS}${FS}1${FS}${FS}\n");
test_page_negative(get_page('action=rc raw=1'), 'title: test');
test_page(get_page('action=rc raw=1 from=1'), 'title: Wiki', 'title: test',
	  'description: test', 'link: http://localhost/wiki.pl/test',
	  'last-modified: 1970-01-01T00:00Z', 'revision: 1');
ok(rename($RcFile, $RcOldFile), "renamed $RcFile to $RcOldFile");
test_page(get_page('action=rc raw=1 from=1'), 'title: Wiki', 'title: test',
	  'description: test', 'link: http://localhost/wiki.pl/test',
	  'last-modified: 1970-01-01T00:00Z', 'revision: 1');

# Test that newlines are in fact stripped
update_page('Newlines', 'Some text', "Summary\nwith newlines",
	    '', '', "'username=my%0aname'");
$page = get_page('action=rc raw=1');
test_page($page, 'title: Newlines',
	  'description: Summary with newlines');
test_page_negative($page, 'generator: my');

# More elaborate tests for the filters

$host1 = 'tisch';
$host2 = 'stuhl';
$ENV{'REMOTE_ADDR'} = $host1;
update_page('Mendacibombus', 'This is the place.', 'samba', 0, 0,
	    ('username=berta'));
update_page('Bombia', 'This is the time.', 'tango', 0, 0,
	    ('username=alex'));
$ENV{'REMOTE_ADDR'} = $host2;
update_page('Confusibombus', 'This is order.', 'ballet', 1, 0,
	    ('username=berta'));
update_page('Mucidobombus', 'This is chaos.', 'tarantella', 0, 0,
	    ('username=alex'));

@Positives = split('\n',<<'EOT');
for time\|place only
Mendacibombus.*samba
Bombia.*tango
EOT

@Negatives = split('\n',<<'EOT');
Confusibombus
ballet
Mucidobombus
tarantella
EOT

$page = get_page('action=rc rcfilteronly=time\|place');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella);
@Negatives = split('\n',<<'EOT');
Mendacibombus
samba
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcfilteronly=order\|chaos');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = ();
@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Mendacibombus
samba
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcfilteronly=order%20chaos');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mendacibombus.*samba Bombia.*tango);
@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Confusibombus
ballet
EOT

$page = get_page('action=rc rchostonly=tisch');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella);
@Negatives = split('\n',<<'EOT');
Confusibombus
ballet
Bombia
tango
Mendacibombus
samba
EOT

$page = get_page('action=rc rchostonly=stuhl'); # no minor edits!
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella Confusibombus.*ballet);
@Negatives = split('\n',<<'EOT');
Mendacibombus
samba
Bombia
tango
EOT

$page = get_page('action=rc rchostonly=stuhl showedit=1'); # with minor edits!
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mendacibombus.*samba);
@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcuseronly=berta');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella Bombia.*tango);
@Negatives = qw(Confusibombus ballet Mendacibombus samba);

$page = get_page('action=rc rcuseronly=alex');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Bombia.*tango);
@Negatives = qw(Mucidobombus tarantella Confusibombus ballet
		Mendacibombus samba);

$page = get_page('action=rc rcidonly=Bombia');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

update_page('Mucidobombus', 'This is limbo.', 'flamenco');
$page = get_page('action=rc');
test_page($page, 'flamenco');
test_page_negative($page, 'tarantella');
$page = get_page('action=rc all=1');
test_page($page, 'flamenco');
test_page($page, 'tarantella');
