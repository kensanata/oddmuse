# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 13;
use LWP::UserAgent;
use RPC::XML::Client;
use RPC::XML;

add_module('pingback-server.pl');
AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments_on_';\n");

# This test is is going to use two servers in addition to this script, but in
# actual fact we are all going to share the data directory.

test_page(update_page('Target', 'This is the test page.'), 'This is the test page');

# Server 1 is going to be the pingback server.

start_server();

# Check whether the child is up and running
my $ua = LWP::UserAgent->new;
my $response = $ua->get("$ScriptName?action=version");
ok($response->is_success, "There is a wiki running at $ScriptName");
like($response->decoded_content, qr/\bpingback-server\.pl/, "The server has the pingback-server extension installed");

# Now that we have the pingback server running, we need to get the URL of the
# test page, including its port.

my $target_url = ScriptUrl('Target');
my $pingback_url = ScriptUrl('pingback/Target');

# Verify that the target exists via external request
$response = $ua->get($target_url);
ok($response->is_success, "Target URL response");
like($response->decoded_content, qr/This is the test page/, "Target URL decoded");

# Create the Source page before starting the next server (so that it knows about
# the new page)
test_page(update_page('Source', "Link to $target_url"), 'Link to');

# Server 2 is going to be the source server.
start_server(2);

# Check whether the child is up and running (with a new $ScriptName!)
$response = $ua->get("$ScriptName?action=version");
ok($response->is_success, "There is a wiki running at $ScriptName");

# New script name means we can now get the source_url.
my $source_url = ScriptUrl('Source');

# Verify that the source exists via external request
$response = $ua->get($source_url);
ok($response->is_success, "Source URL response");
like($response->decoded_content, qr/Link to/, "Source URL decoded");
like($response->decoded_content, qr/$target_url/, "Source page links to Target page");

my $client = RPC::XML::Client->new($pingback_url);
my $source = RPC::XML::string->new($source_url);
my $target = RPC::XML::string->new($target_url);
my $request = RPC::XML::request->new('pingback.ping', $source, $target);
my $response = $client->send_request($request);

ok(ref($response), 'Got a response reference');

test_page(get_page('Comments_on_Target'),
	  'Pingback:',
	  $source_url);
