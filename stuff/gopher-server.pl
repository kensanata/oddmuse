#!/usr/bin/env perl
# Copyright (C) 2017–2019  Alex Schroeder <alex@gnu.org>

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
use base qw(Net::Server::Fork); # any personality will do
use MIME::Base64;
use Text::Wrap;
use List::Util qw(first);
use Socket;

our($RunCGI, $DataDir, %IndexHash, @IndexList, $IndexFile, $TagFile, $q,
    %Page, $OpenPageName, $MaxPost, $ShowEdits, %Locks, $CommentsPattern,
    $CommentsPrefix, $EditAllowed, $NoEditFile, $SiteName, $ScriptName,
    $Now, %RecentVisitors, $SurgeProtectionTime, $SurgeProtectionViews,
    $SurgeProtection);

my $external_image_path = '/home/alex/alexschroeder.ch/pics/';

# Sadly, we need this information before doing anything else
my %args = (proto => 'ssl');
for (grep(/--wiki_(key|cert)_file=/, @ARGV)) {
  $args{SSL_cert_file} = $1 if /--wiki_cert_file=(.*)/;
  $args{SSL_key_file} = $1 if /--wiki_key_file=(.*)/;
}
if ($args{SSL_cert_file} and not $args{SSL_key_file}
    or not $args{SSL_cert_file} and $args{SSL_key_file}) {
  die "I must have both --wiki_key_file and --wiki_cert_file\n";
} elsif ($args{SSL_cert_file} and $args{SSL_key_file}) {
  OddMuse->run(%args);
} else {
  OddMuse->run;
}

sub options {
  my $self     = shift;
  my $prop     = $self->{'server'};
  my $template = shift;

  # setup options in the parent classes
  $self->SUPER::options($template);

  # add a single value option
  $prop->{wiki} ||= undef;
  $template->{wiki} = \$prop->{wiki};

  $prop->{wiki_dir} ||= undef;
  $template->{wiki_dir} = \$prop->{wiki_dir};

  $prop->{wiki_pages} ||= [];
  $template->{wiki_pages} = $prop->{wiki_pages};

  $prop->{menu} ||= [];
  $template->{menu} = $prop->{menu};

  $prop->{menu_file} ||= [];
  $template->{menu_file} = $prop->{menu_file};

  # $prop->{wiki_pem_file} ||= undef;
  # $template->{wiki_pem_file} = $prop->{wiki_pem_file};
}

sub post_configure_hook {
  my $self = shift;
  $self->write_help if $ARGV[0] eq '--help';

  $DataDir = $self->{server}->{wiki_dir} || $ENV{WikiDataDir} || '/tmp/oddmuse';

  $self->log(3, "PID $$");
  $self->log(3, "Host " . ("@{$self->{server}->{host}}" || "*"));
  $self->log(3, "Port @{$self->{server}->{port}}");

  # Note: if you use sudo to run gopher-server.pl, these options might not work!
  $self->log(4, "--wikir_dir says $self->{server}->{wiki_dir}\n");
  $self->log(4, "\$WikiDataDir says $ENV{WikiDataDir}\n");
  $self->log(3, "Wiki data dir is $DataDir\n");

  $RunCGI = 0;
  my $wiki = $self->{server}->{wiki} || "./wiki.pl";
  $self->log(1, "Running $wiki\n");
  unless (my $return = do $wiki) {
    $self->log(1, "couldn't parse wiki library $wiki: $@") if $@;
    $self->log(1, "couldn't do wiki library $wiki: $!") unless defined $return;
    $self->log(1, "couldn't run wiki library $wiki") unless $return;
  }

  # make sure search is sorted newest first because NewTagFiltered resorts
  *OldGopherFiltered = \&Filtered;
  *Filtered = \&NewGopherFiltered;
  *ReportError = sub {
    my ($error, $status, $log, @html) = @_;
    $self->print_error("Error: $error");
    map { ReleaseLockDir($_); } keys %Locks;
    exit 2;
  };
}

my $usage = << 'EOT';
This server serves a wiki as a gopher site.

It implements Net::Server and thus all the options available to
Net::Server are also available here. Additional options are available:

wiki       - this is the path to the Oddmuse script
wiki_dir   - this is the path to the Oddmuse data directory
wiki_pages - this is a page to show on the entry menu
menu       - this is the description of a gopher menu to prepend
menu_file  - this is the filename of the gopher menu to prepend
wiki_cert_file - the filename containing a certificate in PEM format
wiki_key_file - the filename containing a private key in PEM format

For many of the options, more information can be had in the Net::Server
documentation. This is important if you want to daemonize the server. You'll
need to use --pid_file so that you can stop it using a script, --setsid to
daemonize it, --log_file to write keep logs, and you'll need to set the user or
group using --user or --group such that the server has write access to the data
directory.

For testing purposes, you can start with the following:

--port=7070
    The port to listen to, defaults to a random port.
--log_level=4
    The log level to use, defaults to 2.
--wiki_dir=/var/oddmuse
    The wiki directory, defaults to the value of the "WikiDataDir" environment
    variable or "/tmp/oddmuse".
--wiki_lib=/home/alex/src/oddmuse/wiki.pl
    The Oddmuse main script, defaults to "./wiki.pl".
--wiki_pages=SiteMap
    This adds a page to the main index. Can be used multiple times.
--help
    Prints this message.

Example invocation:

/home/alex/src/oddmuse/stuff/gopher-server.pl \
    --port=7070 \
    --wiki=/home/alex/src/oddmuse/wiki.pl \
    --pid_file=/tmp/oddmuse/gopher.pid \
    --wiki_dir=/tmp/oddmuse \
    --wiki_pages=Homepage \
    --wiki_pages=Gopher

Run the script and test it:

echo | nc localhost 7070
lynx gopher://localhost:7070

If you want to use SSL, you need to provide PEM files containing certificate and
private key. To create self-signed files, for example:

openssl req -new -x509 -days 365 -nodes -out \
        gopher-server-cert.pem -keyout gopher-server-key.pem

Make sure the common name you provide matches your domain name!

Note that parameters should not contain spaces. Thus:

/home/alex/src/oddmuse/stuff/gopher-server.pl \
    --port=7070 \
    --log_level=3 \
    --wiki=/home/alex/src/oddmuse/wiki.pl \
    --wiki_dir=/home/alex/alexschroeder \
    --menu=Moku_Pona_Updates \
    --menu_file=~/.moku-pona/updates.txt \
    --menu=Moku_Pona_Sites \
    --menu_file=~/.moku-pona/sites.txt

EOT

run();

sub NewGopherFiltered {
  my @pages = OldGopherFiltered(@_);
  @pages = sort newest_first @pages;
  return @pages;
}

sub normal_to_free {
  my $title = shift;
  $title =~ s/_/ /g;
  return $title;
}

sub free_to_normal {
  my $title = shift;
  $title =~ s/^ +//g;
  $title =~ s/ +$//g;
  $title =~ s/ +/_/g;
  return $title;
}

sub print_text {
  my $self = shift;
  my $text = shift;
  print($text); # bytes
}

sub print_menu {
  my $self = shift;
  my $display = shift;
  my $selector = shift;
  my $host = shift
      || $self->{server}->{host}->[0]
      || $self->{server}->{sockaddr};
  my $port = shift
      || $self->{server}->{port}->[0]
      || $self->{server}->{sockport};
  my $encoded = shift;

  $selector = join('/', map { UrlEncode($_) } split(/\//, $selector)) unless $encoded;
  $self->print_text(join("\t", $display, $selector, $host, $port)
		    . "\r\n");
}

sub print_info {
  my $self = shift;
  my $info = shift;
  $self->print_menu("i$info", "");
}

sub print_error {
  my $self = shift;
  my $error = shift;
  $self->print_menu("3$error", "");
}

sub serve_main_menu {
  my $self = shift;
  my $more = shift;
  $self->log(3, "Serving main menu");
  $self->print_info("Welcome to the Gopher version of this wiki.");
  $self->print_info("");

  $self->print_info("Phlog:");
  my @pages = sort { $b cmp $a } grep(/^\d\d\d\d-\d\d-\d\d/, @IndexList);
  # we should check for pages marked for deletion!
  for my $id (@pages[0..9]) {
    $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
  }
  $self->print_menu("1" . "More...", "do/more");
  $self->print_info("");

  for my $id (@{$self->{server}->{wiki_pages}}) {
    $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
  }

  for my $id (@{$self->{server}->{menu}}) {
    $self->print_menu("1" . normal_to_free($id), "map/" . free_to_normal($id));
  }

  $self->print_menu("1" . "Recent Changes", "do/rc");
  $self->print_menu("0" . "Gopher RSS", "do/rss");
  $self->print_menu("7" . "Find matching page titles", "do/match");
  $self->print_menu("7" . "Full text search", "do/search");
  $self->print_menu("1" . "Index of all pages", "do/index");

  if ($TagFile) {
    $self->print_menu("1" . "Index of all tags", "do/tags");
  }

  if ($EditAllowed and not IsFile($NoEditFile)) {
    $self->print_menu("w" . "New page", "do/new");
  }
}

sub serve_phlog_archive {
  my $self = shift;
  $self->log(3, "Serving phlog archive");
  my @pages = sort { $b cmp $a } grep(/^\d\d\d\d-\d\d-\d\d/, @IndexList);
  for my $id (@pages) {
    $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
  }
}

sub serve_index {
  my $self = shift;
  $self->log(3, "Serving index of all pages");
  for my $id (sort newest_first @IndexList) {
    $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
  }
}

sub serve_match {
  my $self = shift;
  my $match = shift;
  $self->log(3, "Serving pages matching " . UrlEncode($match));
  $self->print_info("Use a regular expression to match page titles.");
  $self->print_info("Spaces in page titles are underlines, '_'.");
  for my $id (sort newest_first grep(/$match/i, @IndexList)) {
    $self->print_menu( "1" . normal_to_free($id), free_to_normal($id) . "/menu");
  }
}

sub serve_search {
  my $self = shift;
  my $str = shift;
  $self->log(3, "Serving search result for " . UrlEncode($str));
  $self->print_info("Use regular expressions separated by spaces.");
  SearchTitleAndBody($str, sub {
    my $id = shift;
    $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
  });
}

sub serve_tags {
  my $self = shift;
  $self->log(3, "Serving tag cloud");
  # open the DB file
  my %h = TagReadHash();
  my %count = ();
  foreach my $tag (grep !/^_/, keys %h) {
    $count{$tag} = @{$h{$tag}};
  }
  foreach my $id (sort { $count{$b} <=> $count{$a} } keys %count) {
    $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/tag");
  }
}

sub serve_rc {
  my $self = shift;
  my $showedit = $ShowEdits = shift;
  $self->log(3, "Serving recent changes"
	     . ($showedit ? " including minor changes" : ""));

  $self->print_info("Recent Changes");
  if ($showedit) {
    $self->print_menu("1" . "Skip minor edits", "do/rc");
  } else {
    $self->print_menu("1" . "Show minor edits", "do/rc/showedits");
  }

  ProcessRcLines(
    sub {
      my $date = shift;
      $self->print_info("");
      $self->print_info("$date");
      $self->print_info("");
    },
    sub {
        my($id, $ts, $author_host, $username, $summary, $minor, $revision,
	   $languages, $cluster, $last) = @_;
	$self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
	for my $line (split(/\n/, wrap('    ', '  ', $summary))) {
	  $self->print_info($line);
	}
    });
}

sub serve_rss {
  my $self = shift;
  $self->log(3, "Serving Gopher RSS");
  my $host = shift
      || $self->{server}->{host}->[0]
      || $self->{server}->{sockaddr};
  my $port = shift
      || $self->{server}->{port}->[0]
      || $self->{server}->{sockport};
  my $gopher = "gopher://$host:$port/"; # use gophers for TLS?
  local $ScriptName = $gopher;
  my $rss = GetRcRss();
  $rss =~ s!$ScriptName\?action=rss!${gopher}1do/rss!g;
  $rss =~ s!$ScriptName\?action=history;id=([^[:space:]<]*)!${gopher}1$1/history!g;
  $rss =~ s!$ScriptName/([^[:space:]<]*)!${gopher}0$1!g;
  $rss =~ s!<wiki:diff>.*</wiki:diff>\n!!g;
  print $rss;
}

sub serve_map {
  my $self = shift;
  my $id = shift;
  $self->log(3, "Serving map " . UrlEncode($id));
  my @menu = @{$self->{server}->{menu}};
  my $i = first { $id eq $menu[$_] } 0..$#menu;
  my $file = $self->{server}->{menu_file}->[$i];
  if (-f $file and open(my $fh, '<:encoding(UTF-8)', $file)) {
    local $/ = undef;
    my $text = <$fh>;
    $self->log(4, "Map has " . length($text) . " characters");
    $self->print_text($text);
  } else {
    $self->log(1, "Error reading $file");
  }
}

sub serve_page_comment_link {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  if (not $revision and $CommentsPattern) {
    if ($id =~ /$CommentsPattern/) {
      my $original = $1;
      # sometimes we are on a comment page and cannot derive the original
      $self->print_menu("1" . "Back to the original page",
		 "$original/menu") if $original;
      $self->print_menu("w" . "Add a comment", free_to_normal($id) . "/append/text");
    } else {
      my $comments = free_to_normal($CommentsPrefix . $id);
      $self->print_menu("1" . "Comments on this page", "$comments/menu");
    }
  }
}

sub serve_page_history_link {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  if (not $revision) {
    $self->print_menu("1" . "Page History", free_to_normal($id) . "/history");
  }
}

sub serve_file_page_menu {
  my $self = shift;
  my $id = shift;
  my $type = shift;
  my $revision = shift;
  my $code = substr($type, 0, 6) eq 'image/' ? 'I' : '9';
  $self->log(3, "Serving file page menu for " . UrlEncode($id));
  $self->print_menu($code . normal_to_free($id)
	     . ($revision ? "/$revision" : ""), free_to_normal($id));
  $self->serve_page_comment_link($id, $revision);
  $self->serve_page_history_link($id, $revision);
}

sub serve_text_page_menu {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  my $revision = shift;
  $self->log(3, "Serving text page menu for $id"
	     . ($revision ? "/$revision" : ""));

  $self->print_info("The text of this page:");
  $self->print_menu("0" . normal_to_free($id),
		    free_to_normal($id) . ($revision ? "/$revision" : ""));
  $self->print_menu("h" . normal_to_free($id),
		    free_to_normal($id) . ($revision ? "/$revision" : "") . "/html");
  $self->print_menu("w" . "Replace " . normal_to_free($id),
		    free_to_normal($id) . "/write/text");

  $self->serve_page_comment_link($id, $revision);
  $self->serve_page_history_link($id, $revision);

  my $first = 1;
  while ($page->{text} =~ /
	 \[\[ (?<title>[^\]|]*) (?:\|(?<text>[^\]]*))? \]\]
	 | \[ (?<url>https?:\/\/\S+) \s+ (?<text>[^\]]*) \]
	 | (?<url>https?:\/\/\S+)
	 | \[ (?<text>[^\]]*) \] \( (?<url>https?:\/\/\S+) \)
	 | \[ gophers?:\/\/ (?<hostname>[^:\/]*) (?::(?<port>\d+))?
	      (?:\/(?<type>\d)? (?<selector>\S+))? \]
	 | \[ gophers?:\/\/ (?<hostname>[^:\/]*) (?::(?<port>\d+))?
	      (?:\/(?<type>\d)? (?<selector>\S+))?
              \s+ (?<text>[^\]]+) \]
	 | \[ (?<text>[^\]]+) \]
           \( gophers?:\/\/ (?<hostname>[^:\/]*) (?::(?<port>\d+))?
	      (?:\/(?<type>\d)? (?<selector>\S+))? \)
	 /xg) {
    # remember $type can be "0" and thus "false" -- use // and defined instead!
    my ($title, $text, $url, $hostname,
	$port, $type, $selector)
	= ($+{title}, $+{text}, $+{url}, $+{hostname},
	   $+{port}||70, $+{type}//1, $+{selector});
    $title =~ s/\n/ /g;
    $text =~ s/\n/ /g;
    if ($first) {
      $self->print_info("");
      $self->print_info("Links leaving " . normal_to_free($id) . ":");
      $first = 0;
    }
    if ($hostname and $text) {
      $self->print_text(join("\t", $type . $text, $selector, $hostname, $port) . "\r\n");
    } elsif ($hostname and $selector) {
      $self->print_text(join("\t", "$type$hostname:$port/$type$selector", $selector, $hostname, $port) . "\r\n");
    } elsif ($hostname) {
      $self->print_text(join("\t", "1$hostname:$port", $selector, $hostname, $port) . "\r\n");
    } elsif ($url and $text) {
      $self->print_menu("h$text", "URL:" . $url, undef, undef, 1);
    } elsif ($url) {
      $self->print_menu("h$url", "URL:" . $url, undef, undef, 1);
    } elsif ($title and substr($title, 0, 4) eq 'tag:') {
      $self->print_menu("1" . ($text||substr($title, 4)),
			free_to_normal(substr($title, 4)) . "/tag");
    } elsif ($title =~ s!^image[/a-z]* external:!pics/!) {
      $self->print_menu("I" . $text||$title, $title); # do not normalize space
    } elsif ($title) {
      $title =~ s!^image[/a-z]*:!!i;
      $self->print_menu("1" . ($text||$title), free_to_normal($title) . "/menu");
    }
  }

  $first = 1;
  while ($page->{text} =~ /\[https?:\/\/gopher\.floodgap\.com\/gopher\/gw\?a=gopher%3a%2f%2f(.*?)(?:%3a(\d+))?%2f(.)(\S+)\s+([^\]]+)\]/gi) {
    my ($hostname, $port, $type, $selector, $text) = ($1, $2||"70", $3, $4, $5);
    if ($first) {
      $self->print_info("");
      $self->print_info("Gopher links (via Floodgap):");
      $first = 0;
    }
    $selector =~ s/%([0-9a-f][0-9a-f])/chr(hex($1))/eig; # url unescape
    $self->print_text(join("\t", $type . $text, $selector, $hostname, $port)
		      . "\r\n");
  }

  if ($page->{text} =~ m/<journal search tag:(\S+)>\s*/) {
    my $tag = $1;
    $self->print_info("");
    $self->serve_tag_list($tag);
  }
}

sub serve_page_history {
  my $self = shift;
  my $id = shift;
  $self->log(3, "Serving history of " . UrlEncode($id));
  OpenPage($id);

  $self->print_menu("1" . normal_to_free($id) . " (current)", free_to_normal($id) . "/menu");
  $self->print_info(CalcTime($Page{ts})
      . " by " . GetAuthor($Page{username})
      . ($Page{summary} ? ": $Page{summary}" : "")
      . ($Page{minor} ? " (minor)" : ""));

  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my $keep = GetKeptRevision($revision);
    $self->print_menu("1" . normal_to_free($id) . " ($keep->{revision})",
		      free_to_normal($id) . "/$keep->{revision}/menu");
    $self->print_info(CalcTime($keep->{ts})
	. " by " . GetAuthor($keep->{username})
	. ($keep->{summary} ? ": $keep->{summary}" : "")
	. ($keep->{minor} ? " (minor)" : ""));
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
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);

  if (my ($type) = TextIsFile($page->{text})) {
    $self->serve_file_page_menu($id, $type, $revision);
  } else {
    $self->serve_text_page_menu($id, $page, $revision);
  }
}

sub serve_file_page {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  $self->log(3, "Serving " . UrlEncode($id) . " as file");
  my ($encoded) = $page->{text} =~ /^[^\n]*\n(.*)/s;
  $self->log(4, UrlEncode($id) . " has " . length($encoded)
	     . " bytes of MIME encoded data");
  my $data = decode_base64($encoded);
  $self->log(4, UrlEncode($id) . " has " . length($data)
	     . " bytes of binary data");
  binmode(STDOUT, ":raw");
  print($data);
}

sub serve_text_page {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  my $text = $page->{text};
  $text =~ s/^\./../mg;
  $text =~ s/\[\[tag:([^]]+)\]\]/'#' . join('_', split(' ', $1))/mge;
  $self->log(3, "Serving " . UrlEncode($id) . " as " . length($text)
	     . " bytes of text");
  $self->print_text($text);
}

sub serve_page {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);
  if (my ($type) = TextIsFile($page->{text})) {
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

  $self->log(3, "Serving " . UrlEncode($id) . " as HTML");

  my $title = normal_to_free($id);
  print GetHtmlHeader(Ts('%s:', $SiteName) . ' ' . UnWiki($title), $id);
  print GetHeaderDiv($id, $title);
  print $q->start_div({-class=>'wrapper'});

  if ($revision) {
    # no locking of the file, no updating of the cache
    PrintWikiToHTML($page->{text});
  } else {
    PrintPageHtml();
  }
  PrintFooter($id, $revision);
}

sub serve_redirect {
  my $self = shift;
  my $url = shift;
  print qq{<!DOCTYPE HTML>
<html lang="en-US">
<head>
<meta http-equiv="refresh" content="0; url=$url">
<title>Redirection</title>
</head>
<body>
If you are not redirected automatically, follow this <a href='$url'>link</a>.
</body>
</html>
};
}

sub serve_image {
  my $self = shift;
  my $pic = shift;
  my $file = $external_image_path . $pic;
  # no tricks
  if ($file !~ /\.\./ and $file !~ /\/\//
      and -f $file and open(my $fh, "<", $file)) {
    local $/ = undef;
    my $data = <$fh>;
    $self->log(4, $pic . " has " . length($data)
	       . " bytes of binary data");
    binmode(STDOUT, ":raw");
    print($data);
  } else {
    $self->log(1, "Error reading $file: $!");
  }
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
  $self->print_info("Search result for tag $tag:");
  for my $id (sort newest_first TagFind($tag)) {
    $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
  }
}

sub serve_tag {
  my $self = shift;
  my $tag = shift;
  $self->log(3, "Serving tag " . UrlEncode($tag));
  if ($IndexHash{$tag}) {
    $self->print_info("This page is about the tag $tag.");
    $self->print_menu("1" . normal_to_free($tag), free_to_normal($tag) . "/menu");
    $self->print_info("");
  }
  $self->serve_tag_list($tag);
}

sub serve_error {
  my $self = shift;
  my $id = shift;
  my $error = shift;
  $self->log(3, "Error ('" . UrlEncode($id) . "'): $error");
  $self->print_error("Error ('" . UrlEncode($id) . "'): $error");
}

sub write_help {
  my $self = shift;
  my @lines = split(/\n/, <<"EOF");
This is how your document should start:
```
username: Alex Schroeder
summary: typo fixed
```
This is the text of your document.
Just write whatever.

Note the space after the colon for metadata fields.
More metadata fields are allowed:
`minor` is 1 if this is a minor edit. The default is 0.
EOF
  for my $line (@lines) {
    $self->print_info($line);
  }
}

sub write_page_ok {
  my $self = shift;
  my $id = shift;
  $self->print_info("Page was saved.");
  $self->print_menu("1" . normal_to_free($id), free_to_normal($id) . "/menu");
}

sub write_page_error {
  my $self = shift;
  my $error = shift;
  $self->log(4, "Not saved: $error");
  $self->print_error("Page was not saved: $error");
  map { ReleaseLockDir($_); } keys %Locks;
}

sub write_data {
  my $self = shift;
  my $id = shift;
  my $data = shift;
  my $param = shift||'text';
  SetParam($param, $data);
  my $error;
  eval {
    local *ReBrowsePage = sub {};
    local *ReportError = sub { $error = shift };
    DoPost($id);
  };
  if ($error) {
    $self->write_page_error($error);
  } else {
    $self->write_page_ok($id);
  }
}

sub write_file_page {
  my $self = shift;
  my $id = shift;
  my $data = shift;
  my $type = shift || 'application/octet-stream';
  $self->write_page_error("page title is missing") unless $id;
  $self->log(3, "Posting " . length($data) . " bytes of $type to page "
	     . UrlEncode($id));
  # no metadata
  $self->write_data($id, "#FILE $type\n" . encode_base64($data));
}

sub write_text {
  my $self = shift;
  my $id = shift;
  my $data = shift;
  my $param = shift;

  utf8::decode($data);

  my ($lead, $meta, $text) = split(/^```\s*(?:meta)?\n/m, $data, 3);

  if (not $lead and $meta) {
    while ($meta =~ /^([a-z-]+): (.*)/mg) {
      if ($1 eq 'minor' and $2) {
	SetParam('recent_edit', 'on'); # legacy UseMod parameter name
      } else {
	SetParam($1, $2);
	if ($1 eq "title") {
	  $id = $2;
	}
      }
    }
    $self->log(3, ($param eq 'text' ? "Posting" : "Appending")
	       . " " . length($text) . " characters (with metadata) to page $id");
    $self->write_data($id, $text, $param);
  } else {
    # no meta data
    $self->log(3, ($param eq 'text' ? "Posting" : "Appending")
	       . " " . length($data) . " characters to page $id") if $id;
    $self->write_data($id, $data, $param);
  }
}

sub write_text_page {
  my $self = shift;
  $self->write_text(@_, 'text');
}

sub append_text_page {
  my $self = shift;
  $self->write_text(@_, 'aftertext');
}

sub read_file {
  my $self = shift;
  my $length = shift;
  $length = $MaxPost if $length > $MaxPost;
  local $/ = \$length;
  my $buf .= <STDIN>;
  $self->log(4, "Received " . length($buf) . " bytes (max is $MaxPost)");
  return $buf;
}

sub read_text {
  my $self = shift;
  my $buf;
  while (1) {
    my $line = <STDIN>;
    if (length($line) == 0) {
      sleep(1); # wait for input
      next;
    }
    last if $line =~ /^.\r?\n/m;
    $buf .= $line;
    if (length($buf) > $MaxPost) {
      $buf = substr($buf, 0, $MaxPost);
      last;
    }
  }
  $self->log(4, "Received " . length($buf) . " bytes (max is $MaxPost)");
  utf8::decode($buf);
  $self->log(4, "Received " . length($buf) . " characters");
  return $buf;
}

sub allow_deny_hook {
  my $self = shift;
  my $client = shift;

  # clear cookie, read config file
  $q = undef;
  Init();

  # don't do surge protection if we're testing
  return 1 unless $SurgeProtection;

  # get the client IP number
  my $peeraddr = $self->{server}->{'peeraddr'};

  # implement standard surge protection using Oddmuse tools but without using
  # ReportError and all that
  $self->log(4, "Adding visitor $peeraddr");
  ReadRecentVisitors();
  AddRecentVisitor($peeraddr);
  if (RequestLockDir('visitors')) { # not fatal
    WriteRecentVisitors();
    ReleaseLockDir('visitors');
    my @entries = @{$RecentVisitors{$peeraddr}};
    my $ts = $entries[$SurgeProtectionViews];
    if (($Now - $ts) < $SurgeProtectionTime) {
      $self->log(2, "Too many requests by $peeraddr");
      return 0;
    }
  }
  return 1;
}

sub process_request {
  my $self = shift;

  # refresh list of pages
  if (IsFile($IndexFile) and ReadIndex()) {
    # we're good
  } else {
    RefreshIndex();
  }

  eval {
    local $SIG{'ALRM'} = sub {
      $self->log(1, "Timeout!");
      die "Timed Out!\n";
    };
    alarm(10); # timeout
    my $selector = <STDIN>; # no loop
    $selector = UrlDecode($selector); # assuming URL-encoded UTF-8
    $selector =~ s/\s+$//g; # no trailing whitespace

    if (not $selector or $selector eq "/") {
      $self->serve_main_menu();
    } elsif ($selector eq "do/more") {
      $self->serve_phlog_archive();
    } elsif ($selector eq "do/index") {
      $self->serve_index();
    } elsif (substr($selector, 0, 9) eq "do/match\t") {
      $self->serve_match(substr($selector, 9));
    } elsif (substr($selector, 0, 10) eq "do/search\t") {
      $self->serve_search(substr($selector, 10));
    } elsif ($selector eq "do/tags") {
      $self->serve_tags();
    } elsif ($selector eq "do/rc") {
      $self->serve_rc(0);
    } elsif ($selector eq "do/rss") {
      $self->serve_rss(0);
    } elsif ($selector eq "do/rc/showedits") {
      $self->serve_rc(1);
    } elsif ($selector eq "do/new") {
      my $data = $self->read_text();
      $self->write_text_page(undef, $data);
    } elsif ($selector =~ m!^([^/]*)/(\d+)/menu$!) {
      $self->serve_page_menu($1, $2);
    } elsif ($selector =~ m!^map/(.*)!) {
      $self->serve_map($1);
    } elsif (substr($selector, -5) eq '/menu') {
      $self->serve_page_menu(substr($selector, 0, -5));
    } elsif ($selector =~ m!^([^/]*)/tag$!) {
      $self->serve_tag($1);
    } elsif ($selector =~ m!^([^/]*)(?:/(\d+))?/html!) {
      $self->serve_page_html($1, $2);
    } elsif ($selector =~ m!^([^/]*)/history$!) {
      $self->serve_page_history($1);
    } elsif ($selector =~ m!^([^/]*)/write/text$!) {
      my $data = $self->read_text();
      $self->write_text_page($1, $data);
    } elsif ($selector =~ m!^([^/]*)/append/text$!) {
      my $data = $self->read_text();
      $self->append_text_page($1, $data);
    } elsif ($selector =~ m!^([^/]*)(?:/([a-z]+/[-a-z]+))?/write/file(?:\t(\d+))?$!) {
      my $data = $self->read_file($3);
      $self->write_file_page($1, $data, $2);
    } elsif ($selector =~ m!^([^/]*)(?:/(\d+))?(?:/text)?$!) {
      $self->serve_page($1, $2);
    } elsif ($selector =~ m!^URL:(.*)!i) {
      $self->serve_redirect(UrlDecode($1));
    } elsif ($selector =~ m!^pics/(.*)!i) {
      $self->serve_image(UrlDecode($1));
    } else {
      $self->serve_error($selector, ValidId($selector)||'Cause unknown');
    }

    $self->log(4, "Done");
  }
}
