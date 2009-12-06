# Copyright (C) 2004, 2005, 2009  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: anchors.pl,v 1.17 2009/12/06 19:26:33 as Exp $</p>';

push(@MyRules, \&AnchorsRule);

sub AnchorsRule {
  if (m/\G\[\[\#$FreeLinkPattern\]\]/gc) {
    return $q->a({-href=>'#' . FreeToNormal($1), -class=>'local anchor'}, $1);
  } elsif ($BracketWiki && m/\G\[\[\#$FreeLinkPattern\|([^\]]+)\]\]/gc) {
    return $q->a({-href=>'#' . FreeToNormal($1), -class=>'local anchor'}, $2);
  } elsif ($BracketWiki && m/\G(\[\[$FreeLinkPattern\#$FreeLinkPattern\|([^\]]+)\]\])/cog
	   or m/\G(\[\[\[$FreeLinkPattern\#$FreeLinkPattern\]\]\])/cog
	   or m/\G(\[\[$FreeLinkPattern\#$FreeLinkPattern\]\])/cog) {
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
      $title = $id; # override title
      $title =~ s/_/ /g if $free;
    }
    $text = $id unless $text;
    $text =~ s/_/ /g;
    return ScriptLink(UrlEncode($id), $text, $class, undef, $title);
  } elsif (m/\G\[\:$FreeLinkPattern\]/gc) {
    return $q->a({-name=>FreeToNormal($1), -class=>'anchor'}, '');
  }
  return undef;
}
