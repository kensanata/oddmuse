#! /usr/bin/perl
# Copyright (C) 2003  Alex Schroeder <alex@emacswiki.org>
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

if (not param('url')) {
  print header(),
    start_html('UseMod Search RSS 3.0'),
    h1('UseMod Search RSS 3.0'),
    p('Translates a UseMod Search result into RSS 3.0 usable by Oddmuse.'),
    start_form(-method=>'GET'),
    p('Search URL: ', textfield('url'), submit()),
    end_form(),
    end_html();
  exit;
}

print header(-type=>'text/plain; charset=UTF-8');

my $ua = new LWP::UserAgent;
my $request = HTTP::Request->new('GET', param('url'));
my $response = $ua->request($request);
my $data = $response->content;

$data =~ /\<title\>([^<]*)/i;
print "title: $1\n" if $1;
print "link: " . param('url') . "\n\n";

while ($data =~ /\n\<a[^>]*\>([^<]*)\<\/a\>\<br\>/gi) {
  print "title: $1\n\n";
}
