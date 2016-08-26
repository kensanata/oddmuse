# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

use strict;
use v5.10;

AddModuleDescription('search-shortcut.pl', 'Comments on Searching');

our ($FullUrl);

*OldGetHeader = \&GetHeader;
*GetHeader = \&NewGetHeader;

sub NewGetHeader {
  my $html = OldGetHeader(@_);
  my $label = T('Search:');
  my $form = qq{<form class="tiny" action="$FullUrl"><p>$label }
    . qq{<input type="text" name="search" size="20" />}
    . qq{</p></form>};
  $html =~ s{</span>}{</span>$form};
  return $html;
}
