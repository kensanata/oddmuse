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
use XML::RSS;
use LWP::UserAgent;
use encoding 'utf8';
use POSIX;

my $wikins = 'http://purl.org/rss/1.0/modules/wiki/';
my $rdfns = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
my $output = '0.91';

my $q = new CGI;
if (not $q->param('url')) {
  print $q->header(),
    $q->start_html('ChangeLog to RSS'),
    $q->h1('ChangeLog to RSS'),
    $q->p('Translates ChangeLog output to RSS ', $output, '.'),
    $q->p('$Id: changelog-to-rss.pl,v 1.1 2005/01/05 21:12:42 as Exp $: '),
    $q->start_form(-method=>'GET'),
    $q->p('ChangeLog URL: ', $q->textfield('url', '', 70)),
    $q->p('Limit number of entries returned: ', $q->textfield('limit', '15', 5)),
    $q->p($q->submit()),
    $q->end_form(),
    $q->end_html();
  exit;
}

print $q->header(-type=>'text/plain; charset=UTF-8');
my $rss = new XML::RSS(output=>$output);
$rss->channel(title => 'ChangeLog',
	      link => $url,
	      description => 'RSS feed automatically extracted from a ChangeLog file.',
	     );

my $ua = new LWP::UserAgent;
my $response = $ua->get($q->param('url'));
die $response->status_line unless $response->is_success;
my $data = $response->content;

my $limit = $q->param('limit') || 15;
my ($date, $author, $file, $log, $count);
foreach my $line (split(/\n/, $data)) {
  # print "----\n$line\n----\n";
  if ($line =~ m/^(\d\d\d\d-\d\d-\d\d)\s*(.*)/) {
    output($date, $author, $file, $log);
    $date = $1;
    $author = $2;
    $file = '';
    $log = '';
  } elsif ($line =~ m|^\t\* ([a-z./-]+)|) {
    last if ++$count > $limit;
    output($date, $author, $file, $log);
    $file = $1;
    $log = $line;
  } else {
    $log .= "\n" . $line;
  }
}

output($date, $author, $file, $log) if $file or $log;
print $rss->as_string;

sub output {
  my ($date, $author, $file, $log) = @_;
  return unless $file;
  $rss->add_item(title => $file,
		 description => $log,
		 dc => {
			date  => to_date($date),
			creator  => $author,
		       },
		 );
}

sub to_date {
  $_ = shift;
  my ($year, $month, $day) = split(/-/);
  return strftime("", 0, 0, 0, $day - 1, $month - 1, $year - 1900);
}
