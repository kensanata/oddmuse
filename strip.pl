#!/usr/bin/perl

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
    start_html('Link Stripping'),
    h1('Link Stripping'),
    p('Transforms HTML into a plain-text list of link texts, one link per line.',
      'For example, the HTML &lt;a href="foo.html">bar&lt;/a> will be transformed to',
      'the text "bar".'),
    start_form(-method=>'GET'),
    p('HTML feed: ', textfield('url'), submit()),
    end_form(),
    end_html();
  exit;
}

print header(-type=>'text/plain; charset=UTF-8');
$ua = LWP::UserAgent->new;
$request = HTTP::Request->new('GET', param('url'));
$response = $ua->request($request);
$data = $response->content;
$p = HTML::Parser->new(api_version => 3);
$p->handler( start => \&start_handler, "tagname,self");
%pages = ();
$p->parse($data);
$p->eof;                 # signal end of document
print join("\n", sort keys %pages), "\n";

sub start_handler {
  return if shift ne "a";
  my $self = shift;
  $self->handler(text => sub { $pages{(shift)} = 1 }, "dtext");
  $self->handler(end  => sub { $self->handler(text => ""); });
}
