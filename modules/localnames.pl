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

$ModulesDescription .= '<p>$Id: localnames.pl,v 1.4 2005/01/07 01:18:02 as Exp $</p>';

use vars qw($LocalNamesPage);

$LocalNamesPage = 'LocalNames';

# do this later so that the user can customize $LocalNamesPage
push(@MyInitVariables, \&LocalNamesInit);

sub LocalNamesInit {
  $LocalNamesPage = FreeToNormal($LocalNamesPage); # spaces to underscores
  push(@AdminPages, $LocalNamesPage) unless grep(/$LocalNamesPage/, @AdminPages); # mod_perl!
}

my %LocalNames = ();

# Just hook into NearLink stuff -- whenever near links are
# initialized, we initialize as well.  Add our stuff first, because
# local names have priority over near links.

*LocalNamesOldNearInit = *NearInit;
*NearInit = *LocalNamesNewNearInit;

sub LocalNamesNewNearInit {
  my $data = GetPageContent($LocalNamesPage);
  while ($data =~ m/\[$FullUrlPattern\s+([^\]]+?)\]/go) {
    my ($id, $url) = ($2, $1);
    my $page = FreeToNormal($id);
    # Make sure we're listed in action=index;near=1
    $LocalNames{$page} = $url;
    push(@{$NearSource{$page}}, $LocalNamesPage);
    # %NearSite is for fetching the list of pages -- we don't need that.
  }
  LocalNamesOldNearInit();
}

# Now make sure we resolve correctly:

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
