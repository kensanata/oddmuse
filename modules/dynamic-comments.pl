# Copyright (C) 2005-2013  Alex Schroeder <alex@gnu.org>
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

AddModuleDescripton('dynamic-comments.pl', 'Dynamic Comments Extension');

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

my $num = 0;

*DynamicCommentsOldGetPageLink = *GetPageLink;
*GetPageLink = *DynamicCommentsNewGetPageLink;

sub DynamicCommentsNewGetPageLink {
  my ($id, @rest) = @_;
  if ($CollectingJournal and $id =~ /^$CommentsPrefix/) {
    my $title = $id;
    $title =~ s/_/ /g;
    my $page = PageHtml($id);
    if ($page) {
      my $anchor = "id" . $num++;
      return qq{<a href="javascript:togglecomments('$anchor')">$title</a>}
        . '</p>' # close p before opening div
        . $q->div({-class=>'commenthidden', -id=>$anchor},
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
