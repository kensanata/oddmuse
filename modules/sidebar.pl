# Copyright (C) 2004  Tilmann Holst
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

$ModulesDescription .= '<p>$Id: sidebar.pl,v 1.16 2006/08/06 23:18:08 as Exp $</p>';

use vars qw($SidebarName $SideBarOpenPageName);

# Include this page on every page:

$SidebarName = 'SideBar';

# do this later so that the user can customize $SidebarName
push(@MyInitVariables, \&SidebarInit);

sub SidebarInit {
  $SidebarName = FreeToNormal($SidebarName); # spaces to underscores
  $AdminPages{$SidebarName} = 1;
}

*OldSideBarGetHeader = *GetHeader;
*GetHeader = *NewSideBarGetHeader;

# this assumes that *all* calls to GetHeader will print!
sub NewSideBarGetHeader {
  my ($id) = @_;
  print OldSideBarGetHeader(@_);
  # While rendering, OpenPageName must point to the sidebar, so that
  # the form extension which checks whether the current page is locked
  # will check the SideBar lock and not the real page's lock.
  # On the other hand, when the sidebar contains a <toc>, the
  # generated toc should point to the headers of the real page.
  local $SideBarOpenPageName = $OpenPageName;
  local $OpenPageName = $SidebarName;
  print '<div class="sidebar">';
  # This makes sure that $Page{text} remains undisturbed.
  PrintWikiToHTML(GetPageContent($SidebarName));
  print '</div>';
  return '';
}
