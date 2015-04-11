# Copyright (C) 2004–2015  Alex Schroeder <alex@gnu.org>
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

AddModuleDescription('link-all.pl', 'Link All Words Extension');

our (%IndexHash, %RuleOrder, @MyRules, $UserGotoBar, $ScriptName);

push(@MyRules, \&LinkAllRule);
$RuleOrder{\&LinkAllRule} = 1000;

sub LinkAllRule {
  if (/\G([A-Za-z\x{0080}-\x{fffd}]+)/gc) {
    my $oldpos = pos;
    Dirty($1);
    # print the word, or the link to the word
    print LinkAllGetPageLinkIfItExists($1);
    pos = $oldpos; # protect against changes in pos
    # the block is cached so we don't return anything
    return '';
  }
  return;
}

sub LinkAllGetPageLinkIfItExists {
  my $id = shift;
  AllPagesList();
  if ($IndexHash{$id}) {
    return GetPageLink($id);
  } elsif (GetParam('define', 0)) {
    return GetEditLink($id, $id);
  } else {
    return $id;
  }
}

*OldLinkAllGetGotoBar = \&GetGotoBar;
*GetGotoBar = \&NewLinkAllGetGotoBar;

sub NewLinkAllGetGotoBar {
  my $id = shift;
  my $define = T('Define');
  my $addition = "<a href=\"$ScriptName?action=browse;id=$id;define=1\">$define</a>";
  if (index($UserGotoBar, $addition) < 0) {
    $UserGotoBar .= ' ' if $UserGotoBar;
    $UserGotoBar .= $addition;
  }
  return OldLinkAllGetGotoBar();
}
