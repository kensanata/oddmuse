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
use encoding 'utf8';
use POSIX;

my $q = new CGI;
my $url = $q->param('url');
my $pattern = $q->param('pattern');

if (not $url) {
  print $q->header(),
    $q->start_html('LocalNames Server'),
    $q->h1('LocalNames Server'),
    $q->p('Reads a definition of', $q->a({-href=>'http://ln.taoriver.net/about.html'}, 'local names'),
	  'from an URL and returns a list of names, one per line.  Use the resulting URL for your NearMap.'),
    $q->p(q{$Id: localnames-server.pl,v 1.1 2005/01/09 22:33:46 as Exp $}),
    $q->start_form(-method=>'GET'),
    $q->p('LocalNames Definition  URL: ',
	  $q->textfield('url', '', 70)),
    $q->p($q->submit()),
    $q->end_form(),
    $q->end_html();
  exit;
}

my $ua = new LWP::UserAgent;
my $response = $ua->get($url);
die $response->status_line unless $response->is_success;
my $data = $response->content;

print $q->header(-type=>'text/plain; charset=UTF-8');
print LocalNamesParseDefinition($data);

my %LocalNamesSeen = ();
my %LocalNames = ();

sub LocalNamesParseDefinition {
  my ($url) = @_;
  if (not $LocalNamesSeen{$url}) {
    $LocalNamesSeen{$url} = 1;
    my($type, $name, $target);
    foreach my $line (split(/\n/, GetRaw($url))) {
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
  # else do nothing -- benn there before
}
