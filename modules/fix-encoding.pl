# Copyright (C) 2012  Alex Schroeder <alex@gnu.org>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/fix-encoding.pl">fix-encoding.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Fix_Encoding">Fix Encoding</a></p>';

$Action{'fix-encoding'} = \&FixEncoding;

sub FixEncoding {
  my $id = shift;
  ValidIdOrDie($id);
  RequestLockOrError();
  OpenPage($id);
  my $text = $Page{text};
  utf8::decode($text);
  Save($id, $text, 'fix encoding', 1) if $text ne $Page{text};
  ReleaseLock();
  ReBrowsePage($id);
}

push(@MyAdminCode, \&FixEncodingMenu);

sub FixEncodingMenu {
  my ($id, $menuref, $restref) = @_;
  if ($id) {
    push(@$menuref,
	 ScriptLink('action=fix-encoding;id=' . UrlEncode($id), T('Fix page encoding')));
  }
}
