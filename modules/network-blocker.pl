# -*- mode: perl -*-
# Copyright (C) 2017–2021  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.

=encoding utf8

=head1 NAME

Oddmuse Network Blocker

=head1 DESCRIPTION

This module hooks into regular Oddmuse Surge Protection. It adds the following
features:

Repeated offenders are blocked for increasingly longer times.

For every offender, we record the CIDR their IP number belongs to. Everytime an
IP number is blocked, all the CIDRs of the other blocked IPs are checked: if
there are three or more blocked IP numbers sharing the same CIDRs, the CIDR
itself is blocked.

CIDR blocking works the same way: Repeated offenders are blocked for
increasingly longer times.

=head2 Behind a reverse proxy

Make sure your config file copies the IP number to the correct environment
variable:

    $ENV{REMOTE_ADDR} = $ENV{HTTP_X_FORWARDED_FOR};

=head1 SEE ALSO

<Oddmuse Surge Protection|https://oddmuse.org/wiki/Surge_Protection>

=cut

package OddMuse;
use Modern::Perl;
use Net::IP qw(:PROC);
use Net::DNS qw(rr);

our ($Now, $DataDir, $SurgeProtectionViews, $SurgeProtectionTime);

*OldNetworkBlockerDelayRequired = \&DelayRequired;
*DelayRequired = \&NewNetworkBlockerDelayRequired;

# Block for at least this many seconds.
my $NetworkBlockerMinimumPeriod = 30;

# Every violation doubles the current period until this maximum is reached (four weeks).
my $NetworkBlockerMaximumPeriod = 60 * 60 * 24 * 7 * 4;

# All the blocked networks. Maps CIDR to an array [expiry timestamp, expiry
# period].
my %NetworkBlockerList;

# Candidates are remembered for this many seconds.
my $NetworkBlockerCachePeriod = 600;

# All the candidate networks for a block. Maps IP to an array [ts, cidr, ...].
# Candidates are removed after $NetworkBlockerCachePeriod.
my %NetworkBlockerCandidates;

sub NetworkBlockerRead {
  my ($status, $data) = ReadFile("$DataDir/network-blocks");
  return unless $status;
  my @lines = split(/\n/, $data);
  while ($_ = shift(@lines)) {
    my @items = split(/,/);
    $NetworkBlockerList{shift(@items)} = \@items;
  }
  # an empty line separates the two sections
  while ($_ = shift(@lines)) {
    my @items = split(/,/);
    $NetworkBlockerCandidates{shift(@items)} = \@items;
  }
  return 1;
}

sub NetworkBlockerWrite {
  RequestLockDir('network-blocks') or return '';
  WriteStringToFile(
    "$DataDir/network-blocks",
    join("\n\n",
         join("\n", map {
           join(",", $_, @{$NetworkBlockerList{$_}})
              } keys %NetworkBlockerList),
         join("\n", map {
           join(",", $_, @{$NetworkBlockerCandidates{$_}})
              } keys %NetworkBlockerCandidates)));
  ReleaseLockDir('network-blocks');
}

sub NewNetworkBlockerDelayRequired {
  my $ip = shift;
  # If $ip is a name and not an IP number, parsing fails. In this case, run the
  # regular code.
  my $ob = new Net::IP($ip);
  return OldNetworkBlockerDelayRequired($ip) unless $ob;
  # Read the file. If the file does not exist, no problem.
  NetworkBlockerRead();
  # See if the current IP number is one of the blocked CIDR ranges.
  for my $cidr (keys %NetworkBlockerList) {
    # Perhaps this CIDR block can be expired.
    if ($NetworkBlockerList{$cidr}->[0] < $Now) {
      delete $NetworkBlockerList{$cidr};
      next;
    }
    # Forget the CIDR if it cannot be turned into a range.
    my $range = new Net::IP($cidr);
    if (not $range) {
      warn "CIDR $cidr is blocked but has no range: " . Net::IP::Error();
      delete $NetworkBlockerList{$cidr};
      next;
    }
    # If the CIDR overlaps with the remote IP number, it's a block.
    my $overlap = $range->overlaps($ob);
    # $IP_PARTIAL_OVERLAP (ranges overlap) $IP_NO_OVERLAP (no overlap)
    # $IP_A_IN_B_OVERLAP (range2 contains range1) $IP_B_IN_A_OVERLAP (range1
    # contains range2) $IP_IDENTICAL (ranges are identical) undef (problem)
    if (defined $overlap and $overlap != $IP_NO_OVERLAP) {
      # Double the block period unless it has reached $NetworkBlockerMaximumPeriod.
      if ($NetworkBlockerList{$cidr}->[1] < $NetworkBlockerMaximumPeriod / 2) {
        $NetworkBlockerList{$cidr}->[1] *= 2;
      } else {
        $NetworkBlockerList{$cidr}->[1] = $NetworkBlockerMaximumPeriod;
      }
      $NetworkBlockerList{$cidr}->[0] = $Now + $NetworkBlockerList{$cidr}->[1];
      # And we're done!
      NetworkBlockerWrite();
      ReportError(Ts('Too many connections by %s', $cidr)
		  . ': ' . Tss('Please do not fetch more than %1 pages in %2 seconds.',
			       $SurgeProtectionViews, $SurgeProtectionTime),
		  '503 SERVICE UNAVAILABLE');
    }
  }
  # If the CIDR isn't blocked, let's see if Surge Protection wants to block it.
  my $result = OldNetworkBlockerDelayRequired($ip);
  # If the IP is to be blocked, determine its CIDRs and put them on a list. Sadly,
  # routeviews does not support IPv6 at the moment!
  if ($result and not ip_is_ipv6($ip) and not $NetworkBlockerCandidates{$ip}) {
    my $reverse = $ob->reverse_ip();
    $reverse =~ s/in-addr\.arpa\.$/asn.routeviews.org/;
    my @candidates;
    for my $rr (rr($reverse, "TXT")) {
      next unless $rr->type eq "TXT";
      my @data = $rr->txtdata;
      push(@candidates, join("/", @data[1..2]));
    }
    $NetworkBlockerCandidates{$ip} = [$Now, @candidates];
    # Expire any of the other candidates
    for my $other_ip (keys %NetworkBlockerCandidates) {
      if ($NetworkBlockerCandidates{$other_ip}->[0] < $Now - $NetworkBlockerCachePeriod) {
        delete $NetworkBlockerCandidates{$other_ip};
      }
    }
    # Determine if any of the CIDRs is to be blocked.
    my $save;
    for my $cidr (@candidates) {
      # Count how often the candidate CIDRs show up for other IP numbers.
      my $count = 0;
      for my $other_ip (keys %NetworkBlockerCandidates) {
        my @data = $NetworkBlockerCandidates{$other_ip};
        for my $other_cidr (@data[1 .. $#data]) {
          $count++ if $cidr eq $other_cidr;
        }
      }
      if ($count >= 3) {
        $NetworkBlockerList{$cidr} = [$Now + $NetworkBlockerMinimumPeriod, $NetworkBlockerMinimumPeriod];
        $save = 1;
      }
    }
    NetworkBlockerWrite() if $save;
  }
  return $result;
}
