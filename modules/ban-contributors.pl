# Copyright (C) 2013-2021  Alex Schroeder <alex@gnu.org>

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

=head1 Ban Contributors Extension

This module adds "Ban contributors" to the administration page. If you
click on it, it will list all the recent contributors to the page
you've been looking at. Each contributor (IP or hostname) will be
compared to the list of regular expressions on the C<BannedHosts> page
(see C<$BannedHosts>). If the contributor is already banned, this is
mentioned. If the contributor is not banned, you'll see a button
allowing you to ban him or her immediately. If you click the button,
the IP will be added to the C<BannedHosts> page for you.

=cut
use strict;
use v5.10;

our ($q, $Now, %Page, $OpenPageName, %Action, $UrlPattern, $BannedContent, $BannedHosts, @MyAdminCode);

AddModuleDescription('ban-contributors.pl', 'Ban Contributors Extension');

push(@MyAdminCode, \&BanMenu);

sub BanMenu {
  my ($id, $menuref, $restref) = @_;
  if ($id and UserIsAdmin()) {
    push(@$menuref, ScriptLink('action=ban;id=' . UrlEncode($id),
			       T('Ban contributors')));
  }
}

$Action{ban} = \&DoBanHosts;

sub IsItBanned {
  my ($it, $regexps) = @_;
  my $re = undef;
  foreach my $regexp (@$regexps) {
    eval { $re = qr/$regexp/i; };
    if (defined($re) && $it =~ $re) {
      return $it;
    }
  }
}

sub DoBanHosts {
  my $id = shift;
  my $content = GetParam('content', '');
  my $range = GetParam('range', '');
  my $regexp = GetParam('regexp', '');
  if ($content) {
    SetParam('text', GetPageContent($BannedContent)
	     . $content . " # " . CalcDay($Now) . " "
	     . NormalToFree($id) . "\n");
    SetParam('summary', NormalToFree($id));
    DoPost($BannedContent);
  } elsif ($regexp) {
    SetParam('text', GetPageContent($BannedHosts)
	     . $regexp . " # " . CalcDay($Now)
	     . " $range "
	     . NormalToFree($id) . "\n");
    SetParam('summary', NormalToFree($id));
    DoPost($BannedHosts);
  } else {
    ValidIdOrDie($id);
    print GetHeader('', Ts('Ban Contributors to %s', NormalToFree($id)));
    SetParam('rcidonly', $id);
    SetParam('all', 1);
    SetParam('showedit', 1);
    my %contrib = ();
    for my $line (GetRcLines()) {
      $contrib{$line->[4]}->{$line->[5]} = 1 if $line->[4];
    }
    my @regexps = ();
    foreach (split(/\n/, GetPageContent($BannedHosts))) {
      if (/^\s*([^#]\S+)/) { # all lines except empty lines and comments, trim whitespace
	push(@regexps, $1);
      }
    }
    print '<div class="content ban">';
    foreach (sort(keys %contrib)) {
      my $name = $_;
      delete $contrib{$_}{''};
      $name .= " (" . join(", ", sort(keys(%{$contrib{$_}}))) . ")";
      if (IsItBanned($_, \@regexps)) {
	print $q->p(Ts("%s is banned", $name));
      } else {
	my @pairs = BanContributors::get_range($_);
	while (@pairs) {
	  my $start = shift(@pairs);
	  my $end = shift(@pairs);
	  $range = "[$start - $end]";
	  $name .= " " . $range;
	  print GetFormStart(undef, 'get', 'ban'),
	      GetHiddenValue('action', 'ban'),
	      GetHiddenValue('id', $id),
	      GetHiddenValue('range', $range),
	      GetHiddenValue('regexp', BanContributors::get_regexp_ip($start, $end)),
	      GetHiddenValue('recent_edit', 'on'),
	      $q->p($name, $q->submit(T('Ban!'))), $q->end_form();
	}
      }
    }
  }
  PrintFooter();
}

=head2 Rollback

If you are an admin and rolled back a single page, this extension will
list the URLs your rollback removed (assuming that those URLs are part
of the spam) and it will allow you to provide a regular expression
that will be added to BannedHosts.

=cut

*OldBanContributorsWriteRcLog = \&WriteRcLog;
*WriteRcLog = \&NewBanContributorsWriteRcLog;

sub NewBanContributorsWriteRcLog {
  my ($tag, $id, $to) = @_;
  if ($tag eq '[[rollback]]' and $id and $to > 0
      and $OpenPageName eq $id and UserIsAdmin()) {
    # we currently have the clean page loaded, so we need to reload
    # the spammed revision (there is a possible race condition here)
    my $old = GetTextRevision($Page{revision} - 1, 1)->{text};
    my %urls = map {$_ => 1 } $old =~ /$UrlPattern/g;
    # we open the file again to force a load of the despammed page
    foreach my $url ($Page{text} =~ /$UrlPattern/g) {
      delete($urls{$url});
    }
    # we also remove any candidates that are already banned
    my @regexps = ();
    foreach (split(/\n/, GetPageContent($BannedContent))) {
      if (/^\s*([^#]\S+)/) { # all lines except empty lines and comments, trim whitespace
	push(@regexps, $1);
      }
    }
    foreach my $url (keys %urls) {
      delete($urls{$url}) if IsItBanned($url, \@regexps);
    }
    if (keys %urls) {
      print $q->p(Ts("These URLs were rolled back. Perhaps you want to add a regular expression to %s?",
		     GetPageLink($BannedContent)));
      print $q->pre(join("\n", sort keys %urls));
      print GetFormStart(undef, 'get', 'ban'),
	    GetHiddenValue('action', 'ban'),
	    GetHiddenValue('id', $id),
	    GetHiddenValue('recent_edit', 'on'),
	    $q->p($q->label({-for=>'content'}, T('Regular expression:')), " ",
		  $q->textfield(-name=>'content', -size=>30), " ",
		  $q->submit(T('Ban!'))),
	    $q->end_form();
    };
    print $q->p(T("Consider banning the IP number as well:"), ' ',
		ScriptLink('action=ban;id=' . UrlEncode($id), T('Ban contributors')));
  };
  return OldBanContributorsWriteRcLog(@_);
}

package BanContributors;
use Net::Whois::Parser qw/parse_whois/;
use Net::IP;

sub get_range {
  my $ip = shift;
  my $response = parse_whois(domain => $ip);
  my $re = '(?:[0-9]{1,3}\.){3}[0-9]{1,3}';
  # Just try all the keys and see whether there is a range match.
  for (keys %$response) {
    my @result;
    $_ = $response->{$_};
    for (ref eq 'ARRAY' ? @$_ : $_) {
      $ip = Net::IP->new($_);
      push(@result, $ip->ip, $ip->last_ip) if $ip;
    }
    return @result if @result;
  }
  # Fallback
  return $ip, $ip;
}

sub get_groups {
  my ($from, $to) = @_;
  my @groups;
  if ($from == $to) {
    return [$from, $to];
  }
  # ones up to the nearest ten
  if ($from < $to and ($from % 10 or $from < 10)) {
    # from 5-7: as is
    # from 5-17: 5 + 9 - 5 = 9 thus 5-9, set $from to 10
    my $to2 = int($to/10) > int($from/10) ? $from + 9 - $from % 10 : $to;
    push(@groups, [$from, $to2]);
    $from = $to2 + 1;
  }
  # tens up to the nearest hundred
  if ($from < $to and $from % 100) {
    # 10-17: as is
    # 10-82: 10 to 79, set $from to 80 (8*10-1)
    # 10-182: 10 to 99, set $from to 100 (10+99=10=99)
    # 110-182: 110 to 179, set $from to 180 (170)
    # 110-222: 110 to 199, set $from to 200 (110+99-10 = 199)
    my $to2 = int($to/100) > int($from/100) ? $from + 99 - $from % 100
	: int($to/10) > int($from/10) ? int($to / 10) * 10 - 1
	: $to;
    push(@groups, [$from, $to2]);
    $from = $to2 + 1;
  }
  # up to the next hundred
  if (int($to/100) > int($from/100)) {
    # from 100 to 223: set $from to 200 (2*100-1)
    my $to2 = int($to/100) * 100 - 1;
    push(@groups, [$from, $to2]);
    $from = $to2 + 1;
  }
  # up to the next ten
  if (int($to/10) > int($from/10)) {
    # 10 to 17: skip
    # 100 to 143: set $from to 140 (14*10-1)
    my $to2 = int($to / 10) * 10 - 1;
    push(@groups, [$from, $to2]);
    $from = $to2 + 1;
  }
  # up to the next one
  if ($from <= $to) {
    push(@groups, [$from, $to]);
  }
  # warn join("; ", map { "@$_" } @groups);
  return \@groups;
}

sub get_regexp_range {
  my @chars;
  for my $group (@{get_groups(@_)}) {
    my ($from, $to) = @$group;
    my $char;
    for (my $i = length($from); $i >= 1; $i--) {
      if (substr($from, - $i, 1) eq substr($to, - $i, 1)) {
	$char .= substr($from, - $i, 1);
      } else {
	$char .= '[' . substr($from, - $i, 1) . '-' . substr($to, - $i, 1). ']';
      }
    }
    push(@chars, $char);
  }
  return join('|', @chars);
}

sub get_regexp_ip {
  my ($from, $to) = @_;
  my @start = split(/\./, $from);
  my @end = split(/\./, $to);
  my $regexp = "^";
  for my $i (0 .. 3) {
    if ($start[$i] eq $end[$i]) {
      # if the byte is the same, use it as is
      $regexp .= $start[$i];
      $regexp .= '\.' if $i < 3;
    } elsif ($start[$i] == 0 and $end[$i] == 255) {
      # the starting byte is 0 and the end byte is 255, then anything goes:
      # we're done, e.g. 185.244.214.0 - 185.244.214.255 results in 185\.244\.214\.
      last;
    } elsif ($i == 3 and $start[$i] != $end[$i]) {
      # example 45.87.2.128 - 45.87.2.255: the last bytes differ
      $regexp .= '(' . get_regexp_range($start[$i], $end[$i]) . ')';
      last;
    } elsif ($start[$i + 1] == 0 and $end[$i + 1] == 255) {
      # if we're here, we already know that the start byte and the end byte are
      # not the same; if the next bytes are from 0 to 255, we know that
      # everything else doesn't matter, e.g. 42.118.48.0 - 42.118.63.255
      $regexp .= '(' . get_regexp_range($start[$i], $end[$i]) . ')';
      $regexp .= '\.' if $i < 3;
      last;
    } elsif ($end[$i] - $start[$i] == 1 and $start[$i + 1] > 0 and $end[$i + 1] < 255) {
      # if we're here, we already know that the start byte and the end byte are
      # not the same; if the starting byte of the next (!) byte is bigger than
      # zero, then we need groups: in the case 77.56.180.0 - 77.57.70.255 for
      # example,
      $regexp .= '(' . $start[$i] . '\.(' . get_regexp_range($start[$i + 1], 255) . ')|'
		   . $end[$i] . '\.(' . get_regexp_range(0, $end[$i + 1]) . ')';
      $regexp .= '\.' if $i < 3;
      last;
    } else {
      warn "Unhandled regexp: $from - $to ($i)";
      $regexp .= 'XXX';
      $regexp .= '\.' if $i < 3;
      last;
    }
  }
  return $regexp;
}

# this is required in case we concatenate other modules to this one
package OddMuse;
