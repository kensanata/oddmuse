# Copyright (C) 2006–2023  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 4;
use utf8;

# Reproduce a particular bug from alexschroeder.ch with the rc.log provided.
WriteStringToFile($RcFile, <<'EOT');
16853910992023-05-29_Net_newsHow to IRCAnonymousAlex2en
16854004152023-05-29_Net_newsHow to IRCAnonymousAlex3en
1685430599[[rollback]]1685400415Anonymous
16855185032023-05-29_Net_newsAnonymousAlex4en
EOT

local $SIG{ALRM} = sub { fail "timeout!"; kill 'KILL', $$; };
alarm 3;
# this is recent changes from between the rollback and the page before it, so there are no pages to roll back
my $page = get_page("action=rss full=1 short=0 from=1685413682");
alarm 0;
test_page($page, '2023-05-29 Net news');
test_page_negative($page, 'rollback');

# Reproduce a follow-up bug. First, rolling back just Test works as intended.
WriteStringToFile($RcFile, <<'EOT');
1691499987Testham127.0.0.1Berta1
1691499988Mustuff127.0.0.1Chris1
1691499989Testspam127.0.0.1Spammer2
1691499990Test0Rollback to 2023-08-08 13:06 UTC127.0.0.1Alex3
1691499990[[rollback]]1691499987Test
EOT

my $feed = get_page('action=rc raw=1 from=1691499900'); # need from or the result is empty
test_page($feed, 'title: Test');

# Rolling back all of the wiki doesn't work.
WriteStringToFile($RcFile, <<'EOT');
1691499987Testham127.0.0.1Berta1
1691499988Mustuff127.0.0.1Chris1
1691499989Testspam127.0.0.1Spammer2
1691499990Test0Rollback to 2023-08-08 13:06 UTC127.0.0.1Alex3
1691499990[[rollback]]1691499987
EOT

$feed = get_page('action=rc raw=1 from=1691499900'); # need from or the result is empty
test_page($feed, 'title: Test');
