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


package OddMuse;
use strict;
use 5.10.0;
use MIME::Base64;
use Mojo::IOLoop;
use Mojo::Log;
use Getopt::Long;

our($RunCGI, $DataDir, %IndexHash, @IndexList, $IndexFile, $TagFile,
    %Page, $OpenPageName, $MaxPost, $ShowEdits, %Locks);

my $host;
my $port;
my @wiki_pages;
my $help;
my $log;

my $usage = << 'EOT';
This server serves a wiki as a gopher site.

Options:

--host=alexschroeder.ch
    The host we are serving from. This defaults to localhost, meaning
    that only clients on the same host will be able to follow links.
--port=3000
    The port to listen to, defaults to a random port.
--log_file=/var/log/oddmuse/gopher_server.log
    The log file to write, defaults to STDERR.
--log_level=error
    The log level to use, defaults to "debug". The available log levels
    are "debug", "info", "warn", "error" and "fatal", in that order.
    Note that the "MOJO_LOG_LEVEL" environment variable can override
    this value.
--wiki_dir=/tmp/oddmuse
    The wiki directory. Note that the "WikiDataDir" environment
    variable can override this value.
--wiki_lib=/home/alex/src/oddmuse/wiki.pl
    The Oddmuse main script. This defaults to "./wiki.pl".
--wiki_pages=SiteMap
    This adds a page to the main index. Can be used multiple times.
--help
    Prints this message.

Man pages of interest:
- Mojo::IOLoop
- Mojo::IOLoop::Server
- Mojo::Log

Example invocation:

/home/alex/src/oddmuse/stuff/gopher-server.pl \
    --host=alexschroeder.ch \
    --port=7070 \
    --wiki=/home/alex/src/oddmuse/wiki.pl \
    --wiki_dir=/tmp/oddmuse \
    --wiki_pages=Homepage \
    --wiki_pages=Gopher_News

Run the script and test it:

echo | nc localhost 7070
lynx gopher://localhost:7070

The list of all pages:

lynx gopher://localhost:7070/1do/index

Edit a page from the command line:

perl src/oddmuse/wiki.pl title=HomePage text="Welcome!"

Visit it:

lynx gopher://localhost:7070/0HomePage

To daemonize it, I recommend using an external tool:

daemonize -p /tmp/oddmuse/gopher-server.pid \
    /home/alex/src/oddmuse/stuff/gopher-server.pl \
    --host alexschroeder.ch \
    --port 7070 \
    --wiki_lib /home/alex/src/oddmuse/wiki.pl \
    --wiki_dir /tmp/oddmuse \
    --wiki_pages Homepage \
    --wiki_pages Gopher_News

EOT

run();

sub run {
  my $wiki_dir = '/tmp/oddmuse';
  my $wiki_lib = './wiki.pl';
  my $log_file;
  my $log_level;
  $host = 'localhost';
  
  GetOptions ("host=s" => \$host,
	      "port=i"   => \$port,
	      "log=s" => \$log,
	      "log_file=s" => \$log_file,
	      "log_level=s" => \$log_level,
	      "wiki_dir=s" => \$wiki_dir,
	      "wiki_lib=s" => \$wiki_lib,
	      "wiki_pages=s" => \@wiki_pages,
	      "help=s" => \$help,)
      or die("Error in command line arguments\n");

  die $usage if $help;

  $log = Mojo::Log->new;
  $log->path($log_file) if $log_file;
  $log->level($log_level) if $log_level;
  
  $log->info("Wiki data dir is " . $wiki_dir);
  $RunCGI = 0;
  $DataDir = $wiki_dir;
  $log->info("Running " . $wiki_lib);
  unless (my $return = do $wiki_lib) {
    $log->error("couldn't parse wiki library $wiki_lib: $@") if $@;
    $log->error("couldn't do wiki library $wiki_lib: $!") unless defined $return;
    $log->error("couldn't run wiki library $wiki_lib") unless $return;
  }
  # do the init code without CGI (no $q)
  Init();
  # make sure search is sorted newest first because NewTagFiltered resorts
  *OldGopherFiltered = \&Filtered;
  *Filtered = \&NewGopherFiltered;

  my $id = Mojo::IOLoop->server({
    port => $port} => \&process_request);
  # if it's a random port, we need to know
  $port = Mojo::IOLoop->acceptor($id)->port;

  $log->info("PID $$");
  $log->info("Linking to $host");
  $log->info("Listening on port $port");
  Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
};

sub NewGopherFiltered {
  my @pages = OldGopherFiltered(@_);
  @pages = sort newest_first @pages;
  return @pages;
}

sub print_text {
  my $stream = shift;
  my $text = shift;
  utf8::encode($text);
  $stream->write($text); # bytes
}

sub serve_main_menu {
  my $stream = shift;
  $log->info("Serving main menu");
  print_text($stream, "iWelcome to the Gopher version of this wiki.\r\n");
  print_text($stream, "iHere are some interesting starting points:\r\n");

  for my $id (@wiki_pages) {
    last unless $id;
    print_text($stream, join("\t",
	       "1" . NormalToFree($id),
	       "$id/menu",
	       $host,
	       $port)
	. "\r\n");
  }

  print_text($stream, join("\t",
	     "1" . "Recent Changes",
	     "do/rc",
	     $host,
	     $port)
      . "\r\n");

  print_text($stream, join("\t",
	     "7" . "Find matching page titles",
	     "do/match",
	     $host,
	     $port)
      . "\r\n");

  print_text($stream, join("\t",
	     "7" . "Full text search",
	     "do/search",
	     $host,
	     $port)
      . "\r\n");

  print_text($stream, join("\t",
	     "1" . "Index of all pages",
	     "do/index",
	     $host,
	     $port)
      . "\r\n");

  if ($TagFile) {
    print_text($stream, join("\t",
	       "1" . "Index of all tags",
	       "do/tags",
	       $host,
	       $port)
	. "\r\n");
  }

  my @pages = sort { $b cmp $a } grep(/^\d\d\d\d-\d\d-\d\d/, @IndexList);
  for my $id (@pages) {
    last unless $id;
    print_text($stream, join("\t",
	       "1" . NormalToFree($id),
	       "$id/menu",
	       $host,
	       $port)
	. "\r\n");
  }
}

sub serve_index {
  my $stream = shift;
  $log->info("Serving index of all pages");
  for my $id (sort newest_first @IndexList) {
    print_text($stream, join("\t",
	       "1" . NormalToFree($id),
	       "$id/menu",
	       $host,
	       $port)
	. "\r\n");
  }
}

sub serve_match {
  my $stream = shift;
  my $match = shift;
  $log->info("Serving pages matching $match");
  print_text($stream, "iUse a regular expression to match page titles.\r\n");
  print_text($stream, "iNote that spaces in page titles are actually underlines, '_'.\r\n");
  for my $id (sort newest_first grep(/$match/i, @IndexList)) {
    print_text($stream, join("\t",
	       "1" . NormalToFree($id),
	       "$id/menu",
	       $host,
	       $port)
	. "\r\n");
  }
}

sub serve_search {
  my $stream = shift;
  my $str = shift;
  $log->info("Serving search result for $str");
  print_text($stream, "iUse regular expressions separated by space to search.\r\n");
  SearchTitleAndBody($str, sub {
    my $id = shift;
    print_text($stream, join("\t",
	       "1" . NormalToFree($id),
	       "$id/menu",
	       $host,
	       $port)
	. "\r\n");
  });
}

sub serve_tags {
  my $stream = shift;
  $log->info("Serving tag cloud");
  # open the DB file
  my %h = TagReadHash();
  my %count = ();
  foreach my $tag (grep !/^_/, keys %h) {
    $count{$tag} = @{$h{$tag}};
  }
  foreach my $id (sort { $count{$b} <=> $count{$a} } keys %count) {
    print_text($stream, join("\t",
	       "1" . NormalToFree($id),
	       "$id/tag",
	       $host,
	       $port)
	. "\r\n");
  }
}

sub serve_rc {
  my $stream = shift;
  my $showedit = $ShowEdits = shift;
  $log->info("Serving recent changes"
	     . ($showedit ? " including minor changes" : ""));

  print_text($stream, "iRecent Changes\r\n");
  if ($showedit) {
    print_text($stream, join("\t",
	       "1" . "Skip minor edits",
	       "do/rc",
	       $host,
	       $port)
	. "\r\n");
  } else {
    print_text($stream, join("\t",
	       "1" . "Show minor edits",
	       "do/rc/showedits",
	       $host,
	       $port)
	. "\r\n");
  }

  ProcessRcLines(
    sub {
      my $date = shift;
      print_text($stream, "i\r\n");
      print_text($stream, "i$date\r\n");
      print_text($stream, "i\r\n");
    },
    sub {
        my($id, $ts, $author_host, $username, $summary, $minor, $revision,
	   $languages, $cluster, $last) = @_;
	print_text($stream, join("\t",
		   "1" . NormalToFree($id),
		   "$id/menu",
		   $host,
		   $port)
	    . "\r\n");
	print_text($stream, "i" . CalcTime($ts)
	    . " by " . GetAuthor($author_host, $username)
	    . ($summary ? ": $summary" : "")
	    . ($minor ? " (minor)" : "")
	    . "\r\n");
    });
}

sub serve_file_page_menu {
  my $stream = shift;
  my $id = shift;
  my $type = shift;
  my $revision = shift;
  my $code = substr($type, 0, 6) eq 'image/' ? 'I' : '9';
  $log->info("Serving file page menu for $id");
  print_text($stream, join("\t",
	     $code . NormalToFree($id)
	     . ($revision ? "/$revision" : ""),
	     $id,
	     $host,
	     $port)
      . "\r\n");
}

sub serve_text_page_menu {
  my $stream = shift;
  my $id = shift;
  my $page = shift;
  my $revision = shift;
  $log->info("Serving text page menu for $id"
	     . ($revision ? "/$revision" : ""));

  print_text($stream, "iThe text of this page:\r\n");
  print_text($stream, join("\t",
	     "0" . NormalToFree($id),
	     $id . ($revision ? "/$revision" : ""),
	     $host,
	     $port)
      . "\r\n");
  print_text($stream, join("\t",
	     "h" . NormalToFree($id),
	     $id . ($revision ? "/$revision" : "") . "/html",
	     $host,
	     $port)
      . "\r\n");
  print_text($stream, join("\t",
	     "w" . NormalToFree($id),
	     $id . "/write/text",
	     $host,
	     $port)
      . "\r\n");

  my @links; # ["page name", "display text"]
  while ($page->{text} =~ /\[\[([^\]|]*)(?:\|([^\]]*))?\]\]/g) {
    if (substr($1, 0, 4) eq 'tag:') {
      push(@links, [substr($1, 4) . "/tag", $2||substr($1, 4)]);
    } else {
      push(@links, [$1 . "/menu", $2||$1]);
    }
  }

  if (@links) {
    print_text($stream, "i\r\n");
    print_text($stream, "iLinks leaving " . NormalToFree($id) . ":\r\n");
    for my $link (@links) {
      print_text($stream, join("\t",
		 "1" . NormalToFree($link->[1]),
		 FreeToNormal($link->[0]),
		 $host,
		 $port)
	  . "\r\n");
    }
  } else {
    print_text($stream, "i\r\n");
    print_text($stream, "iThere are no links leaving this page.\r\n");
  }

  if ($page->{text} =~ m/<journal search tag:(\S+)>\s*/) {
    my $tag = $1;
    print_text($stream, "i\r\n");
    serve_tag_list($stream, $tag);
  }
}

sub serve_page_history {
  my $stream = shift;
  my $id = shift;
  $log->info("Serving history of $id");
  OpenPage($id);

  print_text($stream, join("\t",
	     "1" . NormalToFree($id) . " (current)",
	     "$id/menu",
	     $host,
	     $port)
      . "\r\n");
  print_text($stream, "i" . CalcTime($Page{ts})
      . " by " . GetAuthor($Page{host}, $Page{username})
      . ($Page{summary} ? ": $Page{summary}" : "")
      . ($Page{minor} ? " (minor)" : "")
      . "\r\n");

  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my $keep = GetKeptRevision($revision);
    print_text($stream, join("\t",
	       "1" . NormalToFree($id) . " ($keep->{revision})",
	       "$id/$keep->{revision}/menu",
	       $host,
	       $port)
	. "\r\n");
    print_text($stream, "i" . CalcTime($keep->{ts})
	. " by " . GetAuthor($keep->{host}, $keep->{username})
	. ($keep->{summary} ? ": $keep->{summary}" : "")
	. ($keep->{minor} ? " (minor)" : "")
	. "\r\n");
  }
}

sub get_page {
  my $id = shift;
  my $revision = shift;
  my $page;

  if ($revision) {
    $OpenPageName = $id;
    $page = GetKeptRevision($revision);
  } else {
    OpenPage($id);
    $page = \%Page;
  }

  return $page;
}

sub serve_page_menu {
  my $stream = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);

  if (my ($type) = TextIsFile($page->{text})) {
    serve_file_page_menu($stream, $id, $type, $revision);
  } else {
    serve_text_page_menu($stream, $id, $page, $revision);
  }

  if (not $revision) {
    print_text($stream, "i\r\n");
    print_text($stream, join("\t",
	       "1" . "Page History",
	       "$id/history",
	       $host,
	       $port)
	. "\r\n");
  }
}

sub serve_file_page {
  my $stream = shift;
  my $id = shift;
  my $page = shift;
  $log->info("Serving $id as file");
  require MIME::Base64;
  my ($data) = $page->{text} =~ /^[^\n]*\n(.*)/s;
  $stream->write(MIME::Base64::decode($data));
  # do not append a dot, just close the connection
  goto LOOP_END;
}

sub serve_text_page {
  my $stream = shift;
  my $id = shift;
  my $page = shift;
  $log->info("Serving $id as text");
  my $text = $page->{text};
  $text =~ s/^\./../mg;
  print_text($stream, $text);
}

sub serve_page {
  my $stream = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);

  if (my ($type) = TextIsFile($page->{text})) {
    serve_file_page($stream, $id, $page);
  } else {
    serve_text_page($stream, $id, $page);
  }
}

sub serve_page_html {
  my $stream = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);

  $log->info("Serving $id as HTML");
  # kept pages have no HTML cache
  local *STDIN = \$stream;
  if ($revision) {
    print_text($stream, ToString(\&PrintWikiToHTML, $page->{text}, 1)); # no lock
  } else {
    print_text($stream, ToString(\&PrintPageHtml));
  }
  # do not append a dot, just close the connection
  goto LOOP_END;
}

sub newest_first {
  my ($A, $B) = ($a, $b);
  if ($A =~ /^\d\d\d\d-\d\d-\d\d/ and $B =~ /^\d\d\d\d-\d\d-\d\d/) {
    return $B cmp $A;
  }
  $A cmp $B;
}

sub serve_tag_list {
  my $stream = shift;
  my $tag = shift;
  print_text($stream, "iSearch result for tag $tag:\r\n");
  for my $id (sort newest_first TagFind($tag)) {
    print_text($stream, join("\t",
	       "1" . NormalToFree($id),
	       "$id/menu",
	       $host,
	       $port)
	. "\r\n");
  }
}

sub serve_tag {
  my $stream = shift;
  my $tag = shift;
  $log->info("Serving tag $tag");
  if ($IndexHash{$tag}) {
    print_text($stream, "iThis page is about the tag $tag.\r\n");
    print_text($stream, join("\t",
	       "1" . NormalToFree($tag),
	       "$tag/menu",
	       $host,
	       $port)
	. "\r\n");
    print_text($stream, "i\r\n");
  }
  serve_tag_list($stream, $tag);
}

sub serve_unknown {
  my $stream = shift;
  my $id = shift;
  $log->info("Unknown page: '$id'");
  print_text($stream, "3Unknown page: $id\r\n");
}

sub write_help {
  my $stream = shift;
  print_text($stream, <<"EOF");
iThis is how your document should start:\r
i```\r
iusername: Alex Schroeder\r
isummary: typo fixed\r
i```\r
iThis is the text of your document.\r
iJust write whatever.\r
i\r
iNote the space after the colon for metadata fields.\r
iMore metadata fields are allowed:\r
i`minor` is 1 if this is a minor edit. The default is 0.\r
EOF
}

sub write_page_ok {
  my $stream = shift;
  print_text($stream, "iPage was saved.\r\n");
}

sub write_page_error {
  my $stream = shift;
  my $error = shift;
  print_text($stream, "3Page was not saved: $error\r\n");
  map { ReleaseLockDir($_); } keys %Locks;
}

sub write_data {
  my $stream = shift;
  my $id = shift;
  my $data = shift;
  SetParam('text', $data);
  local *ReBrowsePage = sub {
    write_page_ok($stream);
  };
  local *ReportError = sub {
    write_page_error($stream, @_);
    die;
  };
  eval {
    DoPost($id);
  };
}

sub write_file_page {
  my $stream = shift;
  my $id = shift;
  my $data = shift;
  my $type = shift || 'application/octet-stream';
  $log->info("Posting " . length($data) . " bytes of $type to page $id");
  # no metadata
  write_data($stream, $id, "#FILE $type\n" . MIME::Base64::encode($data));
}

sub write_text_page {
  my $stream = shift;
  my $id = shift;
  my $data = shift;
  utf8::decode($data);
  $log->info("Posting " . length($data) . " characters to page $id");

  my ($lead, $meta, $text) = split(/^```\s*(?:meta)?\n/m, $data, 3);
  if (not $lead) {
    while ($meta =~ /^([a-z-]+): (.*)/mg) {
      if ($1 eq 'minor' and $2) {
	SetParam('recent_edit', 'on'); # legacy UseMod parameter name
      } else {
	SetParam($1, $2);
      }
    }
    write_data($stream, $id, $text);
  } else {
    # no meta data
    write_data($stream, $id, $data);
  }
}

sub process_request {
  my ($loop, $stream) = @_;

  $stream->on(read => sub {
    my ($stream, $bytes) = @_;

    # refresh list of pages
    if (IsFile($IndexFile) and ReadIndex()) {
      # we're good
    } else {
      RefreshIndex();
    }

    # telnet just terminates with \n
    my ($id, $data) = split(/\r?\n/, $bytes, 2);
    utf8::decode($id);
    # $data can be binary file
    $log->debug("Selector: $id");

    if (not $id) {
      serve_main_menu($stream);
    } elsif ($id eq "do/index") {
      serve_index($stream);
    } elsif (substr($id, 0, 9) eq "do/match\t") {
      serve_match($stream, substr($id, 9));
    } elsif (substr($id, 0, 10) eq "do/search\t") {
      serve_search($stream, substr($id, 10));
    } elsif ($id eq "do/tags") {
      serve_tags($stream);
    } elsif ($id eq "do/rc") {
      serve_rc($stream, 0);
    } elsif ($id eq "do/rc/showedits") {
      serve_rc($stream, 1);
    } elsif ($id =~ m!^([^/]*)/(\d+)/menu$! and $IndexHash{$1}) {
      serve_page_menu($stream, $1, $2);
    } elsif (substr($id, -5) eq '/menu' and $IndexHash{substr($id, 0, -5)}) {
      serve_page_menu($stream, substr($id, 0, -5));
    } elsif ($id =~ m!^([^/]*)/tag$!) { # this also works if the tag page is missing
      serve_tag($stream, $1);
    } elsif ($id =~ m!^([^/]*)(?:/(\d+))?/html! and $IndexHash{$1}) {
      serve_page_html($stream, $1, $2);
    } elsif ($id =~ m!^([^/]*)/history$! and $IndexHash{$1}) {
      serve_page_history($stream, $1);
    } elsif ($id =~ m!^([^/]*)/write/text$!) {
      write_text_page($stream, $1, $data);
    } elsif ($id =~ m!^([^/]*)(?:/([a-z]+/[-a-z]+))?/write/file$!) {
      write_file_page($stream, $1, $data, $2);
    } elsif ($id =~ m!^([^/]*)(?:/(\d+))?(?:/text)?$! and $IndexHash{$1}) {
      serve_page($stream, $1, $2);
    } else {
      serve_unknown($stream, $id);
    }

    # Write final dot for almost everything
    print_text($stream, ".\r\n");
  LOOP_END:
    $stream->close_gracefully();
    $log->debug("Done");
  });
}
