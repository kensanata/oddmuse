# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: not-found-handler.pl,v 1.4 2004/06/12 11:40:06 as Exp $</p>';

use vars qw($NotFoundHandlerDir);

$NotFoundHandlerDir = '/tmp/oddmuse/cache';

*OldNotFoundHandlerSave = *Save;
*Save = *NewNotFoundHandlerSave;

sub NewNotFoundHandlerSave {
  my @args = @_;
  my $id = $args[0];
  OldNotFoundHandlerSave(@args);
  mkdir($NotFoundHandlerDir) unless -d $NotFoundHandlerDir;
  if ($Page{revision} == 1) {
    # new page, regenerate all of them
    unlink(glob("$NotFoundHandlerDir/*"));
  } else {
    # unlinke PageName, PageName.en, PageName.de, etc.
    unlink("$NotFoundHandlerDir/$id", glob("$NotFoundHandlerDir/$id.[a-z][a-z]"));
  }
}

# Need to delete cache after maintenance, because the list of near
# pages might have changed.

*OldNotFoundHandlerDoMaintain = *DoMaintain;
*DoMaintain = *NewNotFoundHandlerDoMaintain;

sub NewNotFoundHandlerDoMaintain {
  OldNotFoundHandlerDoMaintain();
  unlink(glob("$NotFoundHandlerDir/*"));
}
