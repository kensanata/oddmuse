# Copyright (C) 2005–2015  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
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

AddModuleDescription('mac.pl', 'Mac');

our (%InterSite, %IndexHash, @IndexList, @MyInitVariables, %Namespaces, $NamespaceRoot);

use Unicode::Normalize;

*OldMacAllPagesList = \&AllPagesList;
*AllPagesList = \&NewMacAllPagesList;

sub NewMacAllPagesList {
  return @IndexList if @IndexList and not GetParam('refresh', 0);
  OldMacAllPagesList(@_);
  my @new = ();
  %IndexHash = ();
  foreach my $id (@IndexList) {
    $id = NFC($id);
    push(@new, $id);
    $IndexHash{$id} = 1;
  }
  @IndexList = @new;
  return @new;
}

*OldMacFiltered = \&Filtered;
*Filtered = \&NewMacFiltered;

sub NewMacFiltered {
  my @pages = OldMacFiltered(@_);
  foreach my $id (@pages) {
    $id = NFC($id);
  }
  return @pages;
}

push(@MyInitVariables, \&MacFixEncoding);

sub MacFixEncoding {
  # the rest is only necessary if using namespaces.pl
  return unless %Namespaces;
  my %hash = ();
  for my $key (keys %Namespaces) {
    $key = NFC($key);
    $hash{$key} = $NamespaceRoot . '/' . $key . '/';
  }
  %Namespaces = %hash;
  %hash = ();
  for my $key (keys %InterSite) {
    $key = NFC($key);
    $hash{$key} = $Namespaces{$key} if $Namespaces{$key};
  }
  %InterSite = %hash;
}

# for drafts.pl

*OldMacDraftFiles = \&DraftFiles;
*DraftFiles = \&NewMacDraftFiles;

sub NewMacDraftFiles {
  return map { NFC($_) } OldMacDraftFiles(@_);
}
