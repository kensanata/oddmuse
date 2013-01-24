# Copyright (C) 2012  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/list-banned-content.pl">list-banned-content.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/BannedContent">Index Extension</a></p>';

$Action{'list-banned-content'} = \&DoListBannedContent;

sub DoListBannedContent {
  print GetHeader('', T('Banned Content'), '');
  my @pages = AllPagesList();
  print '<div class="content banned"><p>';
  foreach my $id (@pages) {
    OpenPage($id);
    my $rule = BannedContent($Page{text});
    if ($rule) {
      print GetPageLink($id) . ': ' . $rule . $q->br();
    }
  }
  print '</p></div>';
  PrintFooter();
}
