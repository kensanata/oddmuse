# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: localnames.pl,v 1.10 2005/12/22 10:52:16 as Exp $</p>';

use vars qw($LocalNamesPage $LocalNamesInit %LocalNames $LocalNamesCollect);

$LocalNamesPage = 'LocalNames';
$LocalNamesCollect = 0;

# do this later so that the user can customize $LocalNamesPage
push(@MyInitVariables, \&LocalNamesInit);

*OldLocalNamesReInit = *ReInit;
*ReInit = *NewLocalNamesReInit;

sub NewLocalNamesReInit {
  my $id = shift;
  OldLocalNamesReInit($id, @_);
  $LocalNamesInit = 0 if not $id or $id eq $LocalNamesPage;
}

# Just hook into NearLink stuff -- whenever near links are
# initialized, we initialize as well.  Add our stuff first, because
# local names have priority over near links.

sub LocalNamesInit {
  return if $LocalNamesInit; # just once, mod_perl!
  $LocalNamesInit = 1;
  %LocalNames = ();
  $LocalNamesPage = FreeToNormal($LocalNamesPage); # spaces to underscores
  push(@AdminPages, $LocalNamesPage);
  my $data = GetPageContent($LocalNamesPage);
  while ($data =~ m/\[$FullUrlPattern\s+([^\]]+?)\]/go) {
    my ($page, $url) = ($2, $1);
    my $id = FreeToNormal($page);
    # The entries in %NearSource will make sure that ResolveId will
    # call GetInterSiteUrl for our pages.
    $LocalNames{$id} = $url;
    # Add at the front to override near links.
    unshift(@{$NearSource{$id}}, $LocalNamesPage);
    # %NearSite is for fetching the list of pages -- we don't need that.
    # %NearSearch is for searching remote sites -- we don't need that.
  }
}

# Allow interlinks: We cannot just use %InterSite, because that would
# result in the same ULR for $LocalNamesPage all the time.

*OldLocalNamesGetInterSiteUrl = *GetInterSiteUrl;
*GetInterSiteUrl = *NewLocalNamesGetInterSiteUrl;

sub NewLocalNamesGetInterSiteUrl {
  my ($site, $page, $quote) = @_;
  if ($site eq $LocalNamesPage and $LocalNames{$page}) {
    return $LocalNames{$page}
  } else {
    return OldLocalNamesGetInterSiteUrl($site, $page, $quote);
  }
}

*LocalNamesOldSave = *Save;
*Save = *LocalNamesNewSave;

sub LocalNamesNewSave {
  LocalNamesOldSave(@_);
  my ($currentid, $text) = @_;
  # avoid recursion
  return if $currentid eq $LocalNamesPage or not $LocalNamesCollect;
  my $currentname = $currentid;
  $currentname =~ s/_/ /g;
  OpenPage($LocalNamesPage);
  my $localnames = $Page{text};
  my @collection = ();
  while ($text =~ /\[$FullUrlPattern\s+([^\]]+?)\]/g) {
    my ($page, $url) = ($2, $1);
    my $id = FreeToNormal($page);
    # canonical form with trimmed spaces and no underlines
    $page = $id;
    $page =~ s/_/ /g;
    # if the mapping exists already, do nothing
    next if ($LocalNames{$id} eq $url);
    push(@collection, $page);
    # if a different mapping exists already; change the old mapping to the new one
    # if the change fails (eg. the page name is not in canonical form), don't skip!
    next if $LocalNames{$id}
      and $localnames =~ s/\[$LocalNames{$id}\s+$page\]/[$url $page]/g;
    # add a new entry at the end
    $localnames .= "\n\n* [$url $page]"
      . Ts(" -- defined on %s", "[[$currentname]]");
  }
  # minor change
  Save($LocalNamesPage, $localnames,
       Tss("Local names defined on %1: %2", $currentname,
	   length(@collection > 1)
	   ? join(', and ',
		  join(', ', @collection[0 .. $#collection-1]),
		  @collection[-1])
	   : @collection), 1)
    unless $localnames eq $Page{text};
}
