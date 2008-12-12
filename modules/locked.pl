# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: locked.pl,v 1.1 2008/12/12 13:34:41 as Exp $</p>';

$Action{locked} = \&DoLocked;

sub DoLocked {
  my $raw = GetParam('raw', 0);
  if ($raw) {
    print GetHttpHeader('text/plain'); # and ignore @menu
  } else {
    print GetHeader('', T('Locked Pages'), '');
    print $q->start_div({-class=>'content locked'}),
      $q->start_p();
  }
  foreach my $id (AllPagesList()) {
    PrintPage($id) if -f GetLockedPageFile($id);
  }
  if (!$raw) {
    print $q->end_p(), $q->end_div();
    PrintFooter();
  }
}

push(@MyAdminCode, \&LockedMenu);

sub LockedMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=locked', T('Locked Pages')));
}
