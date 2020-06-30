# Copyright (C) 2017–2020  Alex Schroeder <alex@gnu.org>
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
use IO::Socket::SSL;
use utf8; # tests contain UTF-8 characters and it matters
use Modern::Perl;
use XML::RSS;
use XML::LibXML;

require './t/test.pl';
require './stuff/gemini-server.pl';

add_module('tags.pl');

# enable uploads and filtering by language
our($ConfigFile);
AppendStringToFile($ConfigFile, <<'EOT');
$UploadAllowed = 1;
%Languages = (
  'de' => '\b(der|die|das|und|oder)\b',
  'en' => '\b(i|he|she|it|we|they|this|that|a|is|was)\b', );
EOT

# enable comments
our($CommentsPrefix);
$CommentsPrefix = 'Comments_on_';
AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments_on_';\n");
AppendStringToFile($ConfigFile, "\@QuestionaskerQuestions = (['Who rules in Rivendell?' => sub { shift =~ /^Elrond/i }]);\n");

# write a gemini-only extension
our($DataDir);
WriteStringToFile("$DataDir/gemini_config", <<'EOT');
package OddMuse;
use Modern::Perl;
our (@extensions, @main_menu_links);
push(@extensions, \&serve_cert);
sub serve_cert {
  my $self = shift;
  my $url = shift;
  my $selector = shift;
  my $base = $self->base();
  if ($selector =~ m!^do/test!) {
    say "20 text/plain\r";
    say "Test";
    return 1;
  }
  return;
}
1;
EOT

my $host = "127.0.0.1";
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
       "stuff/gemini-server.pl",
       "--host=$host",
       "--port=$port",
       "--wiki_cert_file=t/cert.pem",
       "--wiki_key_file=t/key.pem",
       "--log_level=0", # set to 4 for verbose logging
       "--wiki=./wiki.pl",
       "--wiki_dir=$DataDir",
       "--wiki_pages=Alex",
       "--wiki_pages=Berta",
       "--wiki_pages=Chris")
      or die "Cannot exec: $!";
}

# Sorting
is(sub{$a="Alex"; $b="Berta"; newest_first()}->(), -1, "Alex before Berta");
is(sub{$a="Alex"; $b="Comments_on_Alex"; newest_first()}->(), -1, "Alex before Comments_on_Alex");
is(sub{$a="Chris"; $b="Comments_on_Alex"; newest_first()}->(), 1, "Chris after Comments_on_A");
is(sub{$a="Image_1_for_Alex"; $b="Image_10_for_Alex"; newest_first()}->(), -1, "Image_1_for_Alex before Image_10_for_Alex");
is(sub{$a="Comments_on_Alex"; $b="Image_1_for_Alex"; newest_first()}->(), -1, "Comments_on_Alex before Image_1_for_Alex");
is(join(" ", sort newest_first qw(Alex Berta Chris)), "Alex Berta Chris", "Sort alphabetically");
is(join(" ", sort newest_first qw(2017-12-25 2017-12-26 2017-12-27)), "2017-12-27 2017-12-26 2017-12-25", "Sort by date descending");
is(join(" ", sort newest_first qw(Alex Comments_on_Alex Berta Chris)), "Alex Comments_on_Alex Berta Chris", "Comments after pages");
is(join(" ", sort newest_first qw(2017-12-25 2017-12-26 Comments_on_2017-12-26 2017-12-27)), "2017-12-27 2017-12-26 Comments_on_2017-12-26 2017-12-25", "Comments after date pages");
is(join(" ", sort newest_first qw(Alex Comments_on_Alex Image_1_for_Alex Image_2_for_Alex Image_10_for_Alex Berta Chris)), "Alex Comments_on_Alex Image_1_for_Alex Image_2_for_Alex Image_10_for_Alex Berta Chris", "Images sorted numerically");

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

sub query_gemini {
  my $query = shift;
  my $text = shift;

  # create client
  my $socket = IO::Socket::SSL->new(
    PeerHost => "localhost",
    PeerService => $port,
    SSL_cert_file => 'cert.pem',
    SSL_key_file => 'key.pem',
    SSL_verify_mode => SSL_VERIFY_NONE)
      or die "Cannot construct client socket: $@";

  $socket->print("$query\r\n");
  $socket->print($text);

  undef $/; # slurp
  return <$socket>;
}

my $base = "gemini://$host:$port";

# main menu
my $page = query_gemini("$base/");

for my $item(qw(Alex Berta Chris 2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^=> $base\/$item $item/m, "main menu contains $item");
}

unlike($page, qr/^=> .*\/$/m, "No empty links in the menu");

$page = query_gemini("$base/Alex");

like($page, qr/^My best friend is Berta\.$/m, "Local free link (text)");
like($page, qr/=> $base\/Berta Berta$/m, "Local free link (link)");
like($page, qr/^Tags:$/m, "Tags footer");
like($page, qr/^Tags:$/m, "Tags footer");
like($page, qr/=> $base\/tag\/Friends Friends$/m, "Tag link");
like($page, qr/^=> $base\/raw\/Alex Raw text$/m, "Raw text link");
like($page, qr/^=> $base\/history\/Alex History$/m, "History");
like($page, qr/^=> $base\/Comments_on_Alex Comments on this page$/m, "Comment link");

# language tag
$page = query_gemini("$base\/2017-12-25");
like($page, qr/^20 text\/gemini; charset=UTF-8; lang=en\r\n/, "Result 20 with MIME type and language");

# plain text
$page = query_gemini("$base\/raw\/Alex");
like($page, qr/^My best friend is \[\[Berta\]\]\.$/m, "Raw text");

# history
$page = query_gemini("$base/history/Friends");
like($page, qr/^=> $base\/Friends\/1 Friends \(1\)/m, "Revision 1 is listed");
like($page, qr/^=> $base\/Friends\/2 Friends \(2\)/m, "Revision 2 is listed");
like($page, qr/^=> $base\/diff\/Friends\/1 Diff between revision 1 and the current one/m, "Diff 1 link");
like($page, qr/^=> $base\/diff\/Friends\/2 Diff between revision 2 and the current one/m, "Diff 2 link");
like($page, qr/^=> $base\/Friends Friends \(current\)/m, "Current revision is listed");
$page = query_gemini("$base/Friends/1");
like($page, qr/^Some friends\.$/m, "Revision 1 content");
$page = query_gemini("$base/Friends/2");
like($page, qr/^News about friends\.$/m, "Revision 2 content");

#diffs
$page = query_gemini("$base/diff/Friends/1");
like($page, qr/^< Some friends\.\n-+\n> News about friends:\n> \n> <journal search tag:friends>\n$/m, "Diff 1 content");
$page = query_gemini("$base/diff/Friends/2");
like($page, qr/^< News about friends\.\n-+\n> News about friends:\n> \n> <journal search tag:friends>\n$/m, "Diff 1 content");

# tags
$page = query_gemini("$base\/tag\/Friends");
like($page, qr/^This page is about the tag Friends\.$/m, "tag menu intro");
for my $item(qw(Friends Alex Berta Chris)) {
  like($page, qr/^=> $base\/$item $item$/m, "tag menu contains $item");
}

# tags
$page = query_gemini("$base\/tag\/Day");
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s,
     "tag menu sorted newest first");

# match
$page = query_gemini("$base\/do/match?2017");
for my $item(qw(2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^=> $base\/$item $item$/m, "match menu contains $item");
}
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s,
     "match menu sorted newest first");

# search
$page = query_gemini("$base\/do/search?tag:day");
for my $item(qw(2017-12-25 2017-12-26 2017-12-27)) {
  like($page, qr/^=> $base\/$item $item/m, "search menu contains $item");
}
like($page, qr/2017-12-27.*2017-12-26.*2017-12-25/s,
     "search menu sorted newest first");

# rc
$page = query_gemini("$base\/do/rc");
my $re = join(".*", "Picture", "2017-12-27", "2017-12-26", "2017-12-25",
	      "Friends", "Chris", "Berta", "Alex");
like($page, qr/$re/s, "rc in the right order");

$page = query_gemini("$base\/do/rc/minor");

$re = join(".*", "Friends", "2017-12-27", "2017-12-26", "2017-12-25");
like($page, qr/$re/s, "minor rc in the right order");

# rss
my $rss = new XML::RSS;
$page = query_gemini("$base\/do/rss");
ok($page =~ s!^20 application/rss\+xml\r\n!!, "RSS header OK");
ok($rss->parse($page), "RSS parse OK");

# atom
$page = query_gemini("$base\/do/atom");
ok($page =~ s!^20 application/atom\+xml\r\n!!, "Atom header OK");
# $rss->parse($page) results in warnings that I can't get rid of
ok(XML::LibXML->load_xml(string => $page), "Atom parse OK");

# upload text

my $titan = "titan://$host:$port";

my $haiku = <<EOT;
Quiet disk ratling
Keyboard clicking, then it stops.
Rain falls and I think
EOT

$page = query_gemini("$titan/raw/Haiku;size=76;mime=text/plain", $haiku);
like($page, qr/^30 $base\/Haiku\r$/, "Titan Haiku");

my $haiku_re = $haiku;
$haiku_re =~ s/\s+/ /g; # lines get wrapped
$haiku_re =~ s/\s+$//g;
$haiku_re = quotemeta($haiku_re);
$page = query_gemini("$base/Haiku");
like($page, qr/^$haiku_re/m, "Haiku saved");

# comment

like($page, qr/^=> $base\/Comments_on_Haiku Comments on this page$/m, "Comment page link");

$page = query_gemini("$base/Comments_on_Haiku");
like($page, qr/^=> $base\/do\/comment\/Comments_on_Haiku Leave a comment$/m, "Leave comment link");

$page = query_gemini("$base/do/comment/Comments_on_Haiku");
like($page, qr/^30 $base\/do\/comment\/Comments_on_Haiku\/0\r$/, "Redirect to a question");

$page = query_gemini("$base/do/comment/Comments_on_Haiku/0");
like($page, qr/^10 Who rules in Rivendell\?\r$/, "Ask security question");

$page = query_gemini("$base/do/comment/Comments_on_Haiku/0?elrond");
like($page, qr/^30 $base\/do\/comment\/Comments_on_Haiku\/0\/elrond\r$/, "Redirect to comment prompt");

$page = query_gemini("$base/do/comment/Comments_on_Haiku/0/elrond");
like($page, qr/^10 Comment\r$/, "Ask for comment");

$page = query_gemini("$base/do/comment/Comments_on_Haiku/0/elrond?Give%20me%20the%20ring!");
like($page, qr/^30 $base\/Comments_on_Haiku\r$/, "Redirect back to the main page");

$page = query_gemini("$base/Comments_on_Haiku");
like($page, qr/^Give me the ring!\n\n-- Anonymous/m, "Comment saved");

# extension

$page = query_gemini("$base/do/test");
like($page, qr/^Test\n/m, "Extension runs");

done_testing();
