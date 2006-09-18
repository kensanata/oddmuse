#!/usr/bin/perl

require 't/test.pl';
package OddMuse;

use XML::Atom::Client;
use XML::Atom::Entry;
use XML::Atom::Person;
use Test::More tests => 42;

clear_pages();

print "Preparing new entry\n";

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
my $PostURI = 'http://localhost/cgi-bin/wiki.pl/atom';
my $MemberURI = $api->createEntry($PostURI, $entry);
ok($MemberURI, 'posting entry returns member URI')
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
  } else {
    print "Ignoring ", $link->href, "\n";
  }
}
ok($MemberURI, 'entry contains member URI');

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

my $FeedURI = 'http://localhost/cgi-bin/wiki.pl/atom/feed';
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

$FeedURI = 'http://localhost/cgi-bin/wiki.pl/atom/full/feed?rsslimit=2';
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
