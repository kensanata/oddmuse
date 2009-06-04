#! /usr/bin/perl
# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package OddMuse;

use Getopt::Std;
use XML::RSS;
use LWP::UserAgent;
use MIME::Entity;

# -p Oddmuse administrator password
# -r Oddmuse full URL, eg. http://localhost/cgi-bin/wiki
#    This will request http://localhost/cgi-bin/wiki?action=rss;days=1;full=1
#    and http://localhost/cgi-bin/wiki?action=subscriptionlist;raw=1;pwd=foo

my (%opts, $pwd, $url, $ua, $response);

getopt('pr', \%opts);

$ua = new LWP::UserAgent;
$url = $opts{r} . '?action=rss;days=1;full=1';
$response = $ua->get($url);
die $url, $response->status_line unless $response->is_success;

my $rss = new XML::RSS;
$rss->parse($response->content);

$url = $opts{r} . '?action=subscriptionlist;raw=1;pwd=' . $opts{p};
$response = $ua->get($url);
die $url, $response->status_line unless $response->is_success;

my %data;
foreach my $line (split(/\n/, $response)) {
  my ($key, @entries) = split(/ +/, $line);
  $data{$key} = \@entries;
}

# create temporary directory
# loop through the files
# build filename
# extract HTML body, unquote it, save to file
# figure out what recipients are given the filename
# create mailer using ->build and send file

# my $mailer = new Mail::Mailer;
