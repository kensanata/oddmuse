#! /usr/bin/perl
# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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
use LWP::UserAgent;
use Encode;

if (not param('url')) {
  print header(),
    start_html('PHP Wiki Search RSS 3.0'),
    h1('PHP Wiki Search RSS 3.0'),
    p('Translates a PHP Wiki Search result into RSS 3.0 usable by Oddmuse.'),
    start_form(-method=>'GET'),
    p('Search URL: ', textfield('url', '', 40), checkbox('latin-1'), submit()),
    end_form(),
    end_html();
  exit;
}

print header(-type=>'text/plain; charset=UTF-8');

my $ua = new LWP::UserAgent;
my $request = HTTP::Request->new('GET', param('url'));
my $response = $ua->request($request);
my $data = $response->content;
$data = encode('utf-8', decode('latin-1', $data)) if param('latin-1');

$data =~ /\<title\>([^<]*)/i;
print "title: $1\n" if $1;
print "link: " . param('url') . "\n";
my $previous = '';
while ($data =~ m|<dt>.*?<a href="([^"]*)".*\n<dd><small class="search-context">(.*?)</small></dd>|g) {
  if ($previous eq $1) {
    print "\t$2\n";
  } else {
    print "\n";
    print "title: $1\n";
    print "description: $2\n";
  }
  $previous = $1;
}
