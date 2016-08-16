# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#               2004  Niklas Volbers <mithrandir42@web.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This module offers the user the additional possibility to
# edit a page by double-clicking on it. The user must have
# JavaScript enabled for this to work.

use strict;
use v5.10;

AddModuleDescription('doubleclick.pl', 'Doubleclick Extension');

our ($ScriptName);

*OldDoubleclickGetHeader = \&GetHeader;
*GetHeader = \&NewDoubleclickGetHeader;

sub NewDoubleclickGetHeader {
    my $id = shift;
    my $html = OldDoubleclickGetHeader($id, @_);
    my $action = lc(GetParam('action', 'browse'));
    if (($action eq 'browse') and $id) {
        my $ondblclick="ondblclick=\"location.href='"
	    . $ScriptName . "?action=edit;id=" . $id . "'\"";
        $html =~ s/\<body /\<body $ondblclick /;
    }
    return $html;
}
