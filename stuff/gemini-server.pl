#!/usr/bin/env perl
# Copyright (C) 2017–2020  Alex Schroeder <alex@gnu.org>

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

=head1 Gemini Server

This server serves a wiki as a gemini site.

It implements L<Net::Server> and thus all the options available to
C<Net::Server> are also available here. Additional options are available:

    wiki           - the path to the Oddmuse script
    wiki_dir       - the path to the Oddmuse data directory
    wiki_pages     - a page to show on the entry menu
    wiki_cert_file - the filename containing a certificate in PEM format
    wiki_key_file  - the filename containing a private key in PEM format

For many of the options, more information can be had in the C<Net::Server>
documentation. This is important if you want to daemonize the server. You'll
need to use C<--pid_file> so that you can stop it using a script, C<--setsid> to
daemonize it, C<--log_file> to write keep logs, and you'll need to set the user
or group using C<--user> or C<--group> such that the server has write access to
the data directory.

For testing purposes, you can start with the following:

    --port=2000
	The port to listen to, defaults to 1965
    --log_level=4
	The log level to use, defaults to 2
    --wiki_dir=/var/oddmuse
	The wiki directory, defaults to the value of the "WikiDataDir"
	environment variable or "/tmp/oddmuse"
    --wiki_lib=/home/alex/src/oddmuse/wiki.pl
	The Oddmuse main script, defaults to "./wiki.pl"
    --wiki_pages=HomePage
	This adds a page to the main index; can be used multiple times
    --wiki_cert_file=cert.pem
    --wiki_key_file=key.pem
        These two options are mandatory for TLS support
    --help
	Prints this message

You need to provide PEM files containing certificate and private key. To create
self-signed files, use the following:

    openssl req -new -x509 -days 365 -nodes -out \
	    cert.pem -keyout key.pem

Example invocation:

    /home/alex/src/oddmuse/stuff/gemini-server.pl \
	--wiki=/home/alex/src/oddmuse/wiki.pl \
	--wiki_dir=/tmp/oddmuse \
	--wiki_pages=HomePage \
	--wiki_pages=Gemini \
        --wiki_cert_file=cert.pem \
        --wiki_key_file=key.pem \
        --log_level=4

Run the script and test it:

    (sleep 1; echo gemini://localhost) | gnutls-cli localhost:1965

You should see something like the following, after a lot of C<gnutls-cli>
output:

    20 text/gemini; charset=UTF-8
    Welcome to the Gemini version of this wiki.

=cut

package OddMuse;
use utf8;
use strict;
use 5.26.0;
use base qw(Net::Server::Fork); # any personality will do
use List::Util qw(first min);
use Term::ANSIColor;
use MIME::Base64;
use Pod::Text;
use Socket;

our ($RunCGI, $DataDir, %IndexHash, @IndexList, $IndexFile, $TagFile, $q, %Page,
     $OpenPageName, $MaxPost, $ShowEdits, %Locks, $CommentsPattern,
     $CommentsPrefix, $EditAllowed, $NoEditFile, $SiteName, $ScriptName, $Now,
     %RecentVisitors, $SurgeProtectionTime, $SurgeProtectionViews,
     $SurgeProtection, @UploadTypes, $UploadAllowed, $FullUrlPattern,
     $FreeLinkPattern, @QuestionaskerQuestions, $SiteDescription, $HomePage,
     $LastUpdate, $RssExclude, $RssStyleSheet, $RssRights, $RssLicense);

# Gemini server stuff
our (@extensions, @main_menu_links);

# Help
if ($ARGV[0] eq '--help') {
  my $parser = Pod::Text->new();
  $parser->parse_file($0);
  exit;
}

# Sadly, we need this information before doing anything else
my %args = (proto => 'ssl');
for (grep(/--wiki_(key|cert)_file=/, @ARGV)) {
  $args{SSL_cert_file} = $1 if /--wiki_cert_file=(.*)/;
  $args{SSL_key_file} = $1 if /--wiki_key_file=(.*)/;
}
if (not @ARGV) {
  return 1;
} elsif (not $args{SSL_cert_file} or not $args{SSL_key_file}) {
  die "I must have both --wiki_key_file and --wiki_cert_file\n";
} else {
  OddMuse->run(%args);
}

sub default_values {
  return {
    host => 'localhost',
    port => 1965,
  };
}

sub options {
  my $self     = shift;
  my $prop     = $self->{'server'};
  my $template = shift;

  # setup options in the parent classes
  $self->SUPER::options($template);

  $prop->{wiki} ||= undef;
  $template->{wiki} = \$prop->{wiki};

  $prop->{wiki_dir} ||= undef;
  $template->{wiki_dir} = \$prop->{wiki_dir};

  $prop->{wiki_pages} ||= [];
  $template->{wiki_pages} = $prop->{wiki_pages};
}

sub post_configure_hook {
  my $self = shift;

  $DataDir = $self->{server}->{wiki_dir} || $ENV{WikiDataDir} || '/tmp/oddmuse';

  $self->log(3, "PID $$");
  $self->log(3, "Host " . ("@{$self->{server}->{host}}" || "*"));
  $self->log(3, "Port @{$self->{server}->{port}}");

  # Note: if you use sudo to run gemini-server.pl, these options might not work!
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
  *OldGeminiFiltered = \&Filtered;
  *Filtered = \&NewGeminiFiltered;
  *ReportError = sub {
    my ($error, $status, $log, @html) = @_;
    say("⚠ Error: $error");
    map { ReleaseLockDir($_); } keys %Locks;
    exit 2;
  };
}

run();

sub NewGeminiFiltered {
  my @pages = OldGeminiFiltered(@_);
  @pages = sort newest_first @pages;
  return @pages;
}

sub success {
  my $self = shift;
  my $type = shift || 'text/gemini; charset=UTF-8';
  my $lang = shift;
  if ($lang) {
    print "20 $type; lang=$lang\r\n";
  } else {
    print "20 $type\r\n";
  }
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

sub host {
  my $self = shift;
  return $self->{server}->{host}->[0]
      || $self->{server}->{sockaddr};
}

sub port {
  my $self = shift;
  return $self->{server}->{port}->[0]
      || $self->{server}->{sockport};
}

sub base {
  my $self = shift;
  my $host = $self->host();
  my $port = $self->port();
  return "gemini://$host:$port/";
}

sub base_re {
  my $self = shift;
  my $host = $self->host();
  my $port = $self->port();
  return "(gemini|titan)://$host:$port/";
}

sub link {
  my $self = shift;
  my $id = shift;
  # don't encode the slash
  return $self->base() . join("/", map { UrlEncode($_) } split (/\//, $id));
}

sub print_link {
  my $self = shift;
  my $title = shift;
  my $id = shift;
  my $url = $self->link($id);
  print "=> $url $title\n";
}

sub gemini_link {
  my $self = shift;
  my $id = shift;
  my $text = shift || normal_to_free($id);
  $id = free_to_normal($id);
  $text =~ s/\s+/ /g;
  return "=> $id $text" if $id =~ /^$FullUrlPattern$/;
  my $url = $self->link($id);
  return "=> $url $text";
}

sub serve_main_menu {
  my $self = shift;
  $self->log(3, "Serving main menu");
  $self->success();
  say "Welcome to the Gemini version of this wiki.";
  say "";
  say "Blog:";
  my @pages = sort { $b cmp $a } grep(/^\d\d\d\d-\d\d-\d\d/, @IndexList);
  # we should check for pages marked for deletion!
  for my $id (@pages[0..min($#pages, 9)]) {
    $self->print_link(normal_to_free($id), free_to_normal($id));
  }
  $self->print_link("More...", "do/more");
  say "";

  for my $id (@{$self->{server}->{wiki_pages}}) {
    $self->print_link(normal_to_free($id), free_to_normal($id));
  }
  for my $link (@main_menu_links) {
    say $link;
  }

  $self->print_link("Recent Changes", "do/rc");
  $self->print_link("Search matching page names", "do/match");
  $self->print_link("Search matching page content", "do/search");
  $self->print_link("New page", "do/new");
  say "";

  $self->print_link("Index of all pages", "do/index");
  if ($TagFile) {
    $self->print_link("Index of all tags", "do/tags");
  }
}

sub serve_archive {
  my $self = shift;
  $self->success();
  $self->log(3, "Serving archive");
  my @pages = sort { $b cmp $a } grep(/^\d\d\d\d-\d\d-\d\d/, @IndexList);
  for my $id (@pages) {
    $self->print_link(normal_to_free($id), free_to_normal($id));
  }
}

sub serve_index {
  my $self = shift;
  $self->success();
  $self->log(3, "Serving index of all pages");
  for my $id (sort newest_first @IndexList) {
    $self->print_link(normal_to_free($id), free_to_normal($id));
  }
}

sub serve_match {
  my $self = shift;
  my $match = shift;
  if (not $match) {
    print("59 Search term is missing");
    return;
  }
  $self->success();
  $self->log(3, "Serving pages matching $match");
  say "# Search for $match";
  say "Use a regular expression to match page titles.";
  say "Spaces in page titles are underlines, '_'.";
  for my $id (sort newest_first grep(/$match/i, @IndexList)) {
    $self->print_link(normal_to_free($id), free_to_normal($id));
  }
}

sub serve_search {
  my $self = shift;
  my $str = shift;
  if (not $str) {
    print("59 Search term is missing");
    return;
  }
  $self->success();
  $self->log(3, "Serving search result for $str");
  say "# Search for $str";
  say "Use regular expressions separated by spaces.";
  SearchTitleAndBody($str, sub {
    my $id = shift;
    $self->print_link(normal_to_free($id), free_to_normal($id));
  });
}

sub serve_tags {
  my $self = shift;
  $self->success();
  $self->log(3, "Serving tag cloud");
  # open the DB file
  my %h = TagReadHash();
  my %count = ();
  foreach my $tag (grep !/^_/, keys %h) {
    $count{$tag} = @{$h{$tag}};
  }
  foreach my $id (sort { $count{$b} <=> $count{$a} or $a cmp $b } keys %count) {
    $self->print_link(normal_to_free($id) . " ($count{$id})", "tag/" . free_to_normal($id));
  }
}

sub serve_rc {
  my $self = shift;
  $ShowEdits = shift;
  $self->log(3, "Serving recent changes"
	     . ($ShowEdits ? " including minor changes" : ""));
  $self->success();
  say "Recent Changes";
  if ($ShowEdits) {
    $self->print_link("Skip minor edits", "do/rc");
  } else {
    $self->print_link("Show minor edits", "do/rc/minor");
  }
  $self->print_link("Show RSS", "do/rss");
  $self->print_link("Show Atom", "do/atom");
  ProcessRcLines(
    sub {
      my $date = shift;
      say "";
      say "$date";
      say "";
    },
    sub {
      my($id, $ts, $author_host, $username, $summary, $minor, $revision,
	 $languages, $cluster, $last) = @_;
      $self->print_link(normal_to_free($id), free_to_normal($id));
      say $summary if $summary;
    });
}

sub serve_rss {
  my $self = shift;
  $self->log(3, "Serving Gemini RSS");
  $self->success("application/rss+xml");
  print qq{<?xml version="1.0" encoding="UTF-8"?>\n};
  if ($RssStyleSheet =~ /\.(xslt?|xml)$/) {
    print qq{<?xml-stylesheet type="text/xml" href="$RssStyleSheet"?>\n};
  } elsif ($RssStyleSheet) {
    print qq{<?xml-stylesheet type="text/css" href="$RssStyleSheet"?>\n};
  }
  my $host = $self->host();
  my $port = $self->port();
  local $ScriptName = "gemini://$host:$port"; # no slash at the end
  print qq{<rss version="2.0"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:cc="http://web.resource.org/cc/"
  xmlns:atom="http://www.w3.org/2005/Atom">\n};
  print qq"<channel>\n";
  print qq"<docs>http://blogs.law.harvard.edu/tech/rss</docs>\n";
  my $title = QuoteHtml($SiteName) . ': ' . GetParam('title', QuoteHtml(NormalToFree($HomePage)));
  print "<title>$title</title>\n";
  print "<link>$ScriptName/do/rss</link>\n";
  print qq{<atom:link href="$ScriptName/do/rss" rel="self" type="application/rss+xml"/>\n};
  print "<description>" . QuoteHtml($SiteDescription) . "</description>\n" if $SiteDescription;
  my $date = TimeToRFC822($LastUpdate);
  print "<pubDate>$date</pubDate>\n";
  print "<lastBuildDate>$date</lastBuildDate>\n";
  print "<generator>Oddmuse</generator>\n";
  print "<copyright>$RssRights</copyright>\n" if $RssRights;
  if ($RssLicense) {
    print join('', map {"<cc:license>" . QuoteHtml($_) . "</cc:license>\n"}
		 (ref $RssLicense eq 'ARRAY' ? @$RssLicense : $RssLicense))
  }
  local *GetRcLines = defined &JournalRssGetRcLines ? \&JournalRssGetRcLines : \&GetRcLines; # with journal-rss module
  ProcessRcLines(sub {}, sub {
    my ($id, $ts, $host, $username, $summary, $minor, $revision,
	$languages, $cluster, $last) = @_;
    print "<item>\n";
    my $name = ItemName($id);
    print "<title>$name</title>\n";
    my $link = ScriptUrl(UrlEncode($id));
    print "<link>$link</link>\n";
    print "<guid>$link</guid>\n";
    OpenPage($id);
    $summary = $self->gemini_text($Page{text}); # full text
    $summary = QuoteHtml($summary);
    print "<description>$summary</description>\n" if $summary;
    my $date = TimeToRFC822($ts);
    print "<pubDate>$date</pubDate>\n";
    print "<comments>" . ScriptUrl($CommentsPrefix . UrlEncode($id)) . "</comments>\n"
	if $CommentsPattern and $id !~ /$CommentsPattern/;
    $username = QuoteHtml($username);
    print "<dc:contributor>$username</dc:contributor>\n" if $username;
    print "</item>\n"; });
  print "</channel>\n</rss>\n";
}

sub serve_atom {
  my $self = shift;
  $self->log(3, "Serving Gemini Atom");
  $self->success("application/atom+xml");
  print qq{<?xml version="1.0" encoding="UTF-8"?>\n};
  if ($RssStyleSheet =~ /\.(xslt?|xml)$/) {
    print qq{<?xml-stylesheet type="text/xml" href="$RssStyleSheet"?>\n};
  } elsif ($RssStyleSheet) {
    print qq{<?xml-stylesheet type="text/css" href="$RssStyleSheet"?>\n};
  }
  my $host = $self->host();
  my $port = $self->port();
  local $ScriptName = "gemini://$host:$port"; # no slash at the end
  say "<feed xmlns=\"http://www.w3.org/2005/Atom\">";
  my $title = QuoteHtml($SiteName) . ': ' . GetParam('title', QuoteHtml(NormalToFree($HomePage)));
  say "<title>$title</title>";
  say "<link href=\"$ScriptName/\"/>";
  say "<link rel=\"self\" type=\"application/atom+xml\" href=\"gemini://$host:$port/do/atom\"/>";
  say "<id>$ScriptName/do/atom</id>";
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($LastUpdate); # 2003-12-13T18:30:02Z
  say "<updated>"
      . sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec)
      . "</updated>";
  say "<generator uri=\"https://oddmuse.org/\" version=\"1.0\">Oddmuse</generator>";
  local *GetRcLines = defined &JournalRssGetRcLines ? \&JournalRssGetRcLines : \&GetRcLines; # with journal-rss module
  ProcessRcLines(sub {}, sub {
    my ($id, $ts, $host, $username, $summary, $minor, $revision,
	$languages, $cluster, $last) = @_;
    print "<entry>\n";
    my $name = ItemName($id);
    print "<title>$name</title>\n";
    my $link = ScriptUrl(UrlEncode($id));
    print "<link href=\"$link\"/>\n";
    print "<id>$link</id>\n";
    OpenPage($id);
    $summary = $self->gemini_text($Page{text}); # full text feed
    $summary = QuoteHtml($summary);
    print "<summary>$summary</summary>\n" if $summary;
    ($sec, $min, $hour, $mday, $mon, $year) = gmtime($ts); # 2003-12-13T18:30:02Z
    print "<updated>"
	. sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec)
	. "</updated>\n";
    $username = QuoteHtml($username);
    print "<author><name>$username</name></author>\n" if $username;
    print "</entry>\n";
		 });
  print "</feed>\n";
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

sub serve_file_page {
  my $self = shift;
  my $id = shift;
  my $type = shift;
  my $page = shift;
  $self->log(3, "Serving $id as $type file");
  my ($encoded) = $page->{text} =~ /^[^\n]*\n(.*)/s;
  my $data = decode_base64($encoded);
  $self->success($type);
  binmode(STDOUT, ":raw");
  print($data);
}

sub serve_raw_page {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  my $text = $page->{text};
  $self->log(3, "Serving the diff of $id");
  $self->success('text/plain; charset=UTF-8', $page->{languages});
  print $text;
}

sub serve_raw {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);
  if (my ($type) = TextIsFile($page->{text})) {
    $self->serve_file_page($id, $type, $page);
  } else {
    $self->serve_raw_page($id, $page);
  }
}

sub serve_diff {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $title = normal_to_free($id);
  $self->log(3, "Serving the diff of $id");
  $self->success();
  say "# Differences for $title";
  say "Showing the differences between revision $revision and the current revision of $title.";
  # Order is important because $new is a reference to %Page!
  my $new = get_page($id);
  my $old = get_page($id, $revision);
  my $new_type = TextIsFile($new->{text});
  my $old_type = TextIsFile($old->{text});
  if ($old_type) {
    say "Revision $revision is a $old_type file.";
    $self->print_link("Show revision $revision", "$id/$revision");
  }
  if ($new_type) {
    say "The current version is a $new_type file.";
    $self->print_link("Show the current revision", $id);
  }
  if (not $old_type and not $new_type) {
    say "```";
    say DoDiff($old->{text}, $new->{text});
    say "```";
  }
}

sub serve_html {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);
  $self->success('text/html');
  $self->log(3, "Serving $id as HTML");
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

sub serve_history {
  my $self = shift;
  my $id = shift;
  my $title = normal_to_free($id);
  $self->success();
  $self->log(3, "Serve history for $id");
  say "# Page history for $title";
  OpenPage($id);
  $self->print_link("$title (current)", $id);
  say(CalcTime($Page{ts})
      . " by " . GetAuthor($Page{username})
      . ($Page{summary} ? ": $Page{summary}" : "")
      . ($Page{minor} ? " (minor)" : ""));
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my $keep = GetKeptRevision($revision);
    $self->print_link("$title ($keep->{revision})", "$id/$keep->{revision}");
    $self->print_link("Diff between revision $keep->{revision} and the current one", "diff/$id/$keep->{revision}");
    say(CalcTime($keep->{ts})
	. " by " . GetAuthor($keep->{username})
	. ($keep->{summary} ? ": $keep->{summary}" : "")
	. ($keep->{minor} ? " (minor)" : ""));
  }
}

sub footer {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  my $revision = shift;
  my @links;
  if ($CommentsPattern) {
    if ($id =~ /$CommentsPattern/) {
      my $original = $1;
      # sometimes we are on a comment page and cannot derive the original
      push(@links, $self->gemini_link($original, "Back to the original page")) if $original;
      push(@links, $self->gemini_link("do/comment/$id", "Leave a comment"));
    } else {
      my $comments = free_to_normal($CommentsPrefix . $id);
      push(@links, $self->gemini_link($comments, "Comments on this page"));
    }
  }
  push(@links, $self->gemini_link("history/$id", "History"));
  push(@links, $self->gemini_link("raw/$id/$revision", "Raw text"));
  push(@links, $self->gemini_link("html/$id/$revision", "HTML"));
  return join("\n", "\n\nMore:", @links, "") if @links;
  return "";
}

sub gemini_text {
  my $self = shift;
  my $text = shift;
  # escape the preformatted blocks
  my $ref = 0;
  my @escaped;
  # newline magic: the escaped block does not include the newline; it is
  # retained in $text so that the following rules still deal with newlines
  # correctly; when we replace the escaped blocks back in, they'll be without
  # the trailing newline and fit right in.
  $text =~ s/^(```.*?\n```)\n/push(@escaped, $1); "\x03" . $ref++ . "\x04\n"/mesg;
  $self->log(4, "Escaped $ref code blocks");
  my @blocks = split(/\n\n+|\\\\|\n(?=\*)|\n(?==>)/, $text);
  for my $block (@blocks) {
    my @links;
    $block =~ s/\[([^]]+)\]\($FullUrlPattern\)/push(@links, $self->gemini_link($2, $1)); $1/ge;
    $block =~ s/\[([^]]+)\]\(([^) ]+)\)/push(@links, $self->gemini_link($2, $1)); $1/ge;
    $block =~ s/\[$FullUrlPattern\s+([^]]+)\]/push(@links, $self->gemini_link($1, $2)); $2/ge;
    $block =~ s/\[\[([a-z\/-]+):$FullUrlPattern\|([^]]+)\]\]/push(@links, $self->gemini_link($2, $3)); "｢$3｣"/ge;
    $block =~ s/\[\[tag:([^]|]+)\]\]/push(@links, $self->gemini_link("tag\/$1", $1)); $1/ge;
    $block =~ s/\[\[tag:([^]|]+)\|([^\]|]+)\]\]/push(@links, $self->gemini_link("tag\/$1", $2)); $2/ge;
    $block =~ s/<journal search tag:(\S+)>\n*/push(@links, $self->gemini_link("tag\/$1", "Explore the $1 tag")); ""/ge;
    $block =~ s/\[\[image:([^]|]+)\]\]/push(@links, $self->gemini_link($1, "$1 (image)")); "$1"/ge;
    $block =~ s/\[\[image:([^]|]+)\|([^\]|]+)\]\]/push(@links, $self->gemini_link($1, "$2 (image)")); "$2"/ge;
    $block =~ s/\[\[image:([^]|]+)\|([^\]|]*)\|([^\]|]+)\]\]/push(@links, $self->gemini_link($1, "$2 (image)"), $self->gemini_link($3, "$2 (follow-up)")); "$2"/ge;
    $block =~ s/\[\[image:([^]|]+)\|([^\]|]*)\|([^\]|]*)\|([^\]|]+)\]\]/push(@links, $self->gemini_link($1, "$2 (image)"), $self->gemini_link($3, "$4 (follow-up)")); "$2"/ge;
    $block =~ s/\[\[$FreeLinkPattern\|([^\]|]+)\]\]/push(@links, $self->gemini_link($1, $2)); $2/ge;
    $block =~ s/\[\[$FreeLinkPattern\]\]/push(@links, $self->gemini_link($1)); $1/ge;
    $block =~ s/\[color=([^]]+)\]/color($1)/ge;
    $block =~ s/\[\/color\]/color("reset")/ge;
    $block =~ s/<[a-z]+(?:\s+[a-z-]+="[^"]+")>//ge;
    $block =~ s/<\/[a-z]+>//ge;
    $block =~ s/^((?:> .*\n?)+)$/join(" ", split("\n> ", $1))/ge; # unwrap quotes
    $block =~ s/\s+/ /g; # unwrap lines
    $block =~ s/^\s+//; # trim
    $block =~ s/\s+$//; # trim
    $block .= "\n" if $block and @links; # no empty line if the block was all links
    $block .= join("\n", @links);
  }
  $text = join("\n\n", @blocks);
  $text =~ s/^(=>.*\n)\n(?==>)/$1/mg; # remove empty lines between links
  $text =~ s/^Tags: .*/Tags:/m;
  $text =~ s/\x03(\d+)\x04/$escaped[$1]/ge;
  return $text;
}

# All I have to do now is to transform the wiki text into Gemini format: Each
# line is a paragraph. A list item starts with an asterisk and a space. A link
# is a line consisting of "=>", space, URL, space, and some text.
sub serve_gemini_page {
  my $self = shift;
  my $id = shift;
  my $page = shift;
  my $revision = shift;
  $self->log(3, "Serve Gemini page $id");
  $self->success(undef, $page->{languages});
  print $self->gemini_text($page->{text});
  print $self->footer($id, $page, $revision);
}

sub serve_gemini {
  my $self = shift;
  my $id = shift;
  my $revision = shift;
  my $page = get_page($id, $revision);
  if (my ($type) = TextIsFile($page->{text})) {
    $self->serve_file_page($id, $type, $page);
  } else {
    $self->serve_gemini_page($id, $page, $revision);
  }
}

sub newest_first {
  my ($comment_a, $image_a, $date_a, $article_a) = $a =~ /^($CommentsPrefix|Image_(\d+)_for_)?(\d\d\d\d-\d\d(?:-\d\d)?_?)?(.*)/;
  my ($comment_b, $image_b, $date_b, $article_b) = $b =~ /^($CommentsPrefix)?(?:Image_(\d+)_for_)?(\d\d\d\d-\d\d(?:-\d\d)?_?)?(.*)/;
  # warn ""
  #     . ", date: ($date_b cmp $date_a) = "  . ($date_b cmp $date_a)
  #     . ", article: ($article_a cmp $article_b) = " . ($article_a cmp $article_b)
  #     . ", image: ($image_a <=> $image_b) = " . ($image_a <=> $image_b)
  #     . ", comment: ($comment_b cmp $comment_a) = " . ($comment_b cmp $comment_a)
  #     . "\n";
  return (($date_b cmp $date_a)
	  || ($article_a cmp $article_b)
	  || ($image_a <=> $image_b)
	  || ($comment_a cmp $comment_b)
	  # this last one should be unnecessary
	  || ($a cmp $b));
}

sub serve_tag_list {
  my $self = shift;
  my $tag = shift;
  print("Search result for tag $tag:\n");
  for my $id (sort newest_first TagFind($tag)) {
    $self->print_link(normal_to_free($id), free_to_normal($id));
  }
}

sub serve_tag {
  my $self = shift;
  my $tag = shift;
  $self->success();
  $self->log(3, "Serving tag $tag");
  if ($IndexHash{$tag}) {
    print("This page is about the tag $tag.\n");
    $self->print_link(normal_to_free($tag), free_to_normal($tag));
    print("\n");
  }
  $self->serve_tag_list($tag);
}

sub write {
  my $self = shift;
  my $id = shift;
  my $token = shift;
  my $data = shift;
  $self->log(3, "Writing $id");
  SetParam("title", $id);
  SetParam("text", $data);
  SetParam("answer", $token);
  SetParam("recent_edit", $IndexHash{$id} ? "on" : "");
  my $error;
  eval {
    local *ReBrowsePage = sub {};
    local *ReportError = sub { $error = shift };
    DoPost($id);
  };
  if ($error) {
    print "59 Unable to save $id: $error\r\n";
  } else {
    $self->log(3, "Wrote $id");
    print "30 " . $self->base() . UrlEncode($id) . "\r\n";
  }
}

sub write_comment {
  my $self = shift;
  my $id = shift;
  my $n = shift;
  my $a = shift;
  my $c = shift;
  my $error;
  if (not $id) {
    print "59 The URL lacks a page name\r\n";
    return;
  }
  if ($error = ValidId($id)) {
    print "59 $id is not a valid page name: $error\r\n";
    return;
  }
  if (not $c) {
    print "59 The comment is empty\r\n";
    return;
  }
  SetParam("title", $id);
  SetParam("question_num", $n);
  SetParam("answer", $a);
  SetParam("aftertext", $c);
  eval {
    local *ReBrowsePage = sub {};
    local *ReportError = sub { $error = shift };
    DoPost($id);
  };
  if ($error) {
    print "59 Unable to save comment on $id: $error\r\n";
  } else {
    print "30 " . $self->base() . UrlEncode($id) . "\r\n";
  }
}

sub write_page {
  my $self = shift;
  my $id = shift;
  my $params = shift;
  if (not $id) {
    print "59 The URL lacks a page name\r\n";
    return;
  }
  if (my $error = ValidId($id)) {
    print "59 $id is not a valid page name: $error\r\n";
    return;
  }
  my $token = $params->{token};
  # The token is going to be checked by the wiki, if at all.
  my $type = $params->{mime};
  if (not $type) {
    print "59 Uploads require a MIME type\r\n";
    return;
  } elsif ($type ne "text/plain" and (not $UploadAllowed or not grep(/$type/, @UploadTypes))) {
    print "59 This wiki does not allow $type\r\n";
    return;
  }
  my $length = $params->{size};
  if ($length > $MaxPost) {
    print "59 This wiki does not allow more than $MaxPost bytes\r\n";
    return;
  } elsif ($length !~ /^\d+$/) {
    print "59 You need to send along the number of bytes, not $length\r\n";
    return;
  }
  local $/ = undef;
  my $data;
  my $actual = read STDIN, $data, $length;
  if ($actual != $length) {
    print "59 Got $actual bytes instead of $length\r\n";
    return;
  }
  if ($type ne "text/plain") {
    $self->log(3, "Writing $type to $id, $actual bytes");
    $self->write($id, $token, "#FILE $type\n" . encode_base64($data));
    return;
  } elsif (utf8::decode($data)) {
    $self->log(3, "Writing $type to $id, $actual bytes");
    $self->write($id, $token, $data);
    return;
  } else {
    print "59 The text is invalid UTF-8\r\n";
    return;
  }
}

sub allow_deny_hook {
  my $self = shift;
  my $client = shift;
  # clear cookie, read config file
  $q = undef;
  {
    local $SIG{__WARN__} = sub {}; # sooooorryy!! 😭
    Init();
  }
  # gemini config file with extra code
  do "$DataDir/gemini_config" if -r "$DataDir/gemini_config";
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
    if ($ts and ($Now - $ts) < $SurgeProtectionTime) {
      $self->log(2, "Too many requests by $peeraddr");
      return 0;
    }
  }
  return 1;
}

sub run_extensions {
  my $self = shift;
  my $url = shift;
  my $selector = shift;
  foreach my $sub (@extensions) {
    return 1 if $sub->($self, $url, $selector);
  }
  return;
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
    my $port = $self->port();
    my $base = $self->base();
    my $base_re = $self->base_re();
    my $url = <STDIN>; # no loop
    $url =~ s/\s+$//g; # no trailing whitespace
    $url =~ s!^([^/:]+://[^/:]+)(/.*|)$!$1:$port$2!; # add port
    $url .= '/' if $url =~ m!^[^/]+://[^/]+$!; # add missing trailing slash
    my $selector = $url;
    $selector =~ s/^$base_re//;
    $selector = UrlDecode($selector);
    $self->log(3, "Looking at $url / $selector");
    my ($id, $n, $a, $c);
    if ($self->run_extensions($url, $selector)) {
      # config file goes first
    } elsif ($url =~ m"^titan://" and $selector !~ /^raw\//) {
      $self->log(3, "Cannot write $url");
      print "59 This server only allows writing of raw pages\r\n";
    } elsif ($url =~ m"^titan://") {
      if ($selector !~ m"^raw/([^/;=&]+(?:;\w+=[^;=&]+)+)") {
	print "59 The selector $selector is malformed.\r\n";
      } else {
	my ($id, %params) = split(/[;=&]/, $1);
	$self->write_page(free_to_normal($id), \%params);
      }
    } elsif ($url !~ m"^gemini://") {
      $self->log(3, "Cannot serve $url");
      print "53 This server only serves the gemini schema\r\n";
    } elsif ($url !~ m"^$base_re") {
      $self->log(3, "Cannot serve $url");
      print "53 This server only serves $base\r\n";
    } elsif (not $selector) {
      $self->serve_main_menu();
    } elsif ($selector eq "do/more") {
      $self->serve_archive();
    } elsif ($selector eq "do/index") {
      $self->serve_index();
    } elsif ($selector eq "do/match") {
      print "10 Find page by name (Perl regexp)\r\n";
    } elsif (substr($selector, 0, 9) eq "do/match?") {
      $self->serve_match(free_to_normal(substr($selector, 9))); # no spaces in page titles
    } elsif ($selector eq "do/search") {
      print "10 Find page by content (Perl regexp, use tag:foo to search for tags)\r\n";
    } elsif (substr($selector, 0, 10) eq "do/search?") {
      $self->serve_search(substr($selector, 10)); # search terms include spaces
    } elsif ($selector eq "do/new") {
      print "10 New page\r\n";
    } elsif (substr($selector, 0, 7) eq "do/new?") {
      print "30 $base" . "raw/" . UrlEncode(substr($selector, 7)) . "\r\n";
    } elsif (($id) = $selector =~ m!do/comment/([^/?]*)$!) {
      my $n = int(rand(scalar(@QuestionaskerQuestions)));
      print "30 $base" . "do/comment/" . UrlEncode($id) . "/$n\r\n";
    } elsif (($id, $n) = $selector =~ m!do/comment/([^/?]*)/(\d+)$!) {
      my $q = $QuestionaskerQuestions[$n][0];
      print "10 $q\r\n";
    } elsif (($id, $n, $a) = $selector =~ m!do/comment/([^/?]*)/(\d+)\?([^/?]*)$!) {
      if ($QuestionaskerQuestions[$n][1]($a)) {
	print "30 $base" . "do/comment/" . UrlEncode($id) . "/$n/" . UrlEncode($a) . "\r\n";
      } else {
	print "59 You did not answer correctly.\r\n";
      }
    } elsif (($id, $n, $a) = $selector =~ m!do/comment/([^/?]*)/(\d+)/([^/?]*)$!) {
      if ($QuestionaskerQuestions[$n][1]($a)) {
	print "10 Comment\r\n";
      } else {
	print "59 You did not answer correctly.\r\n";
      }
    } elsif (($id, $n, $a, $c) = $selector =~ m!do/comment/([^/?]*)/(\d+)/([^/?]*)\?([^/?]*)$!) {
      if ($QuestionaskerQuestions[$n][1]($a)) {
	$self->write_comment(free_to_normal($id), $n, $a, normal_to_free($c));
      } else {
	print "59 You did not answer correctly.\r\n";
      }
    } elsif ($selector eq "do/tags") {
      $self->serve_tags();
    } elsif ($selector eq "do/rc") {
      $self->serve_rc(0);
    } elsif ($selector eq "do/rss") {
      $self->serve_rss();
    } elsif ($selector eq "do/atom") {
      $self->serve_atom();
    } elsif ($selector eq "do/rc/minor") {
      $self->serve_rc(1);
    } elsif ($selector =~ m!^tag/([^/]*)$!) {
      $self->serve_tag($1);
    } elsif ($selector =~ m!^([^/]*\.txt)$!) {
      $self->serve_raw(free_to_normal($1));
    } elsif ($selector =~ m!^([^/]*)(?:/(\d+))?$!) {
      $self->serve_gemini(free_to_normal($1), $2);
    } elsif ($selector =~ m!^history/([^/]*)$!) {
      $self->serve_history(free_to_normal($1));
    } elsif ($selector =~ m!^diff/([^/]*)(?:/(\d+))?$!) {
      $self->serve_diff(free_to_normal($1), $2);
    } elsif ($selector =~ m!^raw/([^/]*)(?:/(\d+))?$!) {
      $self->serve_raw(free_to_normal($1), $2);
    } elsif ($selector =~ m!^html/([^/]*)(?:/(\d+))?$!) {
      $self->serve_html(free_to_normal($1), $2);
    } else {
      $self->log(3, "Unknown $selector");
      print "40 " . (ValidId(free_to_normal($selector)) || 'Cause unknown') . "\r\n";
    }
    $self->log(4, "Done");
  }
}
