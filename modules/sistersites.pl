# Copyright (C) 2007–2023  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('sistersites.pl', 'Sister Pages');

our (%Action, $ScriptName, $UsePathInfo, %NearSource, %PermanentAnchors);

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
  @pages = Matched(GetParam('match', ''), @pages);
  @pages = sort @pages;
  return @pages;
}
