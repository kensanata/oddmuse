# Copyright (C) 2006  Matthias Dietrich <md (at) plusw (.) de>
# Copyright (C) 2005  Mathias Dahl <mathias . dahl at gmail dot com>
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

# This module offers the possibility to restrict viewing of "hidden"
# pages to only editors or admins. The restriction may be based
# on a pattern matching the page id or to a membership to a certain
# page cluster.

$ModulesDescription .= '<p>$Id: hiddenpages.pl,v 1.3 2006/02/22 17:30:26 as Exp $</p>';

use vars qw($HiddenCluster $HideEditorPages $HideAdminPages
$HideRegExEditor $HideRegExAdmin);

# $HiddenCluster is a cluster name for hidden pages. Default
# is pages in the cluster "HiddenPage". You can override this
# value in your config file.

$HiddenCluster = 'HiddenPage';

# $Hide*Pages sets the access level to hidden pages:
#  0 = Hidden pages visible to all
#  1 = Password required
# You can override this value in your config file.
# NOTE: Pages for Editors are also visible to Admins!

$HideEditorPages = 1;
$HideAdminPages = 1;

# $HideRegEx* are regular expressions to find hidden pages. Default is pages
# ending with "HiddenE" for editors and "Hidden" for admins. You can override
# this value in your config file.

$HideRegExEditor = 'HiddenE$';
$HideRegExAdmin = 'Hidden$';

*OldOpenPage = *OpenPage;
*OpenPage = *NewOpenPage;

sub NewOpenPage {
  # Get page id/name sent in to OpenPage
  my ($id) = @_;

  # Shield the Private pages
  my $hidden = 0;

  # Check for match of HiddenPages
  if ($id and $id =~ /$HideRegExEditor/) {
    $hidden = "edi";
  } elsif ($id and $id =~ /$HideRegExAdmin/) {
    $hidden = "adi";
  }

  # Check the different levels of access
  if ($hidden eq "edi" && $HideEditorPages == 1 && (!UserIsEditor() && !UserIsAdmin())) {
    ReportError(T("Only Editors are allowed to see this hidden page."), "401 Not Authorized");
  } elsif ($hidden eq "adi" && $HideAdminPages == 1 && !UserIsAdmin()) {
    ReportError(T("Only Admins are allowed to see this hidden page."), "401 Not Authorized");
  }

  # Give control back to OpenPage()
  OldOpenPage(@_);
}
