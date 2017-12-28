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

lynx gopher://localhost:7070/1/index

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
  my @pages = sort { $b cmp $a } grep(m!^\d\d\d\d-\d\d-\d\d!, @OddMuse::IndexList);
  for my $id (@{$self->{server}->{wiki_pages}}, @pages[0..9]) {
    last unless $id;
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
  print join("\t",
	     "1" . "Index of all pages",
	     "do/index",
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";
}

sub serve_index {
  my $self = shift;
  $self->log(1, "Serving index of all pages\n");
  for my $id (@OddMuse::IndexList) {
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_file_page_menu {
  my $self = shift;
  my $id = shift;
  my $type = shift;
  my $code = substr($type, 0, 6) eq 'image/' ? 'I' : '9';
  $self->log(1, "Serving file page menu for $id\n");
  print join("\t",
	     $code . OddMuse::NormalToFree($id),
	     $id,
	     $self->{server}->{sockaddr},
	     $self->{server}->{sockport})
      . "\r\n";
}

sub serve_text_page_menu {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Serving text page menu for $id\n");
  my $text = "iThe text of this page:\r\n";
  $text .= join("\t",
		"0" . OddMuse::NormalToFree($id),
		$id,
		$self->{server}->{sockaddr},
		$self->{server}->{sockport})
      . "\r\n";
  $text .= join("\t",
		"h" . OddMuse::NormalToFree($id),
		"$id/html",
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
    $text .= "i\r\n";
    $text .= "iLinks leaving " . OddMuse::NormalToFree($id) . ":\r\n";
    for my $link (@links) {
      $text .= join("\t",
		    "1" . OddMuse::NormalToFree($link->[1]),
		    OddMuse::FreeToNormal($link->[0]),
		    $self->{server}->{sockaddr},
		    $self->{server}->{sockport})
	  . "\r\n";
    }
  } else {
    $text .= "i\r\n";
    $text .= "iThere are no links leaving this page.";
  }

  print $text;
}

sub serve_page_menu {
  my $self = shift;
  my $id = shift;
  OddMuse::OpenPage($id);
  if (my ($type) = OddMuse::TextIsFile($OddMuse::Page{text})) {
    $self->serve_file_page_menu($id, $type);
  } else {
    $self->serve_text_page_menu($id);
  }
}

sub serve_file_page {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Serving $id as file\n");
  binmode(STDOUT, ':pop:raw');
  require MIME::Base64;
  my ($data) = $OddMuse::Page{text} =~ /^[^\n]*\n(.*)/s;
  print MIME::Base64::decode($data);
  # do not append a dot, just close the connection
  exit;
}

sub serve_text_page {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Serving $id as text\n");
  my $text = $OddMuse::Page{text};
  $text =~ s/^\./../mg;
  print $text;
}

sub serve_page {
  my $self = shift;
  my $id = shift;
  OddMuse::OpenPage($id);
  if (my ($type) = OddMuse::TextIsFile($OddMuse::Page{text})) {
    $self->serve_file_page($id);
  } else {
    $self->serve_text_page($id);
  }
}

sub serve_page_html {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Serving $id as HTML\n");
  OddMuse::OpenPage($id);
  OddMuse::PrintPageHtml();
  # do not append a dot, just close the connection
  exit;
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
  print "iSearch result for tag $tag:\r\n";
  for my $id (OddMuse::TagFind($tag)) {
    print join("\t",
	       "1" . OddMuse::NormalToFree($id),
	       "$id/menu",
	       $self->{server}->{sockaddr},
	       $self->{server}->{sockport})
	. "\r\n";
  }
}

sub serve_unknown {
  my $self = shift;
  my $id = shift;
  $self->log(1, "Unknown page: $id\n");
  print "3Unknown page: $id\n";
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
    $id =~ s/\s+//g; # no whitespace in page names
    if (not $id) {
      $self->serve_main_menu();
    } elsif ($id eq "do/index") {
      $self->serve_index();
    } elsif (substr($id, -5) eq '/menu' and $OddMuse::IndexHash{substr($id, 0, -5)}) {
      $self->serve_page_menu(substr($id, 0, -5));
    } elsif (substr($id, -4) eq '/tag') {
      $self->serve_tag(substr($id, 0, -4));
    } elsif ($OddMuse::IndexHash{$id}) {
      $self->serve_page($id);
    } elsif (substr($id, -5) eq '/html') {
      $self->serve_page_html(substr($id, 0, -5));
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
}
