# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>

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
the IP or hostname will be added to the C<BannedHosts> page for you.

=cut

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
  my $host = GetParam('host', '');
  if ($content) {
    SetParam('text', GetPageContent($BannedContent)
	     . $content . " # " . CalcDay($Now) . " "
	     . NormalToFree($id) . "\n");
    SetParam('summary', NormalToFree($id));
    DoPost($BannedContent);
  } elsif ($host) {
    $host =~ s/\./\\./g;
    SetParam('text', GetPageContent($BannedHosts)
	     . "^" . $host . " # " . CalcDay($Now) . " "
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
	print GetFormStart(undef, 'get', 'ban'),
	  GetHiddenValue('action', 'ban'),
	  GetHiddenValue('id', $id),
	  GetHiddenValue('host', $_),
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

*OldBanContributorsWriteRcLog = *WriteRcLog;
*WriteRcLog = *NewBanContributorsWriteRcLog;

sub NewBanContributorsWriteRcLog {
  my ($tag, $id, $to) = @_;
  if ($tag eq '[[rollback]]' and $id and $to > 0
      and $OpenPageName eq $id and UserIsAdmin()) {
    # we currently have the clean page loaded, so we need to reload
    # the spammed revision (there is a possible race condition here)
    my ($old) = GetTextRevision($Page{revision}-1, 1);
    my %urls = map {$_ => 1 } $old =~ /$UrlPattern/og;
    # we open the file again to force a load of the despammed page
    foreach my $url ($Page{text} =~ /$UrlPattern/og) {
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
    print $q->p(T("Consider banning the hostname or IP number as well: "),
		ScriptLink('action=ban;id=' . UrlEncode($id), T('Ban contributors')));
  };
  return OldBanContributorsWriteRcLog(@_);
}
