# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
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

push(@MyAdminCode, \&ListLockedMenu);

sub ListLockedMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=listlocked', T('List of locked pages'),
			     'list locked'));
}

$Action{listlocked} = \&DoListLocked;

sub DoListLocked {
  my $raw = GetParam('raw', 0);
  if ($raw) {
    print GetHttpHeader('text/plain'); # and ignore @menu
  } else {
    print GetHeader(undef, T('List of locked pages'));
    print $q->start_div({-class=>'content list locked'}), $q->start_p();
  }
  foreach my $id (AllPagesList()) {
    PrintPage($id) if -f GetLockedPageFile($id);
  }
  if (not $raw) {
    print $q->end_p(), $q->end_div();
    PrintFooter();
  }
}
