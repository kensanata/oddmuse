# Copyright (C) 2008  Radomir Dopieralski <home@sheep.art.pl>
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

AddModuleDescription('nosearch.pl');

our ($q, @MyAdminCode);

*OldGetSearchLink = \&GetSearchLink;
*GetSearchLink = \&NewGetSearchLink;
sub NewGetSearchLink {
  my ($text, $class, $name, $title) = @_;
  $name = UrlEncode($name);
  $text =~ s/_/ /g;
  return $q->span({-class=>$class}, $text);
}

push(@MyAdminCode, \&BacklinksMenu);
sub BacklinksMenu {
  my ($id, $menuref, $restref) = @_;
  if ($id) {
      my $text = T('Backlinks');
      my $class = 'backlinks';
      my $name = 'backlinks';
      my $title = T('Click to search for references to this page');
      my $link = ScriptLink('search=' . $id, $text, $class, $name, $title);
      push(@$menuref, $link);
  }
}
