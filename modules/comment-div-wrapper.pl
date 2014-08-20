# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>

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

package OddMuse;

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/comment-div-wrapper.pl">comment-div-wrapper.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Comment_Div_Wrapper_Extension">Comment Div Wrapper Extension</a></p>';

my $CommentDiv = 0;
push(@MyRules, \&CommentDivWrapper);
$RuleOrder{\&CommentDivWrapper} = -50;

sub CommentDivWrapper {
  if (substr($OpenPageName, 0, length($CommentsPrefix)) eq $CommentsPrefix) {
    if (pos == 0 and not $CommentDiv) {
      $CommentDiv = 1;
      return '<div class="userComment">';
    }
  }
  if ($OpenPageName =~ /$CommentsPattern/o) {
    if ($bol and m/\G(\s*\n)*----+[ \t]*\n?/cg) {
      my $html = CloseHtmlEnvironments()
          . ($CommentDiv++ > 0 ? '</div>' : '<h2 id="commentsHeading">' . T('Comments:') . '</h2>') . '<div class="userComment">'
          . AddHtmlEnvironment('p');
      return $html;
    }
  }
  return undef;
}

# close final div
*OldCommentDivApplyRules = *ApplyRules;
*ApplyRules = *NewCommentDivApplyRules;

sub NewCommentDivApplyRules {
  my ($blocks, $flags) = OldCommentDivApplyRules(@_);
  if ($CommentDiv) {
    print '</div>';
    $blocks .= $FS . '</div>';
    $flags .= $FS . 0;
    $CommentDiv = 0;
  }
  return ($blocks, $flags);
}
