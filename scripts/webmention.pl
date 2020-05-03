#! /usr/bin/perl -w

# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
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

=head1 Webmention from one site to another

If you link from page A on your site to page B on some other site, you can
invoke this script with the command-line arguments A and B. In theory, this will
create a link back from B to A, letting them and all their visitors know that
you wrote something in response.

=cut

use Modern::Perl;
use XML::LibXML;
use LWP::UserAgent;
use Data::Dumper;

if (@ARGV != 2) {
  die "Usage: webmention FROM TO\n";
}

my $parser = XML::LibXML->new(recover => 2);

my ($from, $to) = @ARGV;
my $ua = LWP::UserAgent->new(agent => "Oddmuse Webmention Client/0.1");

print "Getting $from\n";
my $response = $ua->get($from);

if (!$response->is_success) {
  die $response->status_line;
}

print "Parsing $from\n";
my ($username, $homepage);
my $dom = $parser->load_html(string => $response->decoded_content);
my @nodes = $dom->findnodes('//*[@rel="author"]');
if (@nodes) {
  my $node = shift @nodes;
  $username = $node->textContent;
  $homepage = $node->getAttribute('href');
}
print "Webmention from " . join(", ", $username, $homepage) . "\n"
    if $username or $homepage;

print "Getting $to\n";
$response = $ua->get($to);

if (!$response->is_success) {
  die $response->status_line;
}

print "Parsing $to\n";
$dom = $parser->load_html(string => $response->decoded_content);
my $webmention = $dom->findvalue('//link[@rel="webmention"]/@href');

if (!$webmention) {
  die "Webmention URL not found in $to\n";
}

print "Webmention URL is $webmention\n";

$response = $ua->post($webmention, { source => $from, target => $to });

my $message = $response->code . " " . $response->message . "\n";
if ($response->is_success) {
  print $message;
} else {
  die $message;
}
