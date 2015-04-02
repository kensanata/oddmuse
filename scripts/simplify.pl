#! /usr/bin/perl
# Copyright (C) 2003, 2004  Alex Schroeder <alex@emacswiki.org>
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

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use XML::RSS;
use LWP::UserAgent;
use encoding 'utf8';

my $wikins = 'http://purl.org/rss/1.0/modules/wiki/';
my $rdfns = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
my $output = '0.91';

if (not param('url')) {
  print header(),
    start_html('RSS Simplification'),
    h1('RSS Simplification'),
    p('Translates any RSS feed to Really Simple Syndication ', $output,
      'It understands ModWiki, and will use wiki:diff as the link,',
      'and it will add dc:contributor to the description.'),
    start_form(-method=>'GET'),
    p('RSS feed: ', textfield('url', '', 70)),
    p(submit()),
    end_form(),
    end_html();
  exit;
}

print header(-type=>'text/plain; charset=UTF-8');
my $rss = new XML::RSS(output=>$output);
my $ua = new LWP::UserAgent;
my $request = HTTP::Request->new('GET', param('url'));
my $response = $ua->request($request);
my $data = $response->content;
eval {
  local $SIG{__DIE__} = sub { parse_rss3(); }; # parsing errors -> try RSS 3.0!
  $rss->parse($data);
  munge_rss();
};

sub munge_rss {
  foreach my $i (@{$rss->{items}}) {
    if ($i->{dc}->{contributor}) {
      if ($i->{description}) {
	$i->{description} = $i->{description} . ' -- ' . $i->{dc}->{contributor};
      } else {
	$i->{description} = '-- ' .$i->{dc}->{contributor};
      }
    }
    if ($i->{$wikins}->{diff}) {
      $i->{link} = $i->{$wikins}->{diff};
    }
  }
  print $rss->as_string();
}

# perl simplify.pl 'url=http://localhost/cgi-bin/wiki.pl?search=foo%3braw=1'

sub parse_rss3 {
  $rss->add_module(
    prefix => 'wiki',
    uri    => 'http://purl.org/rss/1.0/modules/wiki/'
  );
  my @entries = ();
  foreach my $entry (split(/\n\n+/, $data)) {
    my %entry = ();
    while ($entry =~ /(\S+?): (.*?)(?=\n[^\t]|\Z)/sg) {
      my ($key, $value) = ($1, $2);
      $value =~ s/\n\t/\n/g;
      $entry{$key} = $value if $value;
    }
    push(@entries, \%entry);
  }
  # the first entry is the channel
  my %entry = %{shift(@entries)};
  $rss->channel(%entry);
  # the rest are items
  while (@entries) {
    my %entry = %{shift(@entries)};
    my %dc = (date        => $entry{'last-modified'},
	      contributor => $entry{generator},);
    my %wiki = (size      => $entry{size},);
    $entry{dc} = %dc;
    $entry{wiki} = %wiki;
    for my $key qw(last-modified generator size) { delete $entry{$key}; }
    $rss->add_item(%entry);
  }
  print $rss->as_string();
}
