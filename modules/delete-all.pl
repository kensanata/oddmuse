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

$ModulesDescription .= '<p>$Id: delete-all.pl,v 1.3 2006/09/07 20:37:29 as Exp $</p>';

use vars qw($DeletedAge);

$DeleteAge = 172800; # 2*24*60*60

*OldDelPageDeletable = *PageDeletable;
*PageDeletable = *NewDelPageDeletable;

# All pages will be deleted after two days of inactivity!
sub NewDelPageDeletable {
  return 1 if $Now - $Page{ts} > $DeleteAge;
  return OldDelPageDeletable(@_);
}
