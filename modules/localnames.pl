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

$ModulesDescription .= '<p>$Id: localnames.pl,v 1.1 2004/07/01 17:48:28 as Exp $</p>';

use vars qw($LocalNamesPage);

$LocalNamesPage = 'LocalNames';

my %LocalNames = ();

# This variable has to be set to 0 every time the LocalNamesPage changes.
# Alternatively, set it to 0 on every request.
# Setting it to 0 when this file is loaded will break under mod_perl!

my $LocalNamesInit;

*OldLocalNamesInitVariables = *InitVariables;
*InitVariables = *NewLocalNamesInitVariables;

sub NewLocalNamesInitVariables {
  OldLocalNamesInitVariables();
  $LocalNamesInit = 0;
}

# Here is the key point: Change ResolveId!

*OldLocalNamesResolveId = *ResolveId;
*ResolveId = *NewLocalNamesResolveId;

sub NewLocalNamesResolveId {
  my @args = @_;
  my @result = OldLocalNamesResolveId(@args);
  my $id = shift(@args);
  if (not $#result) {
    LocalNamesInit() unless $LocalNamesInit;
    if ($LocalNames{$id}) {
      # Make sure we're offered to create a local copy of the page.
      $NearLinksUsed{$id} = 1;
      # Return source as title attribute, and use 'near' as a return
      # value, because this gives us the near link treatment in
      # BrowseResolvedPage.
      return ('near', $LocalNames{$id}, $LocalNamesPage);
    }
  }
  return @result;
}

sub LocalNamesInit {
  my $data = GetPageContent($LocalNamesPage);
  while ($data =~ m/\[$FullUrlPattern\s+([^\]]+?)\]/go) {
    my ($id, $url) = ($2, $1);
    $LocalNames{FreeToNormal($id)} = $url;
  }
  $LocalNamesInit = 1;
}
