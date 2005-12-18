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

$ModulesDescription .= '<p>questionasker.pl (v1.1) - Answer a question to save the page.</p>';

use vars qw( @QuestionaskerQuestions $QuestionaskerBypass);

# Yes, this does what it sounds like it does... bypasses this whole thing
$QuestionaskerBypass = 'awwaiid';

@QuestionaskerQuestions = (
  #['What is the first letter of this question?' => sub { shift =~ /W/i }],

  #['How many letters are in the word "four"?' => sub { shift =~ /4|four/i }],

  #['Tell me any number between 1 and 10' => sub { $a=shift; ($a > 0 && $a < 11) }],

  ["Name a popular programming language<br>
    whose name is four letters long and starts with<br>
    a 'P' and ends in an 'L'" =>
    sub { shift =~ /perl/i }],

  ["How many lives does a cat have?" => sub { shift =~ /9|nine/i }],

  ["This old man came _____ home" => sub { shift =~ /rolling/i }],

  ["Why is a raven like a writing desk?<br>
    Just kidding. What is 2 + 4?" => sub { shift =~ /6|six/i }],

);

*OldQuestionaskerDoPost = *DoPost;
*DoPost = *NewQuestionaskerDoPost;

sub NewQuestionaskerDoPost {
  my(@params) = @_;
  my $question_num = GetParam('question_num', undef);
  my $answer = GetParam('answer', undef);
  my $bypass = GetParam('bypass', undef);

  unless($bypass eq $QuestionaskerBypass || $QuestionaskerQuestions[$question_num][1]($answer)) {
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
  *GetFormStart = *OldQuestionaskerGetFormStart;
  my $retval = OldQuestionaskerGetFormStart(@_);
  $retval .= QuestionaskerGetQuestion();
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


