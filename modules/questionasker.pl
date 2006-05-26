# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
# Copyright (C) 2006  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: questionasker.pl,v 1.4 2006/05/26 23:08:16 as Exp $</p>';

use vars qw(@QuestionaskerQuestions
	    $QuestionaskerRequiredList);

# The page name for exceptions, if defined. Every page linked to via
# WikiWord or [[free link]] is considered to be a page which needs
# questions asked. All other pages do not require questions asked. If
# not set, then all pages need questions asked.
$QuestionaskerRequiredList = '';

@QuestionaskerQuestions =
  (['What is the first letter of this question?' => sub { shift =~ /W/i }],
   ['How many letters are in the word "four"?' => sub { shift =~ /4|four/i }],
   ['Tell me any number between 1 and 10' => sub { shift =~ /^([1-9]|10|one|two|three|four|five|six|seven|eight|nine|ten)$/ }],
   ["How many lives does a cat have?" => sub { shift =~ /9|nine/i }],
   ["What is 2 + 4?" => sub { shift =~ /6|six/i }],
  );

*OldQuestionaskerDoPost = *DoPost;
*DoPost = *NewQuestionaskerDoPost;

sub NewQuestionaskerDoPost {
  my(@params) = @_;
  my $id = FreeToNormal(shift);
  my $question_num = GetParam('question_num', undef);
  my $answer = GetParam('answer', undef);
  unless(QuestionaskerException($id)
	 or UserIsAdmin()
	 or $QuestionaskerQuestions[$question_num][1]($answer)) {
    print GetHeader('', T('Edit Denied'), undef, undef, '403 FORBIDDEN');
    print $q->p(T('You did not answer correctly.'));
    print $q->p(T('Contact the wiki administrator for more information.'));
    return;
  }
  return (OldQuestionaskerDoPost(@params));
}

*OldQuestionaskerGetCommentForm = *GetCommentForm;
*GetCommentForm = *NewQuestionaskerGetCommentForm;

*OldQuestionaskerDoEdit = *DoEdit;
*DoEdit = *NewQuestionaskerDoEdit;
$Action{edit} = \&DoEdit;

sub NewQuestionaskerDoEdit {
  *OldQuestionaskerGetFormStart = *GetFormStart;
  *GetFormStart = *NewQuestionaskerGetFormStart;
  OldQuestionaskerDoEdit(@_);
}

sub NewQuestionaskerGetCommentForm {
  *OldQuestionaskerGetFormStart = *GetFormStart;
  *GetFormStart = *NewQuestionaskerGetFormStart;
  my $retval = OldQuestionaskerGetCommentForm(@_);
  *GetFormStart = *OldQuestionaskerGetFormStart;
  return $retval;
}

sub NewQuestionaskerGetFormStart {
  my $id = FreeToNormal(GetParam('id', ''));
  *GetFormStart = *OldQuestionaskerGetFormStart;
  my $retval = OldQuestionaskerGetFormStart(@_);
  $retval .= QuestionaskerGetQuestion()
    unless QuestionaskerException($id) or UserIsAdmin();
  return $retval;
}

sub QuestionaskerGetQuestion {
  my $question_number = int(rand(scalar(@QuestionaskerQuestions)));
  $retval .= "<p>To save this page you must answer this question:";
  $retval .= "<blockquote>";
  $retval .= $QuestionaskerQuestions[$question_number][0];
  $retval .= "<br/>";
  $retval .= "<input type=text name=answer />";
  $retval .= "<input type=hidden name=question_num value=$question_number />";
  $retval .= "</blockquote></p>";
  return $retval;
}

sub QuestionaskerException {
  my $id = shift;
  return 0 unless $QuestionaskerRequiredList and $id;
  my $data = GetPageContent($id);
  if ($WikiLinks) {
    while ($data =~ /$LinkPattern/g) {
      return 1 if FreeToNormal($1) eq $id;
    }
  }
  if ($FreeLinks) {
    while ($data =~ /\[\[$FreeLinkPattern\]\]/g) {
      return 1 if FreeToNormal($1) eq $id;
    }
  }
  return 0;
}
