#!/bin/env perl
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
use base qw(Net::Server::PreFork); # any personality will do

Oddmuse::Gopher::Server->run;
 
sub usage {
  die <<'EOT';
This server serves a wiki as a gopher site.

It implements Net::Server and thus all the options available to Net::Server are
also available here. Two additional options are available:

wiki     - this is the path to the Oddmuse script
wiki_dir - this is the path to the Oddmuse data directory

Example invocation:

/usr/bin/perl /home/alex/src/oddmuse/stuff/gopher-server.pl \
    --port=7070 \
    --pid_file=/home/alex/alexschroeder-gopher-server.pid \
    --wiki=/home/alex/farm/wiki.pl \
    --wiki_dir=/home/alex/alexschroeder

Run the script and test it:

telnet localhost 7070
lynx gopher://localhost:7070

EOT
}

sub process_request {
  my $self = shift;

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
    $id =~ s/\s+//g;
    if (not $id or $id eq '/') {
      $self->log(1, "Serving menu\n");
      for my $id (@OddMuse::IndexList) {
	print join("\t",
		   "0" . OddMuse::NormalToFree($id),
		   "$id",
		   $self->{server}->{sockaddr},
		   $self->{server}->{sockport})
	    . "\r\n";
      }
      # use Data::Dumper;
      # $self->log(1, Dumper($self->{server}));
    } elsif ($OddMuse::IndexHash{$id}) {
      $self->log(1, "Serving $id\n");
      OddMuse::OpenPage($id);
      my $text = $OddMuse::Page{text};
      $text =~ s/^\./../mg;
      print $text;
      print ".\r\n";
    } else {
      $self->log(1, "Unknown page: $id\n");
      print "3\tUnknown page: $id\n";
    }
  };
  
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
}

sub post_configure_hook {
  my $self = shift;
  usage() unless $self->{server}->{wiki} and $self->{server}->{wiki_dir};
  $self->log(1, "Wiki data dir is " . $self->{server}->{wiki_dir} . "\n");
  $OddMuse::RunCGI = 0;
  $OddMuse::DataDir = $self->{server}->{wiki_dir};
  $self->log(1, "Running " . $self->{server}->{wiki} . "\n");
  do $self->{server}->{wiki}; # do it once
  OddMuse::InitDirConfig();
}

1;
