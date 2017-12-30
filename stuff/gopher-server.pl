#!/usr/bin/env perl
# Copyright (C) 2017  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package Oddmuse::Gopher::Server;
use strict;
use 5.10.0;
use base qw(Net::Server::Fork); # any personality will do

Oddmuse::Gopher::Server->run;

sub options {
  my $self     = shift;
  my $prop     = $self->{'server'};
  my $template = shift;

  # setup options in the parent classes
  $self->SUPER::options($template);

  # add a single value option
  $prop->{wiki} ||= undef;
  $template->{wiki} = \ $prop->{wiki};

  $prop->{wiki_dir} ||= undef;
  $template->{wiki_dir} = \ $prop->{wiki_dir};

  $prop->{wiki_pages} ||= [];
  $template->{wiki_pages} = $prop->{wiki_pages};
}

sub post_configure_hook {
  my $self = shift;
  usage() unless $self->{server}->{wiki} and $self->{server}->{wiki_dir};
  $self->log(1, "Wiki data dir is " . $self->{server}->{wiki_dir} . "\n");
  $OddMuse::RunCGI = 0;
  $OddMuse::DataDir = $self->{server}->{wiki_dir};
  $self->log(1, "Running " . $self->{server}->{wiki} . "\n");
  do $self->{server}->{wiki}; # do it once
  # do the init code without CGI (no $q)
  OddMuse::Init();
  # make sure search is sorted newest first because NewTagFiltered resorts
  *OddMuse::OldGopherFiltered = \&OddMuse::Filtered;
  *OddMuse::Filtered = \&NewGopherFiltered;
}

sub NewGopherFiltered {
  my @pages = OddMuse::OldGopherFiltered(@_);
  @pages = sort newest_first @pages;
  return @pages;
}

sub usage {
  die <<'EOT';
This server serves a wiki as a gopher site.

It implements Net::Server and thus all the options available to
Net::Server are also available here. Additional options are available:

wiki       - this is the path to the Oddmuse script
wiki_dir   - this is the path to the Oddmuse data directory
wiki_pages - this is a page to show on the entry menu

You can use multiple instances of wiki_pages.

Example invocation:

/home/alex/src/oddmuse/stuff/gopher-server.pl \
    --port=localhost:7070 \
    --wiki=/home/alex/src/oddmuse/wiki.pl \
    --pid_file=/tmp/oddmuse/gopher.pid \
    --wiki_dir=/tmp/oddmuse \
    --wiki_pages=Homepage \
    --wiki_pages=Gopher_News

Run the script and test it:

telnet localhost 7070
lynx gopher://localhost:7070

Make changes to the script and reload:

kill -s SIGHUP `cat /tmp/oddmuse/gopher.pid`

The list of all pages:

lynx gopher://localhost:7070/1do/index

Edit a page from the command line:

perl src/oddmuse/wiki.pl title=HomePage text="Welcome!"

Visit it:

lynx gopher://localhost:7070/0HomePage

EOT
}

sub serve_main_menu {
  my $self = shift;
  $self->log(1, "Serving main menu\n");
  print "iWelcome to the Gopher version of this wiki.\r\n";
  print "iHere are some interesting starting points:\r\n";

  for my $id (@{$self->{server}->{wiki_pages}}) {
    last unless $id;
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }

  print join("\t",
	     "1" . "Recent Changes",
	     "do/rc",
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";

  print join("\t",
	     "7" . "Find matching page titles",
	     "do/match",
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";

  print join("\t",
	     "7" . "Full text search",
	     "do/search",
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";

  print join("\t",
	     "1" . "Index of all pages",
	     "do/index",
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";

  if ($OddMuse::TagFile) {
    print join("\t",
	       "1" . "Index of all tags",
	       "do/tags",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }

  my @pages = sort { $b cmp $a } grep(/^\d\d\d\d-\d\d-\d\d/, @OddMuse::IndexList);
  for my $id (@pages) {
    last unless $id;
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_index {
  my $self = shift;
  $self->log(1, "Serving index of all pages\n");
  for my $id (sort newest_first @OddMuse::IndexList) {
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_match {
  my $self = shift;
  my $match = shift;
  $self->log(1, "Serving pages matching $match\n");
  print("iUse a regular expression to match page titles.\r\n");
  print("iNote that spaces in page titles are actually underlines, '_'.\r\n");
  for my $id (sort newest_first grep(/$match/i, @OddMuse::IndexList)) {
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_search {
  my $self = shift;
  my $str = shift;
  $self->log(1, "Serving search result for $str\n");
  print("iUse regular expressions separated by space to search.\r\n");
  OddMuse::SearchTitleAndBody($str, sub {
    my $id = shift;
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  });
}

sub serve_tags {
  my $self = shift;
  $self->log(1, "Serving tag cloud\n");
  # open the DB file
  my %h = OddMuse::TagReadHash();
  my %count = ();
  foreach my $tag (grep !/^_/, keys %h) {
    $count{$tag} = @{$h{$tag}};
  }
  foreach my $id (sort { $count{$b} <=> $count{$a} } keys %count) {
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/tag",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_rc {
  my $self = shift;
  my $showedit = $OddMuse::ShowEdits = shift;
  $self->log(1, "Serving recent changes"
	     . ($showedit ? " including minor changes" : "")
	     . "\n");

  print("iRecent Changes\r\n");
  if ($showedit) {
    print join("\t",
	       "1" . "Skip minor edits",
	       "do/rc",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  } else {
    print join("\t",
	       "1" . "Show minor edits",
	       "do/rc/showedits",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }

  OddMuse::ProcessRcLines(
    sub {
      my $date = shift;
      print "i\r\n";
      print "i$date\r\n";
      print "i\r\n";
    },
    sub {
        my($id, $ts, $host, $username, $summary, $minor, $revision,
	   $languages, $cluster, $last) = @_;
	print join("\t",
		   "1" . OddMuse::NormalToFree($id),
		   "$id/menu",
		   $self->{server}->{sockaddr},
		   $self->{server}->{sockport})
	    . "\r\n";
	print "i" . OddMuse::CalcTime($ts)
	    . " by " . OddMuse::GetAuthor($host, $username)
	    . ($summary ? ": $summary" : "")
	    . ($minor ? " (minor)" : "")
	    . "\r\n";
    });
}

sub serve_file_page_menu {
  my $self = shift;
  my $id = shift;
  my $type = shift;
  my $revision = shift;
  my $code = substr($type, 0, 6) eq 'image/' ? 'I' : '9';
  $self->log(1, "Serving file page menu for $id\n");
  print join("\t",
	     $code . OddMuse::NormalToFree($id)
	     . ($revision ? "/$revision" : ""),
	     $id,
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";
}

sub serve_text_page_menu {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  my $revision = shift;
  $self->log(1, "Serving text page menu for $id"
	     . ($revision ? "/$revision" : "")
	     . "\n");

  print "iThe text of this page:\r\n";
  print join("\t",
	     "0" . OddMuse::NormalToFree($id),
	     $id . ($revision ? "/$revision" : ""),
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";
  print join("\t",
	     "h" . OddMuse::NormalToFree($id),
	     $id . ($revision ? "/$revision" : "") . "/html",
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";

  my @links; # ["page name", "display text"]
  while ($OddMuse::Page{text} =~ /\[\[([^\]|]*)(?:\|([^\]]*))?\]\]/g) {
    if (substr($1, 0, 4) eq 'tag:') {
      push(@links, [substr($1, 4) . "/tag", $2||substr($1, 4)]);
    } else {
      push(@links, [$1 . "/menu", $2||$1]);
    }
  }

  if (@links) {
    print "i\r\n";
    print "iLinks leaving " . OddMuse::NormalToFree($id) . ":\r\n";
    for my $link (@links) {
      print join("\t",
		 "1" . OddMuse::NormalToFree($link->[1]),
		 OddMuse::FreeToNormal($link->[0]),
		 $self->{server}->{sockaddr},
		 $self->{server}->{sockport})
	  . "\r\n";
    }
  } else {
    print "i\r\n";
    print "iThere are no links leaving this page.\r\n";
  }

  if ($OddMuse::Page{text} =~ m/<journal search tag:(\S+)>\s*/) {
    my $tag = $1;
    print "i\r\n";
    $self->serve_tag_list($tag);
  }
}

sub serve_page_history {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Serving history of $id\n");
  OddMuse::OpenPage($id);

  print join("\t",
	     "1" . OddMuse::NormalToFree($id) . " (current)",
	     "$id/menu",
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";
  print "i" . OddMuse::CalcTime($OddMuse::Page{ts})
      . " by " . OddMuse::GetAuthor($OddMuse::Page{host}, $OddMuse::Page{username})
      . ($OddMuse::Page{summary} ? ": $OddMuse::Page{summary}" : "")
      . ($OddMuse::Page{minor} ? " (minor)" : "")
      . "\r\n";

  foreach my $revision (OddMuse::GetKeepRevisions($OddMuse::OpenPageName)) {
    my $keep = OddMuse::GetKeptRevision($revision);
    print join("\t",
	       "1" . OddMuse::NormalToFree($id) . " ($keep->{revision})",
	       "$id/$keep->{revision}/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
    print "i" . OddMuse::CalcTime($keep->{ts})
	. " by " . OddMuse::GetAuthor($keep->{host}, $keep->{username})
	. ($keep->{summary} ? ": $keep->{summary}" : "")
	. ($keep->{minor} ? " (minor)" : "")
	. "\r\n";
  }
}

sub get_page {
  my $id = shift;
  my $revision = shift;
  my $page;
  
  if ($revision) {
    $OddMuse::OpenPageName = $id;
    $page = OddMuse::GetKeptRevision($revision);
  } else {
    OddMuse::OpenPage($id);
    $page = \%OddMuse::Page;
  }

  return $page;
}

sub serve_page_menu {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);

  if (my ($type) = OddMuse::TextIsFile($page->{text})) {
    $self->serve_file_page_menu($id, $type, $revision);
  } else {
    $self->serve_text_page_menu($id, $page, $revision);
  }

  if (not $revision) {
    print "i\r\n";
    print join("\t",
	       "1" . "Page History",
	       "$id/history",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_file_page {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  $self->log(1, "Serving $id as file\n");
  binmode(STDOUT, ':pop:raw');
  require MIME::Base64;
  my ($data) = $page->{text} =~ /^[^\n]*\n(.*)/s;
  print MIME::Base64::decode($data);
  # do not append a dot, just close the connection
  exit;
}

sub serve_text_page {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  $self->log(1, "Serving $id as text\n");
  my $text = $page->{text};
  $text =~ s/^\./../mg;
  print $text;
}

sub serve_page {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);

  if (my ($type) = OddMuse::TextIsFile($page->{text})) {
    $self->serve_file_page($id, $page);
  } else {
    $self->serve_text_page($id, $page);
  }
}

sub serve_page_html {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);

  $self->log(1, "Serving $id as HTML\n");
  # kept pages have no HTML cache
  if ($revision) {
    OddMuse::PrintWikiToHTML($page->{text}, 1); # no lock
  } else {
    OddMuse::PrintPageHtml();
  }
  # do not append a dot, just close the connection
  exit;
}

sub newest_first {
  my ($A, $B) = ($a, $b);
  if ($A =~ /^\d\d\d\d-\d\d-\d\d/ and $B =~ /^\d\d\d\d-\d\d-\d\d/) {
    return $B cmp $A;
  }
  $A cmp $B;
}

sub serve_tag_list {
  my $self = shift;
  my $tag = shift;
  print "iSearch result for tag $tag:\r\n";
  for my $id (sort newest_first OddMuse::TagFind($tag)) {
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_tag {
  my $self = shift;
  my $tag = shift;
  $self->log(1, "Serving tag $tag\n");
  if ($OddMuse::IndexHash{$tag}) {
    print "iThis page is about the tag $tag.\r\n";
    print join("\t",
	       "1" . OddMuse::NormalToFree($tag),
	       "$tag/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
    print "i\r\n";
  }
  $self->serve_tag_list($tag);
}

sub serve_unknown {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Unknown page: $id\n");
  print "3Unknown page: $id\n";
}

sub write_help {
  print("iThis is how your document should start:\r\n");
  print("i```\r\n");
  print("iusername: Alex Schroeder\r\n");
  print("isummary: typo fixed\r\n");
  print("i```\r\n");
  print("iThis is the text of your document.\r\n");
  print("iJust write whatever.\r\n");
  print("i\r\n");
  print("iNote the space after the colon for metadata fields.\r\n");
  print("iMore metadata fields are allowed:\r\n");
  print("i`minor` is 1 if this is a minor edit. The default is 0.\r\n");
}

sub write_page_ok {
  print("iPage was saved.\r\n");
}

sub write_page {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Posting to page $id\n");
  local $/ = \$OddMuse::MaxPost; # limited reading
  my $buf = <STDIN>;
  $self->log(1, "Received " . length($buf) . " bytes");

  my ($lead, $meta, $text) = split(/^```\s*(?:meta)?\n/m, $buf, 3);
  if (not $lead) {
    while ($meta =~ /^([a-z-]+): (.*)/mg) {
      if ($1 eq 'minor' and $2) {
	OddMuse::SetParam('recent_edit', 'on'); # legacy UseMod parameter name
      } else {
	OddMuse::SetParam($1, $2);
      }
    }
    OddMuse::SetParam('text', $text);
  } else {
    # no meta data
    OddMuse::SetParam('text', $buf);
  }

  local *OddMuse::ReBrowsePage = \&write_page_ok;
  OddMuse::DoPost($id);
}

sub process_request {
  my $self = shift;

  binmode(STDIN, ':encoding(UTF-8)');
  binmode(STDOUT, ':encoding(UTF-8)');
  binmode(STDERR, ':encoding(UTF-8)');

  if (OddMuse::IsFile($OddMuse::IndexFile) and OddMuse::ReadIndex()) {
    # we're good
  } else {
    OddMuse::RefreshIndex();
  }

  eval {
    local $SIG{'ALRM'} = sub { die "Timed Out!\n" };
    alarm(10); # timeout
    my $id = <STDIN>; # no loop
    $id =~ s/^\/.//; # strip leading slash and type, if any
    $id =~ s/\s+$//g; # no trailing whitespace
    if (not $id) {
      $self->serve_main_menu();
    } elsif ($id eq "do/index") {
      $self->serve_index();
    } elsif (substr($id, 0, 9) eq "do/match\t") {
      $self->serve_match(substr($id, 9));
    } elsif (substr($id, 0, 10) eq "do/search\t") {
      $self->serve_search(substr($id, 10));
    } elsif ($id eq "do/tags") {
      $self->serve_tags();
    } elsif ($id eq "do/rc") {
      $self->serve_rc(0);
    } elsif ($id eq "do/rc/showedits") {
      $self->serve_rc(1);
    } elsif ($id =~ m!^([^/]*)/(\d+)/menu$! and $OddMuse::IndexHash{$1}) {
      $self->serve_page_menu($1, $2);
    } elsif (substr($id, -5) eq '/menu' and $OddMuse::IndexHash{substr($id, 0, -5)}) {
      $self->serve_page_menu(substr($id, 0, -5));
    } elsif ($id =~ m!^([^/]*)/tag$!) { # this also works if the tag page is missing
      $self->serve_tag($1);
    } elsif ($id =~ m!^([^/]*)(?:/(\d+))?/html! and $OddMuse::IndexHash{$1}) {
      $self->serve_page_html($1, $2);
    } elsif ($id =~ m!^([^/]*)/history$! and $OddMuse::IndexHash{$1}) {
      $self->serve_page_history($1);
    } elsif ($id =~ m!^([^/]*)/write$!) { # this also works if the tag page is missing
      $self->write_page($1);
    } elsif ($id =~ m!^([^/]*)(?:/(\d+))?(?:/text)?$! and $OddMuse::IndexHash{$1}) {
      $self->serve_page($1, $2);
    } else {
      $self->serve_unknown($id);
    }
  };
  print ".\r\n";

  if ($@ =~ /timed out/i) {
    $self->log(1, "Timed Out.\n");
    return;
  }
}
