# Copyright (C) 2004–2021  Alex Schroeder <alex@gnu.org>
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

use strict;
use v5.10;

AddModuleDescription('journal-rss.pl', 'Journal RSS Extension');

our ($OpenPageName, $CollectingJournal, %Page, %Action, @MyInitVariables, $DeletedPage, %NearLinksException,
    $RecentLink, $SiteName, $SiteDescription, $ScriptName, $RssRights);
$Action{journal} = \&DoJournalRss;

# Currently RSS works like RecentChanges, which is not what bloggers
# expect.  Produce a RSS feed that mimicks exactly how the journal tag
# works.

sub DoJournalRss {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  # Fake the result of GetRcLines()
  local *GetRcLines = \&JournalRssGetRcLines;
  local *RcSelfAction = \&JournalRssSelfAction;
  local *RcPreviousAction = \&JournalRssPreviousAction;
  local *RcLastAction = \&JournalRssLastAction;
  SetParam('full', 1);
  if (GetParam('raw', 0)) {
    print GetHttpHeader('text/plain');
    print RcTextItem('title', $SiteName),
	RcTextItem('description', $SiteDescription), RcTextItem('link', $ScriptName),
	RcTextItem('generator', 'Oddmuse'), RcTextItem('rights', $RssRights);
    ProcessRcLines(sub {}, \&RcTextRevision);
  } else {
    print GetHttpHeader('application/xml') . GetRcRss();
  }
}

sub JournalRssParameters {
  my $more = '';
  foreach (@_, qw(rsslimit match search reverse monthly)) {
    my $val = GetParam($_, '');
    $more .= ";$_=" . UrlEncode($val) if $val;
  }
  return $more;
}

sub JournalRssSelfAction {
  return "action=journal" . JournalRssParameters(qw(offset));
}

sub JournalRssPreviousAction {
  my $num = GetParam('rsslimit', 10);
  my $offset = GetParam('offset', 0) + $num;
  return "action=journal;offset=$offset" . JournalRssParameters();
}

sub JournalRssLastAction {
  return "action=journal" . JournalRssParameters();
}

sub JournalRssGetRcLines {
  my $num = GetParam('rsslimit', 10);
  my $match = GetParam('match', '^\d\d\d\d-\d\d-\d\d');
  my $search = GetParam('search', '');
  my $reverse = GetParam('reverse', 0);
  my $monthly = GetParam('monthly', 0);
  my $offset = GetParam('offset', 0);
  my @pages = sort JournalSort (grep(/$match/, $search ? SearchTitleAndBody($search) : AllPagesList()));
  if ($monthly and not $match) {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime();
    $match = '^' . sprintf("%04d-%02d", $year+1900, $mon+1) . '-\d\d';
  }
  if ($reverse) {
    @pages = reverse @pages;
  }
  # FIXME: Missing 'future' and 'past' keywords.
  my @result = ();
  my $n = 0;
  foreach my $id (@pages) {
    # Now save information required for saving the cache of the current page.
    local %Page;
    local $OpenPageName = '';
    OpenPage($id);
    # If this is a minor edit, let's keep everything as it is, but show the date
    # of the last major change, if possible. This is important for blogs that
    # get added to a Planet. A minor change doesn't mean that the page needs to
    # go to the front of the Planet.
    if ($Page{minor} and $Page{lastmajor}) {
      my %major = GetKeptRevision($Page{lastmajor});
      $Page{ts} = $major{ts} if $major{ts};
    }
    next if $Page{text} =~ /^\s*$/; # only whitespace is also to be deleted
    next if $DeletedPage && substr($Page{text}, 0, length($DeletedPage))
	eq $DeletedPage; # no regexp
    # OK, this is a candidate page
    $n++;
    next if $n <= $offset;
    # Generate artifical rows in the list to pass to GetRcRss. We need
    # to open every single page, because the meta-data ordinarily
    # available in the rc.log file is not available to us. This is why
    # we observe the rsslimit parameter. Without it, we would have to
    # open *all* date pages.
    my @languages = split(/,/, $Page{languages});
    push (@result, [$Page{ts}, $id, $Page{minor}, $Page{summary}, $Page{host},
		    $Page{username}, $Page{revision}, \@languages,
		    GetCluster($Page{text})]);
    last if @result >= $num;
  }
  return @result;
}

# Prevent near links from being printed as a result of the search.
push(@MyInitVariables, sub {
       $NearLinksException{journal} = 1;
     });
