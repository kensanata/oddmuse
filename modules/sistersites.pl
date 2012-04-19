# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/sistersites.pl">sistersites.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Sister_Pages">Sister Pages</a></p>';

$Action{'sisterpages'} = \&DoSisterPages;

sub DoSisterPages {
  print GetHttpHeader('text/plain');
  my @pages = SisterPages();
  foreach my $id (@pages) {
    print $ScriptName . ($UsePathInfo ? '/' : '?') . UrlEncode($id)
      . ' ' . NormalToFree($id) . "\n";
  }
}

# Mostly DoIndex() without the printing.
sub SisterPages {
  my @pages;
  push(@pages, AllPagesList()) if GetParam('pages', 1);
  push(@pages, keys %PermanentAnchors) if GetParam('permanentanchors', 1);
  push(@pages, keys %NearSource) if GetParam('near', 0);
  @pages = grep /$match/i, @pages if GetParam('match', '');
  return sort @pages;
}
