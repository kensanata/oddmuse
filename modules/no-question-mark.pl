# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: no-question-mark.pl,v 1.1 2006/06/05 21:51:20 as Exp $</p>';

sub GetPageOrEditLink {
  my ($id, $text, $bracket, $free) = @_;
  $id = FreeToNormal($id);
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if (!$text && $resolved && $bracket) {
    $text = BracketLink(++$FootnoteNumber); # s/_/ /g happens further down!
    $class .= ' number';
    $title = $id; # override title
    $title =~ s/_/ /g if $free;
  }
  $text = "[$id]" if not $text and $bracket; # if the page exists with brackets and no text see above
  $text = $id if not $text;
  $text =~ s/_/ /g;
  if ($resolved) { # anchors don't exist as pages, therefore do not use $exists
    return ScriptLink(UrlEncode($resolved), $text, $class, undef, $title);
  } else {
    return GetEditLink($id, $text);
  }
}
