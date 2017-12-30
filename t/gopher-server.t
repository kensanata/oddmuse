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

package OddMuse;
use strict;
use 5.10.0;
use Test::More;
use Socket;
use utf8; # tests contain UTF-8 characters and it matters

require './t/test.pl';

add_module('tags.pl');

our($DataDir, $ConfigFile);

my $port = random_port();

my $pid = fork();

END {
  # kill server
  if ($pid) {
    kill 'KILL', $pid or warn "Could not kill server $pid";
  }  
}

if (!defined $pid) {
  die "Cannot fork: $!";
} elsif ($pid == 0) {
  use Config;
  my $secure_perl_path = $Config{perlpath};
  exec($secure_perl_path,
       "stuff/gopher-server.pl",
       "--port=localhost:$port",
       "--pid_file=$DataDir/gopher-server.pid",
       "--log_level=0", # set  to 2 for logging
       "--wiki=./wiki.pl",
       "--wiki_dir=$DataDir",
       "--wiki_pages=Alex",
       "--wiki_pages=Berta",
       "--wiki_pages=Chris")
      or die "Cannot exec: $!";
}

# create some pages while the server is starting
update_page('Alex', "My best friend is [[Berta]].\n\nTags: [[tag:Friends]]\n");
update_page('Berta', "This is me.\n\nTags: [[tag:Friends]]\n");
update_page('Chris', "I'm Chris.\n\nTags: [[tag:Friends]]\n");
update_page('Friends', "Some friends.\n");
update_page('2017-12-25', 'It was a Monday.\n\nTags: [[tag:Day]]');
update_page('2017-12-26', 'It was a Tuesday.\n\nTags: [[tag:Day]]');
update_page('2017-12-27', 'It was a Wednesday.\n\nTags: [[tag:Day]]');
update_page('Friends', "News about friends.\n", 'rewrite', 1); # minor change
update_page('Friends', "News about friends:\n\n<journal search tag:friends>\n", 'add journal tag', 1); # minor change

# enable uploads
AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");
update_page('Picture', "#FILE image/png\niVBORw0KGgoAAAA");

sub query_gopher {
  my $query = shift;

  # create client
  socket(my $socket,PF_INET,SOCK_STREAM,(getprotobyname('tcp'))[2]);
  connect($socket, pack_sockaddr_in($port, inet_aton("localhost")))
      or die "Can't connect to gopher-server on localhost:$port\n";
  $socket->autoflush(1);

  print $socket "$query\r\n";

  undef $/; # slurp
  return <$socket>;
}

# main menu
my $page = query_gopher("");
for my $item(qw(Alex Berta Chris 2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^1$item\t$item\/menu\t/m, "main menu contains $item");
}

# page menu
$page = query_gopher("Alex/menu");
like($page, qr/^0Alex\tAlex\t/m, "Alex menu links to plain text");
like($page, qr/^hAlex\tAlex\/html\t/m, "Alex menu links to HTML");
like($page, qr/^1Page History\tAlex\/history\t/m, "Alex menu links to page history");
like($page, qr/^1Berta\tBerta\/menu\t/m, "Alex menu links to Berta menu");
like($page, qr/^1Friends\tFriends\/tag\t/m, "Alex menu links to Friends tag");

# plain text
$page = query_gopher("Alex");
like($page, qr/^My best friend is \[\[Berta\]\]/, "Alex plain text");

# HTML
$page = query_gopher("Alex/html");
like($page, qr/^<p>My best friend is <a.*?>Berta<\/a>/, "Alex HTML");

# tags
$page = query_gopher("Friends/tag");
like($page, qr/iThis page is about the tag Friends/, "tag menu intro");
for my $item(qw(Friends Alex Berta Chris)) {
  like($page, qr/^1$item\t$item\/menu\t/m, "tag menu contains $item");
}

# tags
$page = query_gopher("Day/tag");
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s, "tag menu sorted newest first");

# match
$page = query_gopher("do/match\t2017");
for my $item(qw(2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^1$item\t$item\/menu\t/m, "match menu contains $item");
}
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s, "match menu sorted newest first");

# search
$page = query_gopher("do/search\ttag:day");
for my $item(qw(2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^1$item\t$item\/menu\t/m, "serch menu contains $item");
}
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s, "search menu sorted newest first");

# rc
$page = query_gopher("do/rc");
like($page, qr/Picture.*2017-12-27.*2017-12-26.*2017-12-25.*Friends.*Chris.*Berta.*Alex/s, "rc in the right order");

$page = query_gopher("do/rc/showedits");
like($page, qr/Friends.*2017-12-27.*2017-12-26.*2017-12-25.*Chris.*Berta.*Alex/s, "rc in the right order");

# history
$page = query_gopher("Friends/history");
like($page, qr/^1Friends \(1\)\tFriends\/1\/menu\t/m, "Friends (1)");
like($page, qr/^1Friends \(2\)\tFriends\/2\/menu\t/m, "Friends (2)");
like($page, qr/^1Friends \(current\)\tFriends\/menu\t/m, "Friends (current)");
like($page, qr/Friends\/menu.*Friends\/2\/menu.*Friends\/1\/menu/s, "history in the right order");

# revision menu
$page = query_gopher("Friends/1/menu");
like($page, qr/^0Friends\tFriends\/1\t/m, "Friends/1 menu links to plain text");
like($page, qr/^hFriends\tFriends\/1\/html\t/m, "Friends/1 menu links to HTML");
unlike($page, qr/Search result for tag/, "Friends/1 has no journal and thus no tag search");

# revision plain text
$page = query_gopher("Friends/1");
like($page, qr/^Some friends/m, "Friends/1 plain text");

# revision html
$page = query_gopher("Friends/1/html");
like($page, qr/^<p>Some friends/m, "Friends/1 html");

# uploaded images

done_testing();
