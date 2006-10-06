# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: journal-rss.pl,v 1.9 2006/10/06 09:57:29 as Exp $</p>';

$Action{journal} = \&DoJournalRss;

# Currently RSS works like RecentChanges, which is not what bloggers
# expect.  Produce a RSS feed that mimicks exactly how the journal tag
# works.

# To do this, create an articifial @fullrc list to pass to RcRss.

sub DoJournalRss {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  my $num = GetParam('rsslimit', 10);
  my $match = GetParam('match', '^\d\d\d\d-\d\d-\d\d');
  my $reverse = GetParam('reverse', 0);
  my $past = GetParam('past', 0);
  my $future = GetParam('future', 0);
  my @pages = (grep(/$match/, AllPagesList()));
  if (defined &JournalSort) {
    @pages = sort JournalSort @pages;
  } else {
    @pages = sort {$b cmp $a} @pages;
  }
  if ($reverse) {
    @pages = reverse @pages;
  }
  # xor: if both future and reverse, do not reverse
  if ($reverse xor $future) {
    @pages = reverse @pages;
  }
  my $today = CalcDay($Now);
  if ($future) {
    for (my $i = 0; $i < @pages; $i++) {
      if ($pages[$i] gt $today) {
	@pages = @pages[$i..$#pages];
	last;
      }
    }
  } elsif ($past) {
    for (my $i = 0; $i < @pages; $i++) {
      if ($pages[$i] lt $today) {
	@pages = @pages[$i..$#pages];
	last;
      }
    }
  }
  # Generate artifical rows in the list to pass to GetRcRss.  We need
  # to open every single page, because the meta-data ordinarily
  # available in the rc.log file is not available to us.  This is why
  # we observe the rsslimit parameter.  Without it, we would have to
  # open *all* date pages.  This leads to the unfortunate situation
  # that GetRc can remove some more rows and then the end result will
  # be smaller than rsslimit.  There is no alternative, however,
  # unless we copy the entire GetRc code.  We could try to do better
  # by multiplying $num by a certain factor.  In the *default*
  # situation, however, this will be inefficient as disk access is
  # very slow.  In these non-default situations it might make more
  # sense to require users to explicitly pass a higher rsslimit.
  @pages = @pages[0 .. $num - 1] if $num ne 'all' and $#pages >= $num;
  my @fullrc = ();
  foreach my $id (@pages) {
    # Now save information required for saving the cache of the current page.
    local %Page;
    local $OpenPageName='';
    OpenPage($id);
    unshift (@fullrc, join($FS, $Page{ts}, $id, $Page{minor}, $Page{summary}, $Page{host},
			   $Page{username}, $Page{revision}, $Page{languages},
			   GetCluster($Page{text})));
  }
  # default to showedit=1 because most of these pages will have both
  # minor *and* major changes.
  SetParam('showedit', GetParam('showedit', 1));
  print GetHttpHeader('application/xml') . GetRcRss(@fullrc);
}
