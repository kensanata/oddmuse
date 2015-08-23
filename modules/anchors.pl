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
use v5.10;

AddModuleDescription('anchors.pl', 'Local Anchor Extension');

our ($q, %Page, $FootnoteNumber, $FreeLinkPattern, @MyRules, $BracketWiki);
push(@MyRules, \&AnchorsRule);

sub AnchorsRule {
  if (m/\G\[\[\#$FreeLinkPattern\]\]/cg) {
    return $q->a({-href=>'#' . FreeToNormal($1), -class=>'local anchor'}, $1);
  } elsif ($BracketWiki && m/\G\[\[\#$FreeLinkPattern\|([^\]]+)\]\]/cg) {
    return $q->a({-href=>'#' . FreeToNormal($1), -class=>'local anchor'}, $2);
  } elsif ($BracketWiki && m/\G(\[\[$FreeLinkPattern\#$FreeLinkPattern\|([^\]]+)\]\])/cg
	   or m/\G(\[\[\[$FreeLinkPattern\#$FreeLinkPattern\]\]\])/cg
	   or m/\G(\[\[$FreeLinkPattern\#$FreeLinkPattern\]\])/cg) {
    # This one is not a dirty rule because the output is always a page
    # link, never an edit link (unlike normal free links).
    my $bracket = (substr($1, 0, 3) eq '[[[');
    my $id = $2 . '#' . $3;
    my $text = $4;
    my $class = 'local anchor';
    my $title = '';
    $id = FreeToNormal($id);
    if (!$text && $bracket) {
      $text = BracketLink(++$FootnoteNumber); # s/_/ /g happens further down!
      $class .= ' number';
      # Since we're displaying a number such as [1], the title attribute should tell us where this will go.
      $title = "$2 ($3)";
      # The user might have writen [[[FooBar#one two]]] or [[[FooBar#one_two]]]
      $title =~ s/_/ /g;
    }
    $text = $id unless $text;
    $text =~ s/_/ /g;
    return ScriptLink(UrlEncode($id), $text, $class, undef, $title);
  } elsif (m/\G\[\:$FreeLinkPattern\]/cg) {
    return $q->a({-name=>FreeToNormal($1), -class=>'anchor'}, '');
  }
  return;
}

*OldAnchorsBrowsePage=\&BrowsePage;
*BrowsePage=\&NewAnchorsBrowsePage;

sub NewAnchorsBrowsePage {
  my ($id) = @_;
  OpenPage($id);
  if (not GetParam('revision', '')
      and not GetParam('oldid', '')
      and $Page{text} =~ /^\#REDIRECT\s+\[\[$FreeLinkPattern\#$FreeLinkPattern\]\]/) {
    return ReBrowsePage(FreeToNormal($1 . '#' . $2), $id);
  }
  return OldAnchorsBrowsePage(@_);
}
