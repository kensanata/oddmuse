# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: gotobar.pl,v 1.1 2006/03/21 00:18:43 as Exp $</p>';

use vars qw($GotobarName);

# Include this page on every page:

$GotobarName = 'GotoBar';

# do this later so that the user can customize $GotobarName
push(@MyInitVariables, \&GotobarInit);

sub GotobarInit {
  $GotobarName = FreeToNormal($GotobarName); # spaces to underscores
  push(@AdminPages, $GotobarName) unless grep(/$GotobarName/, @AdminPages); # mod_perl!
  if ($IndexHash{$GotobarName}) {
    OpenPage($GotobarName);
    return if $DeletedPage && $Page{text} =~ /^\s*$DeletedPage\b/o;
    @UserGotoBarPages = ();
    while ($Page{text} =~ m/($LinkPattern|\[\[$FreeLinkPattern\]\])/og) {
      push(@UserGotoBarPages, $2||$3);
    }
  }
}
