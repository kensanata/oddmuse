# Copyright (C) 2005, 2009  Alex Schroeder <alex@gnu.org>
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

package OddMuse;

$ModulesDescription .= '<p>$Id: big-brother.pl,v 1.9 2009/01/06 22:23:36 as Exp $</p>';

use vars qw($VisitorTime);

my $US  = "\x1f";

$VisitorTime = 7200; # keep visitor data arround for 2 hours.

push(@MyAdminCode, \&BigBrotherVisitors);

sub BigBrotherVisitors {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=visitors', Ts('Recent Visitors'), 'visitors'));
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
  # make sure we don't ignore hits in the same second
  my $ts = $Now;
  $ts++ while $entries{$ts};
  my $action = GetParam('action', 'browse');
  my $id = GetId(); # script/p/q -> q
  my $url = $q->url(-path_info=>1,-query=>1);
  my $download = GetParam('action', 'browse') eq 'download'
    || GetParam('download', 0)
    || $q->path_info() =~ m/\/download\//;
  if ($download) {
    # do nothing
  } elsif ($id) {
    $entries{$ts} = $id . $US . $url;
  } elsif ($action eq 'rss' or $action eq 'rc') {
    $entries{$ts} = $RCName . $US . $url;
  } else {
    $entries{$ts} = T('some action') . $US . $url;
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
    # strip entries older than the older visits
    while (@times and $times[0] < $limit) {
      splice(@times, 0, 1);
    }
    # if we still have more than the number of elements required for
    # surge protection, delete these as well
    @times = @times[-$SurgeProtectionViews .. -1] if @times > $SurgeProtectionViews;
    $data .=  join($FS, $name, map { $_, $entries{$_}} @times) . "\n" if @times;
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
    my %reverse = (); # reverse hash to filter out duplicate targets
    foreach my $key (keys %entries) {
      $reverse{$entries{$key}} = $key;
    }
    my $what = join(', ', map { my ($id, $url) = split(/$US/, $entries{$_});
				$q->a({-href=>$url}, $id); }
		    sort values %reverse);
    print $q->li($who, T('was here'), $when, T('and read'), $what);
  }
  print '</ul>' . $q->end_div();
  PrintFooter();
}
