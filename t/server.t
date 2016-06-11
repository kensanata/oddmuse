# Copyright (C) 2016  Alex Schroeder <alex@gnu.org>
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;

use Test::More tests => 4;
use LWP::UserAgent;

start_server();

# Give the child time to start
sleep 1; 

# Check whether the child is up and running
my $ua = LWP::UserAgent->new;
my $response = $ua->get("$ScriptName?action=version");
ok($response->is_success, "There is a wiki running at $ScriptName");
like($response->content, qr/Oddmuse/, "It self-identifies as Oddmuse");
ok($ua->get("$ScriptName?title=Test;text=Testing")->is_success, "Page saved");
like($ua->get("$ScriptName/Test")->content, qr/Testing/, "Content verified");
