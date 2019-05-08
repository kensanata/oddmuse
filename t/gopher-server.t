# Copyright (C) 2017–2019  Alex Schroeder <alex@gnu.org>
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
use IO::Socket::IP;
use utf8; # tests contain UTF-8 characters and it matters

require './t/test.pl';

add_module('tags.pl');

# enable uploads
our($ConfigFile);
AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");

my $port = random_port();
my $pid = fork();

END {
  # kill server
  if ($pid) {
    kill 'KILL', $pid or warn "Could not kill server $pid";
  }
}

our ($DataDir);
if (!defined $pid) {
  die "Cannot fork: $!";
} elsif ($pid == 0) {
  use Config;
  my $secure_perl_path = $Config{perlpath};
  exec($secure_perl_path,
       "stuff/gopher-server.pl",
       "--port=$port",
       "--log_level=0", # set to 4 for verbose logging
       "--wiki=./wiki.pl",
       "--wiki_dir=$DataDir",
       "--wiki_pages=Alex",
       "--wiki_pages=Berta",
       "--wiki_pages=Chris")
      or die "Cannot exec: $!";
}

update_page('Alex', "My best friend is [[Berta]].\n\nTags: [[tag:Friends]]\n");
update_page('Berta', "This is me.\n\nTags: [[tag:Friends]]\n");
update_page('Chris', "I'm Chris.\n\nTags: [[tag:Friends]]\n");
update_page('Friends', "Some friends.\n");
update_page('2017-12-25', 'It was a Monday.\n\nTags: [[tag:Day]]');
update_page('2017-12-26', 'It was a Tuesday.\n\nTags: [[tag:Day]]');
update_page('2017-12-27', 'It was a Wednesday.\n\nTags: [[tag:Day]]');
update_page('Friends', "News about friends.\n", 'rewrite', 1); # minor change
update_page('Friends', "News about friends:\n\n<journal search tag:friends>\n",
	    'add journal tag', 1); # minor change

# file created using convert NULL: test.png && base64 test.png
update_page('Picture',
	    "#FILE image/png\niVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQAAAAA3bv"
	    . "kkAAAACklEQVQI12NoAAAAggCB3UNq9AAAAABJRU5ErkJggg==");

sub query_gopher {
  my $query = shift;
  my $text = shift;

  # create client
  my $socket = IO::Socket::IP->new(
    PeerHost => "localhost",
    PeerPort => $port,
    Type     => SOCK_STREAM, )
      or die "Cannot construct client socket: $@";

  $socket->print("$query\r\n");
  $socket->print($text);

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
like($page, qr/^0Alex\tAlex\t/m,
     "Alex menu links to plain text");
like($page, qr/^hAlex\tAlex\/html\t/m,
     "Alex menu links to HTML");
like($page, qr/^1Page History\tAlex\/history\t/m,
     "Alex menu links to page history");
like($page, qr/^1Berta\tBerta\/menu\t/m,
     "Alex menu links to Berta menu");
like($page, qr/^1Friends\tFriends\/tag\t/m,
     "Alex menu links to Friends tag");

# plain text
$page = query_gopher("Alex");
like($page, qr/^My best friend is \[\[Berta\]\]/, "Alex plain text");

# HTML
$page = query_gopher("Alex/html");
like($page, qr/<p>My best friend is <a.*?>Berta<\/a>/, "Alex HTML");

# tags
$page = query_gopher("Friends/tag");
like($page, qr/iThis page is about the tag Friends/, "tag menu intro");
for my $item(qw(Friends Alex Berta Chris)) {
  like($page, qr/^1$item\t$item\/menu\t/m, "tag menu contains $item");
}

# tags
$page = query_gopher("Day/tag");
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s,
     "tag menu sorted newest first");

# match
$page = query_gopher("do/match\t2017");
for my $item(qw(2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^1$item\t$item\/menu\t/m, "match menu contains $item");
}
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s,
     "match menu sorted newest first");

# search
$page = query_gopher("do/search\ttag:day");
for my $item(qw(2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^1$item\t$item\/menu\t/m, "serch menu contains $item");
}
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s,
     "search menu sorted newest first");

# rc
$page = query_gopher("do/rc");
my $re = join(".*", "Picture", "2017-12-27", "2017-12-26", "2017-12-25",
	      "Friends", "Chris", "Berta", "Alex");
like($page, qr/$re/s, "rc in the right order");

$page = query_gopher("do/rc/showedits");

$re = join(".*", "Friends", "2017-12-27", "2017-12-26", "2017-12-25");
like($page, qr/$re/s, "rc in the right order");

# history
$page = query_gopher("Friends/history");
like($page, qr/^1Friends \(1\)\tFriends\/1\/menu\t/m,
     "Friends (1)");
like($page, qr/^1Friends \(2\)\tFriends\/2\/menu\t/m,
     "Friends (2)");
like($page, qr/^1Friends \(current\)\tFriends\/menu\t/m,
     "Friends (current)");
like($page, qr/Friends\/menu.*Friends\/2\/menu.*Friends\/1\/menu/s,
     "history in the right order");

# revision menu
$page = query_gopher("Friends/1/menu");
like($page, qr/^0Friends\tFriends\/1\t/m,
     "Friends/1 menu links to plain text");
like($page, qr/^hFriends\tFriends\/1\/html\t/m,
     "Friends/1 menu links to HTML");
unlike($page, qr/Search result for tag/,
       "Friends/1 has no journal and thus no tag search");

# revision plain text
$page = query_gopher("Friends/1");
like($page, qr/^Some friends/m, "Friends/1 plain text");

# revision html
$page = query_gopher("Friends/1/html");
like($page, qr/<p>Some friends/m, "Friends/1 html");

# upload text
my $haiku = <<EOT;
Quiet disk ratling
Keyboard clicking, then it stops.
Rain falls and I think
.
EOT

$page = query_gopher("Haiku/write/text", "$haiku");
like($page, qr/^iPage was saved./m, "Write Haiku");
like($page, qr/^1Haiku\tHaiku\/menu/m, "Link back to Haiku");

my $haiku_re = quotemeta(substr($haiku, 0, -2)); # strip period and \n
$page = query_gopher("Haiku");
like($page, qr/^$haiku_re/, "Haiku saved");

$haiku = <<"EOT";
```
username: Alex
minor: 1
summary: typos
```
Quiet disk rattling
Keyboard clicking, then it stops.
Rain falls and I think.
.
EOT

$page = query_gopher("Haiku/write/text", "$haiku");
like($page, qr/^iPage was saved./m, "Write haiku");

$haiku_re = quotemeta(<<"EOT");
Quiet disk rattling
Keyboard clicking, then it stops.
Rain falls and I think.
EOT

$page = query_gopher("Haiku");
like($page, qr/^$haiku_re/, "Haiku updated");

$page = query_gopher("Haiku/history");
like($page, qr/^1Haiku \(current\)\tHaiku\/menu\t/m, "Haiku (current)");
like($page, qr/^i\d\d:\d\d UTC by Alex: typos \(minor\)/m,
     "Metadata recorded");
like($page, qr/^1Haiku \(1\)\tHaiku\/1\/menu\t/m, "Haiku (1)");

# new page
$page = query_gopher("do/new", <<"EOT");
```
username: Alex
summary: copy
title: Haiku_Copy
```
Quiet disk rattling
Keyboard clicking, then it stops.
Rain falls and I think.
.
EOT
like($page, qr/^iPage was saved./m, "Write copy of haiku");
$page = query_gopher("Haiku_Copy");
like($page, qr/^$haiku_re/, "New copy of haiku created");

# append
$page = query_gopher("Haiku_Copy/append/text", "This is a comment by me!\n.\n");
like($page, qr/^iPage was saved./m, "Append to copy of haiku");
$page = query_gopher("Haiku_Copy");
like($page, qr/^$haiku_re/, "Copy of haiku still there");
like($page, qr/\n\n----\n\nThis is a comment by me!\n\n-- Anonymous/,
     "Comment is also there");

# Image download
my $image = query_gopher("Picture");
like($image, qr/\211PNG\r\n/, "Image download");

# Image upload
$page = query_gopher("PictureCopy/write/file\t" . length($image), "$image");
like($page, qr/Files of type application\/octet-stream are not allowed/m,
     "MIME type check");

$page = query_gopher("PictureCopy/image/png/write/file\t" . length($image), "$image");
like($page, qr/^iPage was saved./m, "Image upload");
unlike($page, qr/^3Page was not saved/, "Messages are correct");

my $copy = query_gopher("PictureCopy");
like($copy, qr/\211PNG\r\n/, "Image copy download");

is($copy, $image, "Image and copy are identical");

# image:link
$page = query_gopher("Test/write/text", "[[image:Picture]]\n.\n");
like($page, qr/^iPage was saved./m, "Saved test page containing image link");
$page = query_gopher("Test/menu");
like($page, qr/^1Picture\tPicture\/menu/m, "Link to image page looks good");
$page = query_gopher("Picture/menu");
like($page, qr/^IPicture\tPicture/, "Link to image file looks good");

# Test upload of large page (but note $MaxPost: 1024 * 210 > (10 * 8 + 1) * 2600)
my $garbage = (("0123456789" x 8) . "\n") x 2600 . "Last Line\n";
$page = query_gopher("Large/write/text", "$garbage.\n");
like($page, qr/^iPage was saved./m, "Write page with "
     . length($garbage) . " bytes");
$page = query_gopher("Large");
like(substr($page, -20), qr/Last Line/, "All of large page was saved");

# Test of Umlauts in the selector
test_page(update_page('Zürich♥', '[[Üetliberg♥]]'), 'Zürich♥', 'Üetliberg♥');
$page = query_gopher("Z%c3%bcrich%e2%99%a5");
utf8::decode($page);
like($page, qr/Üetliberg♥/, "UTF-8 encoded page names");

$page = query_gopher("Z%c3%bcrich%e2%99%a5/menu");
utf8::decode($page);
like($page, qr/^0Zürich♥\tZ%c3%bcrich%e2%99%a5\t/m, "UTF-8 encoded text link");
like($page, qr/^1Üetliberg♥\t%c3%9cetliberg%e2%99%a5\/menu\t/m,
     "UTF-8 encoded links");

# Space normalization
test_page(update_page('my_page', '[[my page]]'));
$page = query_gopher("my_page"); # all pages are normalized
like($page, qr/\[\[my page\]\]/, "Page name with space");

$page = query_gopher("my_page/menu");
like($page, qr/^0my page\tmy_page\t/m, "Space translates to underscore in links");

# gopher links
update_page('Gopher', '[http://gopher.floodgap.com/gopher/gw?a=gopher%3A%2F%2Fsdf.org%3A70%2F0%2Fusers%2Fsolderpunk%2Fphlog%2Fintroducing-vf1.txt VF-1], [gopher://sdf.org:70/1/phlogs/ Phlogs]');
$page = query_gopher("Gopher/menu");
like($page, qr/^1Phlogs\t\/phlogs\/\tsdf\.org\t70/m, "Direct Gopher link");
like($page, qr/^0VF-1\t\/users\/solderpunk\/phlog\/introducing-vf1.txt\tsdf\.org\t70/m, "Floodgap proxy link");

# gopher tags
update_page('Gopher', 'Tags: [[tag:Gopher]] [[tag:Perl 6]]');
$page = query_gopher("Gopher");
like($page, qr/#Gopher/m, "Gopher tag");
like($page, qr/#Perl_6/m, "Gopher multi-word tag");

done_testing();
