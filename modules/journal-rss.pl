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

$ModulesDescription .= '<p>$Id: journal-rss.pl,v 1.3 2004/10/10 15:06:39 as Exp $</p>';

$Action{journal} = \&DoJournalRss;

# Currently RSS works like RecentChanges, which is not what bloggers
# expect.  Produce a RSS feed that mimicks exactly how the journal tag
# works.

# To do this, create an articifial @fullrc list to pass to RcRss.

sub DoJournalRss {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  my $num = GetParam('num', 10);
  my $regexp = GetParam('regexp', '^\d\d\d\d-\d\d-\d\d');
  my $mode = GetParam('mode', '');
  my @pages = (grep(/$regexp/, AllPagesList()));
  if (defined &JournalSort) {
    @pages = sort JournalSort @pages;
  } else {
    @pages = sort {$b cmp $a} @pages;
  }
  if ($mode eq 'reverse') {
    @pages = reverse @pages;
  }
  @pages = @pages[0 .. $num - 1] if $#pages >= $num;
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
  print GetHttpHeader('application/rss+xml') . GetRcRss(@fullrc);
}
