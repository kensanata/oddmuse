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
#
#
# Usage: perl graph.pl URL
# The list of all words is printed to stdout.
#
# Example URL: http://www.emacswiki.org/cgi-bin/wiki?action=index;embed=1
# Beware of shell munging, either use \? and \; or quote the URL!
#
$uri = $ARGV[0];
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my $request = HTTP::Request->new('GET', $uri);
my $response = $ua->request($request);
$_ = $response->content;
while (m|>([^<>]+?)</a>|g) {
  print "$1\n";
}
