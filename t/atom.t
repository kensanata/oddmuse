# Copyright (C) 2006–2015  Alex Schroeder <alex@gnu.org>
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

use Test::More tests => 44;
use LWP::UserAgent;
use XML::Atom::Client;
use XML::Atom::Entry;
use XML::Atom::Person;

sub random_port {
  use Errno  qw( EADDRINUSE );
  use Socket qw( PF_INET SOCK_STREAM INADDR_ANY sockaddr_in );
  
  my $family = PF_INET;
  my $type   = SOCK_STREAM;
  my $proto  = getprotobyname('tcp')  or die "getprotobyname: $!";
  my $host   = INADDR_ANY;  # Use inet_aton for a specific interface

  for my $i (1..3) {
    my $port   = 1024 + int(rand(65535 - 1024));
    socket(my $sock, $family, $type, $proto) or die "socket: $!";
    my $name = sockaddr_in($port, $host)     or die "sockaddr_in: $!";
    setsockopt($sock, SOL_SOCKET, SO_REUSEADDR, 1);
    bind($sock, $name)
	and close($sock)
	and return $port;
    die "bind: $!" if $! != EADDRINUSE;
    print "Port $port in use, retrying...\n";
  }
  die "Tried 3 random ports and failed.\n"
}

my $port = random_port();
$ScriptName = "http://localhost:$port";

AppendStringToFile($ConfigFile, "\$ScriptName = $ScriptName;\n");

add_module('atom.pl');

# Fork a test server with the new config file and the module
my $pid = fork();
if (!defined $pid) {
  die "Cannot fork: $!";
} elsif ($pid == 0) {
  use Config;
  my $secure_perl_path = $Config{perlpath};
  exec($secure_perl_path, "stuff/server.pl", "wiki.pl", $port) or die "Cannot exec: $!";
}

# Give the child time to start
sleep 1; 

# Check whether the child is up and running
my $ua = LWP::UserAgent->new;
my $response = $ua->get("$ScriptName?action=version");
ok($response->is_success, "There is a wiki running at $ScriptName");
like($response->content, qr/\batom\.pl/, "The  has the atom extension installed");

# Testing the Atom API
my $api = XML::Atom::Client->new;
my $entry = XML::Atom::Entry->new;
my $title = 'New Post';
my $summary = 'Created';
my $content = 'Content of my post ' . rand(999) . "\n";
my $username = 'Alex';
ok($entry->title($title), 'set post title');
ok($entry->summary($summary), 'set post summary');
ok($entry->content($content), 'set post content');
my $author = XML::Atom::Person->new;
ok($author->name($username), 'set author name');
ok($entry->author($author), 'set entry author');
my $PostURI = "$ScriptName/atom";
my $MemberURI = $api->createEntry($PostURI, $entry);
ok($MemberURI, "posting entry returns member URI $MemberURI")
    or diag($api->errstr);

my $result = $api->getEntry($MemberURI);
ok($result, 'get created entry')
    or diag($api->errstr);
ok($result->title eq $title, 'verify title');
ok($result->summary eq $summary, 'verify summary');
ok($result->content->body eq $content, 'verify content');
ok($result->author->name eq $username, 'verify author');
$MemberURI = '';
my @links = ($result->link);
ok($#links >= 0, 'verify link');
for my $link (@links) {
  if ($link->rel eq 'edit') {
    $MemberURI = $link->href;
    last;
  }
}
ok($MemberURI, "entry contains member URI $MemberURI");

$summary = 'Updated';
$content = "No more random numbers!\n";
ok($entry->summary($summary), 'change summary');
ok($entry->content($content), 'change content');
ok($api->updateEntry($MemberURI, $entry), 'update entry')
    or diag($api->errstr);

$result = $api->getEntry($MemberURI);
ok($result, 'get updated entry')
    or diag($api->errstr);
ok($result->title eq $title, 'verify title');
ok($result->summary eq $summary, 'verify summary');
ok($result->content->body eq $content, 'verify content');
ok($result->author->name eq $username, 'verify author');

my $new_title = 'Same old post';
ok($entry->title($new_title), 'rename entry');
ok($api->updateEntry($MemberURI, $entry), 'post renamed entry')
    or diag($api->errstr);

$result = $api->getEntry($MemberURI);
ok($result, 'get renamed old entry')
    or diag($api->errstr);

ok($result->title eq $title, 'verify title');
ok($result->summary eq "Renamed to $new_title", 'verify summary');
ok($result->content->body eq 'DeletedPage', 'verify deleted page');
ok($result->author->name eq $username, 'verify author');

my $FeedURI = "$ScriptName/atom/feed";
my $feed = $api->getFeed($FeedURI);
ok($feed, 'checking feed');
my @entries = $feed->entries;
ok($#entries >= 1, 'verify feed entries'); # at least 2, start at 0
$result = undef;
for $entry (@entries) {
  if ($entry->author and $entry->author->name eq $username
      and $entry->title eq $new_title) {
    $result = $entry;
    last;
  }
}
ok($result, 'result found in the feed');
ok($result->title eq $new_title, 'verify title');
ok($result->summary eq $summary, 'verify summary');
ok(!$result->content, 'no content in the default feed');
ok($result->author->name eq $username, 'verify author');

$FeedURI = "$ScriptName/atom/full/feed?rsslimit=2";
my $feed = $api->getFeed($FeedURI);
ok($feed, 'checking full feed');
my @entries = $feed->entries;
ok($#entries >= 1, 'verify full feed entries'); # at least 2, start at 0
$result = undef;
for $entry (@entries) {
  if ($entry->author and $entry->author->name eq $username
      and $entry->title eq $new_title) {
    $result = $entry;
    last;
  }
}
ok($result, 'result found in the full feed');
ok($result->title eq $new_title, 'verify title');
ok($result->summary eq $summary, 'verify summary');
sub trim {
  $_ = shift;
  s/^\s+//g;
  s/\s+$//g;
  return $_;
}
ok(trim($result->content->body) eq ("<p>" . trim($content) . '</p>'), 'verify content');
ok($result->author->name eq $username, 'verify author');

END {
  # kill server
  kill 'KILL', $pid;
}
