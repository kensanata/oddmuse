# orphans.pl --- A module for oddmuse to show all orphaned pages on the wiki

# Copyright (C) 2004 Jorgen Schaefer <forcer@forcix.cx>

# Author: Jorgen Schaefer <forcer@forcix.cx>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# This module will show ALL orphaned pages, even whole orphaned
# subgraphs on this wiki.

$ModulesDescription .= '<p>$Id: orphans.pl,v 1.1 2004/05/29 20:43:14 as Exp $</p>';

# What is interesting to us?
@orphan_entrypoints = ($HomePage, $RCName);

$Action{orphans} = \&DoOrphans;

sub DoOrphans {
  if (GetParam('raw', 0)) {
    print GetHttpHeader('text/plain');
    PrintOrphans(GetOrphans());
  } else {
    print GetHeader('', QuoteHtml(T('Orphan List')), '');
    PrintOrphans(GetOrphans());
    PrintFooter();
  }
}

sub PrintOrphans {
  my @orphans = @_;
  if (GetParam('raw', 0)) {
    foreach my $page (@orphans) {
      print "$page\n";
    }
  } else {
    map { PrintPage($_); } @orphans;
  }
}

sub GetOrphans {
  my @allpages = AllPagesList();

  # GetFullLinkList results depend on wether we are raw or not...
  my $oldraw = GetParam('raw', 0);
  SetParam('raw', 1);
  my %links = %{GetFullLinkList()};
  SetParam('raw', $oldraw);

  my %alife;
  my @pagelist;
  my @orphans;

  @pagelist = @orphan_entrypoints;
  foreach my $page (@orphan_entrypoints) {
    $alife{$page} = 1;
  }

  while (@pagelist) {
    my $currpage = pop(@pagelist);
    foreach my $link (@{$links{$currpage}}) {
      $link =~ s/ /_/g;
      if (!$alife{$link}) {
        $alife{$link} = 1;
        push @pagelist, $link;
      }
    }
  }

  # Now return all the pages in @allpages that are not in %alife.
  foreach my $page (@allpages) {
    if (!$alife{$page}) {
      push(@orphans, $page);
    }
  }
  return @orphans;
}
