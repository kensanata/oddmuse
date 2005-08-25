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
# pages to only editors and admins.

$ModulesDescription .= '<p>$Id: hiddenpages.pl,v 1.1 2005/08/25 06:18:14 as Exp $</p>';

use vars qw($HiddenPages $HiddenPagesControl);

# $HiddenPages is a regular expression to find hidden pages. Default
# is pages ending in "Hidden". You can override this value in your
# config file.

$HiddenPages = 'Hidden$';

# $HiddenPagesAccess sets the access level to hidden pages:

# 0 = Hidden pages visible to all
# 1 = Editor access required
# 2 = Admin access required

# You can override this value in your config file.

$HiddenPagesAccess = 2;

*OldOpenPage = *OpenPage;
*OpenPage = *NewOpenPage;

sub NewOpenPage {
    # Get page id/name sent in to OpenPage
    my ($id) = @_;
    # Check for match
    if ($id =~ /$HiddenPages/ ) {
	# Check the different levels of access
	if ($HiddenPagesAccess == 1 and not UserIsEditor()) 
	{
	    ReportError(T("Only Editors are allowed to see hidden pages."), "401 Not Authorized");
	} elsif ($HiddenPagesAccess == 2 and not UserIsAdmin()) 
	{
	    ReportError(T("Only Admins are allowed to see hidden pages."), "401 Not Authorized");
	}
    }
    # Give control back to OpenPage()
    OldOpenPage(@_);
}
