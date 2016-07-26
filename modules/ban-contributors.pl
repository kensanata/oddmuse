# Copyright (C) 2013-2016  Alex Schroeder <alex@gnu.org>

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

package BanContributors;
use Net::Whois::IP qw/whoisip_query/;

sub get_range {
  my $ip = shift;
  my $response = whoisip_query($ip);
  my ($start, $end);
  my $ip_regexp = '(?:[0-9]{1,3}\.){3}[0-9]{1,3}';
  for (sort keys(%{$response})) {
    if (($start, $end)
	= $response->{$_} =~ /($ip_regexp) *- *($ip_regexp)/) {
      last;
    }
  }
  return $start, $end;
}

sub get_groups {
  my ($from, $to) = @_;
  my @groups;
  if ($from < 10) {
    my $to = $to >= 10 ? 9 : $to;
    push(@groups, [$from, $to]);
    $from = $to + 1;
  }
  while ($from < $to) {
    my $to = int($from/100) < int($to/100) ? $from + 99 - $from % 100 : $to;
    if ($from % 10) {
      push(@groups, [$from, $from + 9 - $from % 10]);
      $from += 10 - $from % 10;
    }
    if (int($from/10) < int($to/10)) {
      if ($to % 10 == 9) {
	push(@groups, [$from, $to]);
	$from = 1 + $to;
      } else {
	push(@groups, [$from, $to - 1 - $to % 10]);
	$from = $to - $to % 10;
      }
    } else {
      push(@groups, [$from - $from % 10, $to]);
      last;
    }
    if ($to % 10 != 9) {
      push(@groups, [$from, $to]);
      $from = 1 + $to; # jump from 99 to 100
    }
  }
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
      $regexp .= $start[$i];
    } elsif ($start[$i] eq '0' and $end[$i] eq '255') {
      last;
    } else {
      $regexp .= '(' . get_regexp_range($start[$i], $end[$i]) . ')$';
      last;
    }
    $regexp .= '\.' if $i < 3;
  }
  return $regexp;
}

package OddMuse;

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
	my ($start, $end) = BanContributors::get_range($_);
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
