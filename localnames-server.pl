#! /usr/bin/perl
# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use LWP::UserAgent;

my $db = 'localnames.db';
my $pwd = '5ga55b6b4aq00x192w23efrvhtg';
my $q = new CGI;
my $url = $q->param('url');
my $name = $q->param('name');

if ($q->param('list')) {
  list();
} elsif ($url and $q->param('pwd') eq $pwd) {
  redefine();
} elsif ($name) {
  resolve();
} else {
  html();
}

sub html {
  print $q->header(),
    $q->start_html('LocalNames Server'),
    $q->h1('LocalNames Server'),
    $q->p('Reads a definition of', $q->a({-href=>'http://ln.taoriver.net/about.html'}, 'local names'),
	  'from an URL and saves it.  At the same time it also offers to redirect you to the matching URL,',
	  'if you query it for a name.'),
    $q->p(q{$Id: localnames-server.pl,v 1.5 2005/01/09 23:38:09 as Exp $}),
    $q->p($q->a({-href=>$q->url . '?list=1'}, 'List of all names')),
    $q->start_form(-method=>'GET'),
    $q->p('Redefine from URL:', $q->textfield('url', '', 50)),
    $q->p('Password:', $q->textfield('pwd', '', 50)),
    $q->p('Query name: ', $q->textfield('name', '', 50)),
    $q->p($q->submit()),
    $q->end_form(),
    $q->end_html();
  exit;
}
use warnings ;
use strict ;
use DB_File ;

my %LocalNamesSeen = ();
my %LocalNames = ();

sub redefine {
  print $q->header(-type=>'text/plain; charset=UTF-8');
  unlink $db;
  tie %LocalNames, "DB_File", $db, O_RDWR|O_CREAT, 0666, $DB_HASH
    or die "Cannot open file '$db': $!\n";
  LocalNamesParseDefinition($url);
  print "Done.\n";
}

sub LocalNamesParseDefinition {
  my $url = shift;
  if (not $LocalNamesSeen{$url}) {
    $LocalNamesSeen{$url} = 1;
    print "Reading $url\n";
    my $ua = new LWP::UserAgent;
    my $response = $ua->get($url);
    die $response->status_line unless $response->is_success;
    my $data = $response->content;
    my($type, $name, $target);
    foreach my $line (split(/\n/, $data)) {
      next unless $line;                   # skip empty lines
      next if substr($line, 0, 1) eq '#';  # skip comment
      # split on whitespace, unquote if possible
      $line =~ /^(.|LN|NS|X|PATTERN)\s+(?:"(.*?)"|(\S+))\s+(?:"(.*?)"|(\S+))$/ or next;
      my ($ntype, $nname, $ntarget) = ($1, $2 || $3, $4 || $5);
      # Wherever a period is found, the value of the record's column
      # is the same as the value found in the same column in the
      # previous record.
      $type = $ntype unless $ntype eq '.';
      $name = $nname unless $nname eq '.';
      $target = $ntarget unless $ntarget eq '.';
      if ($type eq 'LN') {
	my $page = FreeToNormal($name);
	$LocalNames{$page} = $target unless $LocalNames{$page}; # use the first
      } elsif ($type eq 'NS') {
  	LocalNamesParseDefinition($target, $name);
      }
      # else do nothing -- X FINAL is not supported, because
      # undefined pages link to edit pages on the local wiki!
    }
  }
  # else do nothing -- been there before
}

sub FreeToNormal { # trim all spaces and convert them to underlines
  my $id = shift;
  return '' unless $id;
  $id =~ s/ /_/g;
  if (index($id, '_') > -1) {  # Quick check for any space/underscores
    $id =~ s/__+/_/g;
    $id =~ s/^_//;
    $id =~ s/_$//;
  }
  return $id;
}

sub resolve {
  tie %LocalNames, "DB_File", $db, O_RDWR|O_CREAT, 0666, $DB_HASH
    or die "Cannot open file '$db': $!\n";
  $name = FreeToNormal($name);
  my $target = $LocalNames{$name};
  if ($target) {
    print $q->redirect($target);
  } else {
    print $q->header(-status=>404),
      $q->start_html('Not Found'),
      $q->h2('Not Found'),
      $q->p("The name '$name' was not found on this server."),
      $q->end_html();
  }
}

sub list {
  print $q->header(-type=>'text/plain; charset=UTF-8');
  tie %LocalNames, "DB_File", $db, O_RDWR|O_CREAT, 0666, $DB_HASH
    or die "Cannot open file '$db': $!\n";
  foreach (keys %LocalNames) {
    print $_, "\n";
  }
}
