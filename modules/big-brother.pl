# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

package OddMuse;

$ModulesDescription .= '<p>$Id: big-brother.pl,v 1.5 2005/07/27 09:07:22 as Exp $</p>';

use vars qw($VisitorTime);

my $US  = "\x1f";

$VisitorTime = 7200; # keep visitor data arround for 2 hours.

push(@MyAdminCode, \&BigBrotherVisitors);

sub BigBrotherVisitors {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=visitors', Ts('Recent Visitors')));
}

my %BigBrotherData;

# replace the subs that DoSurgeProtection calls:
#       ReadRecentVisitors();
#       AddRecentVisitor($name);
# 	WriteRecentVisitors();
# 	if ($SurgeProtection and DelayRequired($name))

sub AddRecentVisitor {
  my ($name) = shift;
  my $value = $BigBrotherData{$name};
  my %entries = $value ? %{$value} : ();
  my $action = GetParam('action', 'browse');
  my $id = GetId(); # script/p/q -> q
  my $url = $q->url(-path_info=>1,-query=>1);
  my $download = GetParam('action', 'browse') eq 'download'
    || GetParam('download', 0)
    || $q->path_info() =~ m/\/download\//;
  if ($download) {
    # do nothing
  } elsif ($id) {
    $entries{$Now} = $id . $US . $url;
  } elsif ($action eq 'rss' or $action eq 'rc') {
    $entries{$Now} = $RCName . $US . $url;
  } else {
    $entries{$Now} = T('some action') . $US . $url;
  }
  $BigBrotherData{$name} = \%entries;
}

sub DelayRequired {
  my $name = shift;
  return 0 unless $BigBrotherData{$name};
  my %entries = %{$BigBrotherData{$name}};
  my @times = sort keys %entries;
  return 0 if not $times[$SurgeProtectionViews - 1]; # all slots must be filled
  return 0 if ($Now - $times[0]) > $SurgeProtectionTime;
  return 1;
}

sub ReadRecentVisitors {
  my ($status, $data) = ReadFile($VisitorFile);
  %BigBrotherData = ();
  return  unless $status;
  foreach (split(/\n/,$data)) {
    my ($name, %entries) = split /$FS/;
    $BigBrotherData{$name} = \%entries if $name and %entries;
  }
}

sub WriteRecentVisitors {
  my $data = '';
  my $limit = $Now - $VisitorTime; # don't save visits older than this
  foreach my $name (keys %BigBrotherData) {
    my %entries = %{$BigBrotherData{$name}};
    my @times = sort keys %entries;
    if (not $times[$SurgeProtectionViews - 1]
	or $times[$SurgeProtectionViews - 1] >= $limit) { # newest is recent enough
      @times = @times[-$SurgeProtectionViews .. -1] if $#times > $SurgeProtectionViews;
      $data .=  join($FS, $name, map { $_, $entries{$_}} @times) . "\n";
    }
  }
  WriteStringToFile($VisitorFile, $data);
}

$Action{visitors} = \&DoBigBrother;

sub DoBigBrother { # no caching of this page!
  print GetHeader('', T('Recent Visitors'), '', 1), $q->start_div({-class=>'content visitors'});
  ReadRecentVisitors();
  print '<p><ul>';
  my %latest = ();
  foreach (keys %BigBrotherData) {
    my %entries = %{$BigBrotherData{$_}};
    my @times = sort keys %entries;
    $latest{$_} = $times[-1];
  }
  foreach my $name (sort {$latest{$b} <=> $latest{$a}} keys %latest) {
    my $when = CalcTimeSince($Now - $latest{$name});
    my $error = ValidId($name);
    my $who = $name && !$error && $name !~ /\./ ? GetPageLink($name) : T('Anonymous');
    my %entries = %{$BigBrotherData{$name}};
    my $what = join(', ', map { my ($id, $url) = split(/$US/, $entries{$_});
				$q->a({-href=>$url}, $id); }
		    sort keys %entries);
    print $q->li($who, T('was here'), $when, T('and read'), $what);
  }
  print '</ul>' . $q->end_div();
  PrintFooter();
}
