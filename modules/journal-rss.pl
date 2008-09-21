# Copyright (C) 2004, 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: journal-rss.pl,v 1.18 2008/09/21 22:15:14 as Exp $</p>';

$Action{journal} = \&DoJournalRss;

# Currently RSS works like RecentChanges, which is not what bloggers
# expect.  Produce a RSS feed that mimicks exactly how the journal tag
# works.

sub DoJournalRss {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  # Fake the result of GetRcLines()
  local *GetRcLines = *JournalRssGetRcLines;
  print GetHttpHeader('application/xml') . GetRcRss();
}

sub JournalRssGetRcLines {
  my $num = GetParam('rsslimit', 10);
  my $match = GetParam('match', '^\d\d\d\d-\d\d-\d\d');
  my $search = GetParam('search', '');
  my $reverse = GetParam('reverse', 0);
  my @pages = sort JournalSort (grep(/$match/, $search ? SearchTitleAndBody($search) : AllPagesList()));
  if ($reverse) {
    @pages = reverse @pages;
  }
  # FIXME: Missing 'future' and 'past' keywords.
  # FIXME: Do we need 'offset'? I don't think so.
  @pages = @pages[0 .. $num - 1] if $num ne 'all' and $#pages >= $num;
  # Generate artifical rows in the list to pass to GetRcRss. We need
  # to open every single page, because the meta-data ordinarily
  # available in the rc.log file is not available to us. This is why
  # we observe the rsslimit parameter. Without it, we would have to
  # open *all* date pages. This leads to the unfortunate situation
  # that the RC code can remove some more rows and then the end result
  # will be smaller than rsslimit. There is no alternative, however,
  # unless we copy the entire RC code. We could try to do better by
  # multiplying $num by a certain factor. In the *default* situation,
  # however, this will be inefficient as disk access is very slow. In
  # these non-default situations it might make more sense to require
  # users to explicitly pass a higher rsslimit.
  my @result = ();
  foreach my $id (@pages) {
    # Now save information required for saving the cache of the current page.
    local %Page;
    local $OpenPageName = '';
    OpenPage($id);
    # If this is a minor edit, get the timestamp of the last major
    # edit.
    if ($Page{minor}) {
      # Perhaps the old kept revision is gone due to $KeepMajor=0 or
      # admin.pl...
      eval {
	my %keep = GetKeptRevision($Page{lastmajor});
	$Page{ts} = $keep{ts};
      }
    }
    my @languages = split(/,/, $languages);
    push (@result, [$Page{ts}, $id, $Page{minor}, $Page{summary}, $Page{host},
		    $Page{username}, $Page{revision}, \@languages,
		    GetCluster($Page{text})]);
  }
  return @result;
}
