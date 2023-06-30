# Copyright (C) 2006–2021  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 2;
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
my $page = get_page("action=rss full=1 short=0 from=1685413682");
alarm 0;
test_page($page, '2023-05-29 Net news');
test_page_negative($page, 'rollback');
