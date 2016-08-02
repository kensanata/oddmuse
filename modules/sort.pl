# Copyright (C) 2016  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

=head1 Sort Extension

This extension allows you to sort search results based on last update date and
based on creation date (if you have installed creationdate.pl).

=cut
    
AddModuleDescription('sort.pl', 'Sort Extension');

our ($q, @InitVariables, %Action, %Page, $OpenPageName);

my %SortUpdate;
my %SortCreation;

*OldSortSearchMenu = \&SearchMenu;
*SearchMenu = \&NewSortSearchMenu;

sub NewSortSearchMenu {
  my $html = OldSortSearchMenu(@_);
  my $string = UrlEncode(shift);
  $html .= ' ' . ScriptLink("search=$string;sort=update",
			    T('Sort by last update'));
  $html .= ' ' . ScriptLink("search=$string;sort=creation",
			    T('Sort by creation date'))
      if defined(&CreationDateOpenPage);
  return $html;
}

*OldSortSearchTitleAndBody = \&SearchTitleAndBody;
*SearchTitleAndBody = \&NewSortSearchTitleAndBody;

sub NewSortSearchTitleAndBody {
  my ($regex, $func, @args) = @_;
  %SortUpdate = ();
  %SortCreation = ();
  my @found = OldSortSearchTitleAndBody($regex);
  my $sort = GetParam('sort');
  if ($sort eq 'update') {
    # last updated means first
    @found = sort { $SortUpdate{$b} cmp $SortUpdate{$a} } @found;
  } elsif ($sort eq 'creation') {
    # first created means first
    @found = sort { $SortCreation{$a} cmp $SortCreation{$b} } @found;
  }
  for my $id (@found) {
    $func->($id, @args) if $func;
  }
  return @found;
}

# Taking advantage of the fact that OpenPage is called for every page, we use it
# to build our hashes.

*OldSortOpenPage = \&OpenPage;
*OpenPage = \&NewSortOpenPage;

sub NewSortOpenPage {
  my $value = OldSortOpenPage(@_);
  $SortUpdate{$OpenPageName} = $Page{ts};
  $SortCreation{$OpenPageName} = $Page{created};
  return $value; # I don't think anybody uses this?
}
