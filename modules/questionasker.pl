
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

$ModulesDescription .= '<p>questionasker.pl (v0.2) - Answer a question to save the page.</p>';

*OldQuestionaskerDoPost = *DoPost;
*DoPost = *NewQuestionaskerDoPost;

use vars qw( $QuestionaskerQuestions );

@QuestionaskerQuestions = (
  ['What is the first letter of this question?' => sub { shift =~ /W/i }],
  ['How many letters are in the word "four"?' => sub { shift =~ /4|four/i }],
  ['Tell me any number between 1 and 10' => sub { $a=shift; ($a > 0 && $a < 11) }]
);

sub NewQuestionaskerDoPost {
  my(@params) = @_;
  my $question_num = GetParam('question_num', undef);
  my $answer = GetParam('answer', undef);

  unless($QuestionaskerQuestions[$question_num][1]($answer)) {
      print GetHeader('', T('Edit Denied'), undef, undef, '403 FORBIDDEN');
      print $q->p(T('You did not answer correctly.'));
      print $q->p(T('Contact the wiki administrator for more information.'));
      return;
  }

  return (OldQuestionaskerDoPost(@params));
}

*OldQuestionaskerDoEdit = *DoEdit;
*DoEdit = *NewQuestionaskerDoEdit;
$Action{edit} = \&DoEdit;

sub NewQuestionaskerDoEdit {
  my (@params) = @_;
  *OldQuestionaskerGetFormStart = *GetFormStart;
  *GetFormStart = *NewQuestionaskerGetFormStart;
  OldQuestionaskerDoEdit(@params);
}


sub NewQuestionaskerGetFormStart {
  my $retval = OldQuestionaskerGetFormStart(@_);
  my $question_number = int(rand(scalar(@QuestionaskerQuestions)));

  $retval .= "<p>To save this page you must answer this question:";
  $retval .= "<blockquote>";
  $retval .= $QuestionaskerQuestions[$question_number][0];
  $retval .= "<br/>";
  $retval .= "<input type=text name=answer />";
  $retval .= "<input type=hidden name=question_num value=$question_number />";
  $retval .= "</blockquote></p>";

  # From now on use the original GetFormStart
  *GetFormStart = *OldQuestionaskerGetFormStart;
  return $retval;
}


