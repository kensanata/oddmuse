# Copyright (C) 2005  Fletcher T. Penney <fletcher@freeshell.org>
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
#
# This module stores additional information about a page when it is 
# first created:
#		created = the date the page is FIRST saved
#		originalAuthor = the username that first created a page
#
# Of course, you can customize this to store more information

$ModulesDescription .= '<p>$Id: creationdate.pl,v 1.1 2005/10/24 18:58:42 fletcherpenney Exp $</p>';

*CreationDateOldOpenPage = *OpenPage;
*OpenPage = CreationDateOpenPage;

sub CreationDateOpenPage{
	CreationDateOldOpenPage(@_);
	$Page{created} = $Now unless $Page{created} or $Page{revision};
	$Page{originalAuthor} = GetParam('username','') unless $Page{originalAuthor}
		or $Page{revision};
}
