# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
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

our ($q, %Page, %Action, %IndexHash, @MyAdminCode);

AddModuleDescription('rename-pages.pl', 'Rename Pages Extension');

$Action{'rename-page'} = \&RenamePage;

sub RenamePage {
  my $id = shift;
  my $to = GetParam('to', '');
  # check target
  ValidIdOrDie($to);
  OpenPage($to);
  ReportError(T('Target page already exists.'), '400 BAD REQUEST')
      if $IndexHash{$to} and not PageMarkedForDeletion();
  # check the source
  ValidIdOrDie($id);
  OpenPage($id);
  ReportError(T('Source page does not exist.'), '400 BAD REQUEST')
      if not $IndexHash{$id} or PageMarkedForDeletion();
  {
    # prevent posting from browsing the target right away
    local *ReBrowsePage = sub {};
    # renaming is a minor change
    SetParam('recent_edit', 'on');
    # copy text
    SetParam('text', $Page{text});
    SetParam('summary', Ts('Copied from %s', FreeToNormal($id)));
    DoPost($to);
    # create redirect
    SetParam('text', "#REDIRECT [[$to]]");
    SetParam('summary', Ts('Moved to %s', FreeToNormal($to)));
    DoPost($id);
  }
  # and now that we're done, go to the target
  ReBrowsePage($to);
}

push(@MyAdminCode, \&RenamePageMenu);

sub RenamePageMenu {
  my ($id, $menuref, $restref) = @_;
  my $name = FreeToNormal($id);
  if ($id) {
    push(@$menuref, GetFormStart()
	 . $q->label({-for=>'to'}, Ts('Rename %s to:', $name) . ' ')
	 . GetHiddenValue('action', 'rename-page')
	 . GetHiddenValue('id', $id)
	 . $q->textfield(-name=>'to', -size=>20)
	 . $q->submit('Do it'));
  }
}
