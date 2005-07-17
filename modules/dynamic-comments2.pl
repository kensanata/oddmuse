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

$ModulesDescription .= '<p>$Id: dynamic-comments2.pl,v 1.1 2005/07/17 01:33:32 as Exp $</p>';

$DefaultStyleSheet .= qq{
div.commenthidden { display:none; }
div.commentshown { display:block; background-color:#ffc; padding:1ex; }
} unless $DefaultStyleSheet =~ /commenthidden/; # mod_perl?

push(@MyInitVariables, \&DynamicCommentsAddScript);

sub DynamicCommentsAddScript {
  $HtmlHeaders .= Tss(qq{
<script type="text/Javascript">
function togglecomments (id) {
   var elem = document.getElementById(id);
   if (elem.className=="commentshown") {
      elem.className="commenthidden";
   }
   else {
      elem.className="commentshown";
   }
};
function insertcommentarea (id, user, home) {
   var elem = document.getElementById(id);
   var form = document.createElement("form");
   form.setAttribute("method", "POST");
   form.setAttribute("action", "%4");
   form.setAttribute("enctype", "application/x-www-form-urlencoded");
   var textarea = document.createElement("textarea");
   textarea.setAttribute("name", "aftertext");
   var p1 = document.createElement("p");
   p1.appendChild(textarea);
   var title = document.createElement("input");
   title.setAttribute("type", "hidden");
   title.setAttribute("name", "title");
   title.setAttribute("value", id);
   p1.appendChild(title);
   form.appendChild(p1);
   var p2 = document.createElement("p");
   p2.appendChild(document.createTextNode("%1 "));
   var username = document.createElement("input");
   username.setAttribute("type", "text");
   username.setAttribute("name", "username");
   username.setAttribute("size", 20);
   username.setAttribute("maxlength", 50);
   username.setAttribute("value", user);
   p2.appendChild(username);
   p2.appendChild(document.createTextNode(" " + "%2 "));
   var homepage = document.createElement("input");
   homepage.setAttribute("type", "text");
   homepage.setAttribute("name", "homepage");
   homepage.setAttribute("size", "20");
   homepage.setAttribute("maxlength", "50");
   homepage.setAttribute("value", home);
   p2.appendChild(homepage);
   form.appendChild(p2);
   var p3 = document.createElement("p");
   var submit = document.createElement("input");
   submit.setAttribute("type", "submit");
   submit.setAttribute("value", "%3");
   p3.appendChild(submit);
   form.appendChild(p3);
   var p = document.getElementById("add");
   elem.replaceChild(form, p);
}</script>
}, T('Username:'), T('Homepage URL:'), T('Save'), $FullUrl)
 unless $HtmlHeaders =~ /commenthidden/; # mod_perl?
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
      return $q->a({-href=>"javascript:togglecomments('$id')"}, $title)
        . '</p>' # close p before opening div
        . $q->div({-class=>commenthidden, -id=>$id},
                  $page,
                  $q->p({-id=>"add"},
			$q->a({-href=>Tss("javascript:insertcommentarea('$id', '%1', '%2')",
					  GetParam('username', ''), GetParam('homepage', ''))},
			     my $add = T('Add Comment'))))
        . '<p>'; # open an empty p that will be closed in PrintAllPages
    } else {
      return DynamicCommentsOldGetPageLink($id, T('Add Comment'));
    }
  } else {
    return DynamicCommentsOldGetPageLink($id, @rest);
  }
}
