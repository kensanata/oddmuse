# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

AddModuleDescripton('mac.pl', 'Mac');

use Unicode::Normalize;

*OldMacAllPagesList = *AllPagesList;
*AllPagesList = *NewMacAllPagesList;

sub NewMacAllPagesList {
  $refresh = GetParam('refresh', 0);
  if ($IndexInit && !$refresh) {
    return @IndexList;
  }
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

*OldMacGrepFiltered = *GrepFiltered;
*GrepFiltered = *NewMacGrepFiltered;

sub NewMacGrepFiltered {
  my @pages = OldMacGrepFiltered(@_);
  foreach my $id (@pages) {
    $id = NFC($id);
  }
  return @pages;
}

push(@MyInitVariables, \&MacFixEncoding);

sub MacFixEncoding {
  # disable grep if searching for non-ascii stuff:

  # $ mkdir /tmp/dir
  # $ echo schroeder > /tmp/dir/schroeder
  # $ echo schröder > /tmp/dir/schröder
  # $ echo SCHRÖDER > /tmp/dir/SCHRÖDER-UP # don't use SCHRÖDER because of HFS
  # $ grep -rli schröder /tmp/dir
  # /tmp/dir/schröder
  # $ grep -rli SCHRÖDER /tmp/dir
  # /tmp/dir/schröder
  #
  # Why is grep not finding the upper case variant in the SCHRÖDER-UP
  # file?

  $UseGrep = 0 if GetParam('search', '') =~ /[x{0080}-\x{fffd}]/;

  # the rest is only necessary if using namespaces.pl
  return unless %Namespaces;
  my %hash = ();
  for my $key (keys %Namespaces) {
    utf8::decode($key);
    $key = NFC($key);
    $hash{$key} = $NamespaceRoot . '/' . $key . '/';
  }
  %Namespaces = %hash;
  %hash = ();
  for my $key (keys %InterSite) {
    utf8::decode($key);
    $key = NFC($key);
    $hash{$key} = $Namespaces{$key} if $Namespaces{$key};
  }
  %InterSite = %hash;
}

# for drafts.pl

*OldMacDraftFiles = *DraftFiles;
*DraftFiles = *NewMacDraftFiles;

sub NewMacDraftFiles {
  return map { NFC($_) } OldMacDraftFiles(@_);
}
