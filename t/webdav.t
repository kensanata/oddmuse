# Copyright (C) 2017  Alex Schroeder <alex@gnu.org>
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

use Test::More tests => 7;
use LWP::UserAgent;

add_module('webdav.pl');

start_mojolicious_server();

# Give the child time to start
sleep 1;

# Check whether the child is up and running
my $ua = LWP::UserAgent->new;
my $response = $ua->get("$ScriptName?action=version");
ok($response->is_success, "There is a wiki running at $ScriptName");
like($response->content, qr/\bwebdav\.pl/, "The server has the WebDAV extension installed");

use HTTP::Request;
my $request = HTTP::Request->new(OPTIONS => "$ScriptName/dav/");
$response = $ua->request($request);
ok($response->is_success, "WebDAV response coming from $ScriptName");
ok($response->header('DAV'), "DAV header is set");
ok($response->header('allow'), "Allow header is set: " . $response->header('allow'));

SKIP: {
  $ENV{PATH} .= ':/usr/local/bin'; # maybe cadaver is installed locally
  if (qx'cadaver --version' !~ /^cadaver \d+\.\d+.\d+/, ) {
    skip("Cadaver is not installed", 2);
  }

  like(qx"echo ls | cadaver $ScriptName/dav/",
       qr/^Listing collection `\/wiki\/dav\/': collection is empty\./m,
       "ls");

  open(my $fh, ">", "$TempDir/foo") or die "Cannot write $TempDir/foo: $!";
  print $fh "this is a test\n";
  close($fh);

  like(qx"echo put $TempDir/foo | cadaver $ScriptName/dav/",
       qr/^Uploading $TempDir\/foo to `\/wiki\/dav\/foo'/m,
       "put");
}
