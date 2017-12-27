#!/bin/env perl
# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>

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
Usage: perl gopher-server.pl

Example: perl gopher-server.pl wiki.pl ~/src/oddmuse/test-data

You may provide the Oddmuse wiki script on the command line. If you do not
provide it, WIKI will default to 'wiki.pl'.

You may provide a data directory on the command line. It will be used to set the
environment variable 'WikiDataDir'. If it is not not set, Oddmuse will default
to '/tmp/oddmuse'.

Run the script and one way to test it is to use telnet:

telnet localhost 7070 /
telnet localhost 7070 /HomePage
EOT
}

sub process_request {
  my $self = shift;
  
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
    $self->log(1, "Timed Out.\r\n");
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
  $prop->{wiki} ||= './wiki.pl';
  $template->{wiki} = \ $prop->{wiki};
}

sub post_configure_hook {
  my $self = shift;
  usage() unless $self->{server}->{wiki};
  die "Must set evironment variable WikiDataDir\n" unless $ENV{WikiDataDir};
  $self->log(1, "Wiki data dir is $ENV{WikiDataDir}\n");
  $OddMuse::RunCGI = 0;
  $self->log(1, "Running " . $self->{server}->{wiki} . "\n");
  do $self->{server}->{wiki}; # do it once
  OddMuse::InitDirConfig();
}

1;
