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

$ModulesDescription .= '<p>$Id: localnames.pl,v 1.8 2005/10/28 15:20:55 as Exp $</p>';

use vars qw($LocalNamesPage $LocalNamesInit %LocalNames);

$LocalNamesPage = 'LocalNames';

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
    my ($id, $url) = ($2, $1);
    my $page = FreeToNormal($id);
    # The entries in %NearSource will make sure that ResolveId will
    # call GetInterSiteUrl for our pages.
    $LocalNames{$page} = $url;
    # Add at the front to override near links.
    unshift(@{$NearSource{$page}}, $LocalNamesPage);
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
