
# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
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

$ModulesDescription .= '<p>$Id: commentcount.pl,v 1.3 2004/11/20 22:24:25 as Exp $</p>';

*OldCommentcountAddComment = *AddComment;
*AddComment = *NewCommentcountAddComment;

sub NewCommentcountAddComment {
  my ($old, $comment) = @_;
  my $new = OldCommentcountAddComment($old,$comment);
  if($new eq $old) {
    # no comment added
  } else {
    my $num = $new;
    if($num =~ /=== (\d+) Comments\. ===/) {
      $num = $1;
      $num++;
      $new =~ s/=== (\d+) Comments\. ===/=== $num Comments. ===/;
    } else {
      $new = "=== 1 Comments. ===\n" . $new;
    }
  }
  return $new;
}

*OldCommentcountScriptLink = *ScriptLink;
*ScriptLink = *NewCommentcountScriptLink;

sub NewCommentcountScriptLink {
  my ($action, $text, @rest) = @_;
  if($text eq T('Comments on this page')) {
    # Add the number of comments here
    my $comments = GetPageContent($action);
    my $num = 0;
    if($comments =~ /=== (\d+) Comments\. ===/) {
      $num = $1;
    }
    # Plurality!
    $text =~ s/Comments/Comment/ if($num == 1);
    $text = $num . ' ' . $text;
  }
  return OldCommentcountScriptLink($action, $text, @rest);
}
