# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
# Copyright (C) 2006–2015  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;

AddModuleDescription('questionasker.pl', 'QuestionAsker Extension');

use vars qw($q $bol $FreeLinks $FreeLinkPattern $LinkPattern $WikiLinks @MyInitVariables %AdminPages %CookieParameters %InvisibleCookieParameters);
use vars qw(@QuestionaskerQuestions
	    $QuestionaskerRememberAnswer
	    $QuestionaskerSecretKey
	    $QuestionaskerRequiredList
	    %QuestionaskerProtectedForms);

# A list of arrays. The first element in each array is a string, the
# question to be asked. The second element is a subroutine which is
# passed the answer as the first argument.
@QuestionaskerQuestions =
  (['What is the first letter of this question?' => sub { shift =~ /^\s*W\s*$/i }],
   ['How many letters are in the word "four"?' => sub { shift =~ /^\s*(4|four)\s*$/i }],
   ['Tell me any number between 1 and 10' => sub { shift =~ /^\s*([1-9]|10|one|two|three|four|five|six|seven|eight|nine|ten)\s*$/ }],
   ["How many lives does a cat have?" => sub { shift =~ /^\s*(7|seven|9|nine)\s*$/i }],
   ["What is 2 + 4?" => sub { shift =~ /^\s*(6|six)\s*$/i }],
  );

# The page name for exceptions, if defined. Every page linked to via
# WikiWord or [[free link]] is considered to be a page which needs
# questions asked. All other pages do not require questions asked. If
# not set, then all pages need questions asked.
$QuestionaskerRequiredList = '';

# If a user answers a question correctly, remember this in the cookie
# and don't ask any further questions. The name of the parameter in
# the cookie can be changed should a spam bot target this module
# specifically. Changing the secret key will force all users to answer
# another question.
$QuestionaskerRememberAnswer = 1;
$QuestionaskerSecretKey = 'question';

# Forms using one of the following classes are protected.
%QuestionaskerProtectedForms = ('comment' => 1,
				'edit upload' => 1,
				'edit text' => 1,);

push(@MyInitVariables, \&QuestionaskerInit);

sub QuestionaskerInit {
  $QuestionaskerRequiredList = FreeToNormal($QuestionaskerRequiredList);
  $AdminPages{$QuestionaskerRequiredList} = 1;
  $CookieParameters{$QuestionaskerSecretKey} = '';
  $InvisibleCookieParameters{$QuestionaskerSecretKey} = 1;
}

*OldQuestionaskerDoPost = *DoPost;
*DoPost = *NewQuestionaskerDoPost;

sub NewQuestionaskerDoPost {
  my(@params) = @_;
  my $id = FreeToNormal(GetParam('title', undef));
  my $preview = GetParam('Preview', undef); # case matters!
  my $question_num = GetParam('question_num', undef);
  my $answer = GetParam('answer', undef);
  unless (UserIsEditor()
	  or $QuestionaskerRememberAnswer && GetParam($QuestionaskerSecretKey, 0)
	  or $preview
	  or $QuestionaskerQuestions[$question_num][1]($answer)
	  or QuestionaskerException($id)) {
    print GetHeader('', T('Edit Denied'), undef, undef, '403 FORBIDDEN');
    print $q->p(T('You did not answer correctly.'));
    print GetFormStart(), QuestionaskerGetQuestion(1),
      (map { $q->input({-type=>'hidden', -name=>$_,
			-value=>UnquoteHtml(GetParam($_))}) }
       qw(title text oldtime summary recent_edit aftertext)), $q->end_form;
    PrintFooter();
    # logging to the error log file of the server
    # warn "Q: '$QuestionaskerQuestions[$question_num][0]', A: '$answer'\n";
    return;
  }
  # Set the secret key only if a question has in fact been answered
  if (not GetParam($QuestionaskerSecretKey, 0)
      and $QuestionaskerQuestions[$question_num][1]($answer)) {
    SetParam($QuestionaskerSecretKey, 1)
  }
  return (OldQuestionaskerDoPost(@params));
}

*OldQuestionaskerGetEditForm = *GetEditForm;
*GetEditForm = *NewQuestionaskerGetEditForm;

sub NewQuestionaskerGetEditForm {
  return QuestionAddTo(OldQuestionaskerGetEditForm(@_), $_[1]);
}

*OldQuestionaskerGetCommentForm = *GetCommentForm;
*GetCommentForm = *NewQuestionaskerGetCommentForm;

sub NewQuestionaskerGetCommentForm {
  return QuestionAddTo(OldQuestionaskerGetCommentForm(@_));
}

sub QuestionAddTo {
  my ($form, $upload) = @_;
  if (not $upload
      and not QuestionaskerException(GetId())
      and not $QuestionaskerRememberAnswer && GetParam($QuestionaskerSecretKey, 0)
      and not UserIsEditor()) {
    my $question = QuestionaskerGetQuestion();
    $form =~ s/(.*)<p>(.*?)<label for="username">/$1$question<p>$2<label for="username">/;
  }
  return $form;
}

sub QuestionaskerGetQuestion {
  my $need_button = shift;
  my $button = $need_button ? $q->submit(-value=>T('Go!')) : '';
  my $question_number = int(rand(scalar(@QuestionaskerQuestions)));
  return $q->div({-class=>'question'},
		 $q->p(T('To save this page you must answer this question:')),
		 $q->blockquote($q->p($QuestionaskerQuestions[$question_number][0]),
				$q->p($q->input({-type=>'text', -name=>'answer'}),
				      $q->input({-type=>'hidden', -name=>'question_num',
						 -value=>$question_number}),
				      $button)));
}

sub QuestionaskerException {
  my $id = shift;
  return 0 unless $QuestionaskerRequiredList and $id;
  my $data = GetPageContent($QuestionaskerRequiredList);
  if ($WikiLinks) {
    while ($data =~ /$LinkPattern/g) {
      return 0 if FreeToNormal($1) eq $id;
    }
  }
  if ($FreeLinks) {
    while ($data =~ /\[\[$FreeLinkPattern\]\]/g) {
      return 0 if FreeToNormal($1) eq $id;
    }
  }
  return 1;
}
