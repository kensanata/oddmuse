# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: dynamic-comments.pl,v 1.10 2011/07/06 19:18:01 as Exp $</p>';

push(@MyInitVariables, \&DynamicCommentsAddScript);

sub DynamicCommentsAddScript {
  $HtmlHeaders .= qq{
<script type="text/Javascript">
function togglecomments (id) {
   var elem = document.getElementById(id);
   if (elem.className=="commentshown") {
      elem.className="commenthidden";
   }
   else {
      elem.className="commentshown";
   }
}
</script>
} unless $HtmlHeaders =~ /commenthidden/; # mod_perl?
}

sub SafeId {
  my $id = shift;
  my $regexp = "";
  $regexp = "|\xc3[\x80-\x96\x98-\xb6\xb8-\xff]|[\xc4-\xca].|\xcb[\x00-\xbf]"
          . "|\xcd[\xb0-\xbd\xbf-\xff]|[\xce-\xDF].|\xe0..|\xe1[\x00-\xbe]."
          . "|\xe1\xbf[\x00-\xbf]|\xe2\x80[\x8c\x8d]"
      if $HttpCharset eq 'UTF-8';
  # Unicode Codepoint   UTF-8 encoding
  # [#xC0-#xD6]              c3 80 - c3 96
  # [#xD8-#xF6]              c3 98 - c3 b6
  # [#xF8-#x2FF]             c3 b8 - cb bf
  # [#x370-#x37D]            cd b0 - cd bd
  # [#x37F-#x1FFF]           cd bf - e1 bf bf
  # [#x200C-#x200D]       e2 80 8c - e2 80 8d
  # [#x2070-#x218F]       e2 81 b0 - e2 86 8f    -- FIXME \
  # [#x2C00-#x2FEF]       e2 b0 80 - e2 bf af    -- FIXME |
  # [#x3001-#xD7FF]       e3 80 81 - ed 9f bf    -- FIXME | these are missing
  # [#xF900-#xFDCF]       ef a4 80 - ef b7 8f    -- FIXME | in the regexp above
  # [#xFDF0-#xFFFD]       ef b7 b0 - ef bf bd    -- FIXME |
  # [#x10000-#xEFFFF]  f0 90 80 80 - f3 af bf bf -- FIXME /
  $id = ":$id" unless $id =~ /^[:_A-Za-z]$regexp/;
  return join('', $id =~ m/([-.:_A-Za-z0-9]$regexp)/g);
}

*DynamicCommentsOldGetPageLink = *GetPageLink;
*GetPageLink = *DynamicCommentsNewGetPageLink;

sub DynamicCommentsNewGetPageLink {
  my ($id, @rest) = @_;
  if ($CollectingJournal and $id =~ /^$CommentsPrefix/) {
    my $title = $id;
    $title =~ s/_/ /g;
    my $page = PageHtml($id);
    if ($page) {
      my $safe = SafeId($id);
      return qq{<a href="javascript:togglecomments('$safe')">$title</a>}
        . '</p>' # close p before opening div
        . $q->div({-class=>commenthidden, -id=>$safe},
                  $page,
                  $q->p(DynamicCommentsOldGetPageLink($id, T('Add Comment'))))
        . '<p>'; # open an empty p that will be closed in PrintAllPages
    } else {
      return DynamicCommentsOldGetPageLink($id, T('Add Comment'));
    }
  } else {
    return DynamicCommentsOldGetPageLink($id, @rest);
  }
}
