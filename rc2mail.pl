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
use File::Temp;

# This script can be invoked as follows:
# perl rc2mail.pl -r http://localhost/cgi-bin/wiki -p test

# -n Don't send email
# -p Oddmuse administrator password
# -r Oddmuse full URL, eg. http://localhost/cgi-bin/wiki
#    This will request http://localhost/cgi-bin/wiki?action=rss;days=1;full=1
#    and http://localhost/cgi-bin/wiki?action=subscriptionlist;raw=1;pwd=foo

my %opts;
getopt('prn', \%opts);
die "Must provide an url with the -r option\n" unless $opts{r};

my $ua = new LWP::UserAgent;

# Fetch subscribers first because we need to verify the password

sub get_subscribers {
  my ($url, $pwd) = @_;
  $url .= '?action=subscriptionlist;raw=1;pwd=' . $pwd;
  my $response = $ua->get($url);
  die "Must provide an admin password with the -p option\n"
    if $response->code == 403 and not $pwd;
  die "Must provide the correct admin password with the -p option\n"
    if $response->code == 403;
  die $url, $response->status_line unless $response->is_success;

  my %data;
  foreach my $line (split(/\n/, $response->content)) {
    my ($key, @entries) = split(/ +/, $line);
    # print "Subscription for $key: ", join(', ', @entries), "\n";
    $data{$key} = \@entries;
  }
  return \%data;
}

# Fetch RSS feed

sub get_rss {
  my $url = shift;
  $url .=  '?action=rss;days=1;full=1';
  my $response = $ua->get($url);
  die $url, $response->status_line unless $response->is_success;
  my $rss = new XML::RSS;
  $rss->parse($response->content);
  return $rss;
}

sub send_files {
  my ($rss, $subscribers) = @_;
  foreach my $item (@{$rss->{'items'}}) {
    my $title = $item->{title};
    my $id = $title;
    $id =~ s/ /_/g;
    send_file($id, $title, @{$subscribers->{$id}});
  }
}

sub send_file {
  my ($id, $title, @subscribers) = @_;
  my $fh = new File::Temp;
  # print $id, ': ', join(', ', @subscribers), "\n";
  print $fh $item->{description};
  foreach my $subscriber (@subscribers) {
    send_mail($subscriber, $title, $fh);
  }
}

sub send_mail {
  my ($subscriber, $title, $fh) = @_;
  my $mail = new MIME::Entity->build(To => $subscriber,
				     Subject => $title,
				     Encoding => "base64",
				     Path => $fh,
				     Type=> "text/html");
  return if exists $opt{n};
  my @recipients = $mail->smtpsend();
  if (@recipients) {
    print "Sent $title to ", join(', ', @recipients), "\n";
  } else {
    print "Failed to send $title to $subscriber\n";
  }
}

sub main {
  my $subscribers = get_subscribers($opts{r}, $opts{p});
  my $rss = get_rss($opts{r});
  send_files($rss, $subscribers);
}

main ();
