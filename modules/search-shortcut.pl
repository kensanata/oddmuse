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

$ModulesDescription .= '<p>$Id: search-shortcut.pl,v 1.1 2007/01/16 15:56:11 as Exp $</p>';

*OldGetHeader = *GetHeader;
*GetHeader = *NewGetHeader;

sub NewGetHeader {
  my $html = OldGetHeader(@_);
  my $label = T('Search:');
  my $form = qq{<form class="tiny" action="$FullUrl"><p>$label }
    . qq{<input type="text" name="search" size="20" />}
    . qq{</p></form>};
  $html =~ s{</span>}{</span>$form};
  return $html;
}
