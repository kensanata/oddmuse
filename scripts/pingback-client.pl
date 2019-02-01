#! /usr/bin/perl -w

# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 Pingback from one site to another

If you link from page A on your site to page B on some other site, you can
invoke this script with the command-line arguments A and B. In theory, this will
create a link back from B to A, letting them and all their visitors know that
you wrote something in response.

=cut

use Modern::Perl;
use RPC::XML;
use RPC::XML::Client;
use XML::LibXML;
use LWP::UserAgent;
use Data::Dumper;

if (@ARGV != 2) {
  die "Usage: pingback-client FROM TO\n";
}

my ($from, $to) = @ARGV;
my $ua = LWP::UserAgent->new;
$ua->agent("OddmusePingbackClient/0.1");

print "Getting $to\n";
my $response = $ua->get($to);

if (!$response->is_success) {
  die $response->status_line;
}

print "Parsing $to\n";
my $data = $response->decoded_content;

my $parser = XML::LibXML->new(recover => 2);
my $dom = $parser->load_html(string => $data);
my $pingback = $dom->findvalue('//link[@rel="pingback"]/@href');

if (!$pingback) {
  die "Pingback URL not found in $to\n";
}

print "Pingback URL is $pingback\n";

my $request = RPC::XML::request->new(
  'pingback.ping', $from, $to);
my $client = RPC::XML::Client->new($pingback);
$response = $client->send_request($request);

if (!ref($response)) {
  die $response;
}

print Dumper($response->value);
