# Copyright (C) 2004, 2006, 2007, 2008, 2009  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: journal-rss.pl,v 1.24 2010/12/04 15:13:53 as Exp $</p>';

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
  my @result = ();
  foreach my $id (@pages) {
    # Now save information required for saving the cache of the current page.
    local %Page;
    local $OpenPageName = '';
    OpenPage($id);
    # If this is a minor edit, ignore it. Load the last major revision
    # instead, if you can.
    if ($Page{minor}) {
      # Perhaps the old kept revision is gone due to $KeepMajor=0 or
      # admin.pl or because a page was created as a minor change and
      # never edited. Reading kept revisions in this case results in
      # an error.
      eval {
 	%Page = GetKeptRevision($Page{lastmajor});
      };
      next if $@;
    }
    next if $Page{text} =~ /^\s*$/; # only whitespace is also to be deleted
    next if $DeletedPage && substr($Page{text}, 0, length($DeletedPage))
      eq $DeletedPage; # no regexp
    # Generate artifical rows in the list to pass to GetRcRss. We need
    # to open every single page, because the meta-data ordinarily
    # available in the rc.log file is not available to us. This is why
    # we observe the rsslimit parameter. Without it, we would have to
    # open *all* date pages.
    my @languages = split(/,/, $languages);
    push (@result, [$Page{ts}, $id, $Page{minor}, $Page{summary}, $Page{host},
		    $Page{username}, $Page{revision}, \@languages,
		    GetCluster($Page{text})]);
    last if $num ne 'all' and $#result + 1 >= $num;
  }
  return @result;
}

# Prevent near links from being printed as a result of the search.
push(@MyInitVariables, sub {
       $NearLinksException{journal} = 1;
     });
