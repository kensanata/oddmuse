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

$ModulesDescription .= '<p>$Id: link-all.pl,v 1.6 2004/11/15 00:12:20 as Exp $</p>';

push(@MyRules, \&LinkAllRule);
$RuleOrder{\&LinkAllRule} = 1000;

sub LinkAllRule {
  if (/\G([A-Za-z\x80-\xff]+)/gc) {
    my $oldpos = pos;
    Dirty($1);
    # print the word, or the link to the word
    print LinkAllGetPageLinkIfItExists($1);
    pos = $oldpos; # protect against changes in pos
    # the block is cached so we don't return anything
    return '';
  }
  return undef;
}

sub LinkAllGetPageLinkIfItExists {
  my $id = shift;
  AllPagesList() unless $IndexInit;
  if ($IndexHash{$id}) {
    return GetPageLink($id);
  } elsif (GetParam('define', 0)) {
    return GetEditLink($id, $id);
  } else {
    return $id;
  }
}

*OldLinkAllGetGotoBar = *GetGotoBar;
*GetGotoBar = *NewLinkAllGetGotoBar;

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
