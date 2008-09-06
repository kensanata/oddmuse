# Copyright (C) 2004, 2008  Brock Wilcox <awwaiid@thelackthereof.org>
# Copyright (C) 2006, 2007, 2008  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: recaptcha.pl,v 1.2 2008/09/06 13:07:12 as Exp $</p>';

use vars qw(
  $ReCaptchaPrivateKey
  $ReCaptchaPublicKey
  $ReCaptchaRememberAnswer
  $ReCaptchaSecretKey
  $ReCaptchaRequiredList
  %ReCaptchaProtectedForms
);

# The ReCaptcha project requires registration for your domain, and then it will
# give you a private and public keypair
$ReCaptchaPublicKey  = 'XXX';
$ReCaptchaPrivateKey = 'YYY';

# The page name for exceptions, if defined. Every page linked to via
# WikiWord or [[free link]] is considered to be a page which needs
# questions asked. All other pages do not require questions asked. If
# not set, then all pages need questions asked.
$ReCaptchaRequiredList = '';

# If a user answers the captcha correctly, remember this in the cookie
# and don't ask again. The name of the parameter in
# the cookie can be changed should a spam bot target this module
# specifically. Changing the secret key will force all users to answer
# another question.
$ReCaptchaRememberAnswer = 1;
$ReCaptchaSecretKey = 'question';

# Forms using one of the following classes are protected.
%ReCaptchaProtectedForms = ('comment' => 1,
				'edit upload' => 1,
				'edit text' => 1,);

push(@MyInitVariables, \&ReCaptchaInit);

sub ReCaptchaInit {
  $ReCaptchaRequiredList = FreeToNormal($ReCaptchaRequiredList);
  $AdminPages{$ReCaptchaRequiredList} = 1;
  $CookieParameters{$ReCaptchaSecretKey} = '';
  $InvisibleCookieParameters{$ReCaptchaSecretKey} = 1;
}

*OldReCaptchaDoPost = *DoPost;
*DoPost = *NewReCaptchaDoPost;

sub NewReCaptchaDoPost {
  my(@params) = @_;
  my $id = FreeToNormal(GetParam('title', undef));
  my $preview = GetParam('Preview', undef); # case matters!
  unless (UserIsEditor()
	  or $ReCaptchaRememberAnswer && GetParam($ReCaptchaSecretKey, 0)
	  or $preview
      or ReCaptchaCheckAnswer()
	  or ReCaptchaException($id)) {
    print GetHeader('', T('Edit Denied'), undef, undef, '403 FORBIDDEN');
    print $q->p(T('You did not answer correctly.'));
    print $q->start_form, ReCaptchaGetQuestion(1),
      (map { $q->hidden($_, '') }
       qw(title text oldtime summary recent_edit aftertext)), $q->end_form;
    PrintFooter();
    # logging to the error log file of the server
    # warn "Q: '$ReCaptchaQuestions[$question_num][0]', A: '$answer'\n";
    return;
  }
  SetParam($ReCaptchaSecretKey, 1) unless GetParam($ReCaptchaSecretKey, 0);
  return (OldReCaptchaDoPost(@params));
}

*OldReCaptchaGetEditForm = *GetEditForm;
*GetEditForm = *NewReCaptchaGetEditForm;

sub NewReCaptchaGetEditForm {
  return ReCaptchaQuestionAddTo(OldReCaptchaGetEditForm(@_));
}

*OldReCaptchaGetCommentForm = *GetCommentForm;
*GetCommentForm = *NewReCaptchaGetCommentForm;

sub NewReCaptchaGetCommentForm {
  return ReCaptchaQuestionAddTo(OldReCaptchaGetCommentForm(@_));
}

sub ReCaptchaQuestionAddTo {
  my $form = shift;
  if (not $upload
      and not ReCaptchaException(GetId())
      and not $ReCaptchaRememberAnswer && GetParam($ReCaptchaSecretKey, 0)
      and not UserIsEditor()) {
    my $question = ReCaptchaGetQuestion();
    $form =~ s/<p><label for="username">/$question<p><label for="username">/;
  }
  return $form;
}

sub ReCaptchaGetQuestion {
  my $need_button = shift;
  my $button = $need_button ? $q->submit(-value=>T('Go!')) : '';
  eval "use Captcha::reCAPTCHA";
  my $captcha = Captcha::reCAPTCHA->new;
  my $captcha_html = $captcha->get_html( $ReCaptchaPublicKey );
  return $q->div({-class=>'question'},
		 $q->p(T('To save this page you must answer this captcha:')),
         $q->blockquote(
           $captcha_html,
           $button
         ));
}

sub ReCaptchaCheckAnswer {
  eval "use Captcha::reCAPTCHA";
  my $captcha = Captcha::reCAPTCHA->new;
  my $result = $captcha->check_answer(
    $ReCaptchaPrivateKey,
    $ENV{'REMOTE_ADDR'},
    GetParam('recaptcha_challenge_field'),
    GetParam('recaptcha_response_field')
  );
  return $result->{is_valid};
}

sub ReCaptchaException {
  my $id = shift;
  return 0 unless $ReCaptchaRequiredList and $id;
  my $data = GetPageContent($ReCaptchaRequiredList);
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
