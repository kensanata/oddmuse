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

$ModulesDescription .= '<p>$Id: dynamic-comments.pl,v 1.2 2005/07/13 19:25:02 as Exp $</p>';

$DefaultStyleSheet .= qq{
div.commenthidden { display:none; }
div.commentshown { display:block; background-color:#ffc; padding:1ex; }
} unless $DefaultStyleSheet =~ /commenthidden/; # mod_perl?

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

*DynamicCommentsOldGetPageLink = *GetPageLink;
*GetPageLink = *DynamicCommentsNewGetPageLink;

sub DynamicCommentsNewGetPageLink {
  my ($id, @rest) = @_;
  if ($CollectingJournal and $id =~ /^$CommentsPrefix(.*)/) {
    my $page = $1;
    my $title = $id;
    $title =~ s/_/ /g;
    return qq{<a href="javascript:togglecomments('$id')">$title</a>}
      . $q->div({-class=>commenthidden, -id=>$id},
		PageHtml($page),
	        DynamicCommentsOldGetPageLink($id, T('Add Comment')));
  } else {
    return DynamicCommentsOldGetPageLink($id, @rest);
  }
}
