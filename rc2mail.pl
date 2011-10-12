#! /usr/bin/perl
# Copyright (C) 2010  Alex Schroeder <alex@gnu.org>

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
use File::Basename;
use File::Path;

# This script can be invoked as follows:
# perl rc2mail.pl -r http://localhost/cgi-bin/wiki \
#                 -p test \
#                 -m "alex:*secret*@mail.epfarms.org" \
#                 -f "kensanata@gmail.com" \
#                 -t ~/.rc2mail

# -n Don't send email; useful if debugging the script
# -p Oddmuse administrator password
# -r Oddmuse full URL, eg. http://localhost/cgi-bin/wiki
#    gets http://localhost/cgi-bin/wiki?action=rss;days=1;full=1;short=0
#    And http://localhost/cgi-bin/wiki?action=subscriptionlist;raw=1;pwd=foo
# -m user:password@mailhost for sending email using SMTP Auth. Without this
#    information, the script will send mail to localhost.
# -f email address to use as the sender.
# -t timestamp file; it's last modified date is used to determine when the
#    the last run was and an appropriate URL is used. Instead of days=1 it
#    will use from=n where n is the last modified date of the timestamp file.
# -q quiet (default: number of messages sent)
# -v verbose output (recipients)
# -x debug output

my %opts;
getopts('np:r:m:f:t:qvx', \%opts);
my $nomail = exists $opts{n};
my $verbose = exists $opts{v};
my $quiet = exists $opts{q};
my $debug = exists $opts{x};
my $admin_password = $opts{p};
my $root = $opts{r};
die "Must provide an url with the -r option\n" unless $root;
$opts{m} =~ /(.*?):(.*)\@(.*)/;
my ($user, $password, $host) = ($1, $2, $3);
die "Cannot parse -m " . $opts{m} . "\n" if $opts{m} && !$host;
my $from = $opts{f};
die "Must provide sender using -f\n" if !$nomail && $host && !$from;
my $ts = $opts{t};

my $ua = new LWP::UserAgent;

# Fetch subscribers first because we need to verify the password

sub get_subscribers {
  my $url = "$root?action=subscriptionlist;raw=1;pwd=$admin_password";
  print "Getting $url\n" if $debug;
  my $response = $ua->get($url);
  die "Must provide an admin password with the -p option\n"
    if $response->code == 403 and not $admin_password;
  die "Must provide the correct admin password with the -p option\n"
    if $response->code == 403;
  die $url, "\n", $response->status_line unless $response->is_success;

  my %data;
  foreach my $line (split(/\n/, $response->content)) {
    my ($key, @entries) = split(/ +/, $line);
    # print "Subscription for $key: ", join(', ', @entries), "\n";
    $data{$key} = \@entries;
  }
  print "Found " . scalar(keys(%data)) . " subscribers\n" if $debug;
  return \%data;
}

# Fetch RSS feed

sub get_timestamp {
  if ($ts and -f $ts) {
    return "from=" . (stat($ts))[9];
  } else {
    return "days=1";
  }
}

sub update_timestamp {
  # Only update timestamps if $ts is provided.
  return unless $ts;
  if (-f $ts) {
    # File exists: update timestamp.
    utime undef, undef, $ts;
  } else {
    # File does not exist: create it. File content is ignored on the
    # next run!
    my $dir = dirname($ts);
    mkpath($dir) unless -d $dir;
    open(F, ">$ts") or warn "Unable to create $ts: $!";
    close(F);
  }
}

sub get_rss {
  my $url = "$root?action=rss;full=1;short=0;" . get_timestamp();
  print "Getting $url\n" if $debug;
  my $response = $ua->get($url);
  die $url, $response->status_line unless $response->is_success;
  my $rss = new XML::RSS;
  $rss->parse($response->content);
  print "Found " . @{$rss->{items}} . " items.\n" if $debug;
  update_timestamp();
  return $rss;
}

sub send_files {
  my ($rss, $subscribers) = @_;
  my @items = @{$rss->{items}};
  die "No items to send\n" unless @items;
  my $sent = 0;
  foreach my $item (@items) {
    my $title = $item->{title};
    print "Looking at $title\n" if $debug;
    my $id = $title;
    $id =~ s/ /_/g;
    my @subscribers = @{$subscribers->{$id}};
    print "Subscribers: ", join(', ', @subscribers), "\n" if $debug;
    $sent += @subscribers;
    send_file($id, $title, $item, @subscribers);
  }
  print "$sent messages sent\n" if $sent;
}

sub send_file {
  my ($id, $title, $item, @subscribers) = @_;
  return unless @subscribers;
  my $fh = File::Temp->new(SUFFIX => '.html');
  warn "No content for $title\n" unless $item->{description};
  my $link = $item->{link};
  my $sub = "$root?action=subscriptions";
  print $fh qq(<p>Visit <a href="$link">$title</a>)
    . qq( or <a href="$sub">manage your subscriptions</a>.</p><hr />)
    . $item->{description};
  $fh->close;
  foreach my $subscriber (@subscribers) {
    send_mail($subscriber, $title, $fh);
  }
}

sub send_mail {
  my ($subscriber, $title, $fh) = @_;
  print "Skipping mail to $subscriber...\n" if $debug && $nomail;
  return if $nomail;
  my $mail = new MIME::Entity->build(To => $subscriber,
				     From => $from,
				     Subject => $title,
				     Path => $fh,
				     Type=> "text/html");
  if ($host) {
    print "Sending $title to $subscriber using ${user}\@${host}\n" if $verbose;
    eval {
      require Net::SMTP::TLS;
      my $smtp = Net::SMTP::TLS->new($host,
				     User => $user,
				     Password => $password);
      $smtp->mail($from);
      $smtp->to($subscriber);
      $smtp->data;
      $smtp->datasend($mail->stringify);
      $smtp->dataend;
      $smtp->quit;
    };
    if ($@) {
      require Net::SMTP::SSL;
      my $smtp = Net::SMTP::SSL->new($host, Port => 465);
      $smtp->auth($user, $password);
      $smtp->mail($from);
      $smtp->to($subscriber);
      $smtp->data;
      $smtp->datasend($mail->stringify);
      $smtp->dataend;
      $smtp->quit;
    }
  } else {
    my @recipients = $mail->smtpsend();
    if (@recipients) {
      print "Sent $title to ", join(', ', @recipients), "\n" unless $quiet;
    } else {
      print "Failed to send $title to $subscriber\n" unless $quiet;
    }
  }
}

sub main {
  my $rss = get_rss();
  return unless @{$rss->{items}};
  my $subscribers = get_subscribers();
  return unless %{$subscribers};
  send_files($rss, $subscribers);
}

main ();
