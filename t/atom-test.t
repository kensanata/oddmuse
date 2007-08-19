# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

require 't/test.pl';
package OddMuse;

use Test::More tests => 42;

SKIP: {

  eval {
    require LWP::UserAgent;
  };

  skip "LWP::UserAgent not installed", 42 if $@;


  eval {
    require XML::Atom::Client;
    require XML::Atom::Entry;
    require XML::Atom::Person;
  };

  skip "XML::Atom not installed", 42 if $@;

  my $wiki = 'http://localhost/cgi-bin/wiki.pl';
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get("$wiki?action=version");
  skip("No wiki running at $wiki", 42)
    unless $response->is_success;
  skip("Wiki running at $wiki doesn't have the atom extension installed", 42)
    unless $response->content =~ /\$Id: atom\.pl/;

  clear_pages();

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
  my $PostURI = "$wiki/atom";
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

  my $FeedURI = "$wiki/atom/feed";
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

  $FeedURI = "$wiki/atom/full/feed?rsslimit=2";
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
}
