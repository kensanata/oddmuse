#!/usr/bin/env perl
# ====================[ recapcha.pl                        ]====================

=head1 NAME

recaptcha - An Oddmuse module for adding footnotes to Oddmuse Wiki pages.

=head1 INSTALLATION

recaptcha is simply installable; simply:

=over

=item Move this file into the B<wiki/modules/> directory for your Oddmuse Wiki.

=item Register at https://admin.recaptcha.net/recaptcha/createsite/ for a
      site-specific, public/private key pair to the reCAPTCHA service.

=item Set the C<$ReCaptchaPublicKey> and C<$ReCaptchaPrivateKey> configuration
      variables in your site's configuration file (B<wiki/config.pl>) to
      whatever public and private key strings that registration allotted to you.
      See L<Configuration>, below.

=back

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: recaptcha.pl,v 1.6 2008/11/27 06:00:25 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

recaptcha is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw(
  $ReCaptchaPrivateKey
  $ReCaptchaPublicKey
  $ReCaptchaTheme
  $ReCaptchaTabIndex
  $ReCaptchaRememberAnswer
  $ReCaptchaSecretKey
  $ReCaptchaRequiredList
  %ReCaptchaProtectedForms
);

=head2 $ReCaptchaPublicKey

You must set this to the public key that the reCAPTCHA service allots to you on
registering for that service.

=cut
$ReCaptchaPublicKey  = 'XXX';

=head2 $ReCaptchaPrivateKey

You must set this to the private key that the reCAPTCHA service allots to you on
registering for that service.

=cut
$ReCaptchaPrivateKey = 'YYY';

=head2 $ReCaptchaTheme

A string identifying which of the following CSS themes to skin the embedded
reCAPTCHA with:

   string value   | notes
   ---------------+------
   'red'          | The default.
   'white'        |
   'blackglass'   |
   'clean'        | This is our recommended theme; see below.
   'custom'       | This is not recommended; see below.

You are recommended to use the 'clean' theme, as that tends to integrate more
aesthetically cleanly than the others. This requires some CSS styling on your
part, however, and is, therefore, not the default. For details, see:

   http://wiki.recaptcha.net/index.php/How_to_change_reCAPTCHA_colors

You are recommended not to use the 'custom' theme, as this extension does not
adequately support that theme, yet. For details, see:

  http://recaptcha.net/apidocs/captcha/client.html#Custom%20theming

=cut
$ReCaptchaTheme = undef;

=head2 $ReCaptchaTabIndex

An unsigned integer indicating the HTML form "tab index" of the embedded
reCAPTCHA. (The default should be fine, theoretically.)

=cut
$ReCaptchaTabIndex = undef;

=head2 $ReCaptchaRequiredList

The page name for exceptions, if defined. Every page linked to via WikiWord
or [[free link]] is considered to be a page which needs questions asked. All
other pages do not require questions asked. If not set, then all pages need
questions asked.

=cut
$ReCaptchaRequiredList = '';

=head2 $ReCaptchaRememberAnswer

If a user successfully answers the reCAPTCHA correctly, remember this in the
cookie and don't ask again.

=cut
$ReCaptchaRememberAnswer = 1;

=head2 $ReCaptchaSecretKey

The name of the reCAPTCHA parameter in the Oddmuse cookie. If some spam bot,
robot spider, or other malware program begins targetting this module, simply
change the name. This offers a "first line of defense." (Changing the value of
this secret key forces users to successfully answer a new reCAPTCHA.)

=cut
$ReCaptchaSecretKey = 'question';

# Forms using one of the following classes are protected.
%ReCaptchaProtectedForms = (
  'comment' =>     1,
  'edit upload' => 1,
  'edit text' =>   1
);

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&ReCaptchaInit);

sub ReCaptchaInit {
  $ReCaptchaRequiredList = FreeToNormal($ReCaptchaRequiredList);
  $AdminPages{$ReCaptchaRequiredList} = 1;
  $CookieParameters{$ReCaptchaSecretKey} = '';
  $InvisibleCookieParameters{$ReCaptchaSecretKey} = 1;
}

# ....................{ EDITING                            }....................
*OldReCaptchaGetEditForm = *GetEditForm;
*GetEditForm = *NewReCaptchaGetEditForm;

*OldReCaptchaGetCommentForm = *GetCommentForm;
*GetCommentForm = *NewReCaptchaGetCommentForm;

sub NewReCaptchaGetEditForm {
  return ReCaptchaQuestionAddTo(OldReCaptchaGetEditForm(@_));
}

sub NewReCaptchaGetCommentForm {
  return ReCaptchaQuestionAddTo(OldReCaptchaGetCommentForm(@_));
}

sub ReCaptchaQuestionAddTo {
  my $form = shift;

  if (not $upload
      and not ReCaptchaException(GetId())
      and not $ReCaptchaRememberAnswer && GetParam($ReCaptchaSecretKey, 0)
      and not UserIsEditor()) {
    $form =~
      s/(\Q<p><input type="submit" name="Save"\E)/ReCaptchaGetQuestion().$1/e;
  }

  return $form;
}

sub ReCaptchaGetQuestion {
  my $need_button = shift;

  # Unfortunately, "Captcha::reCAPTCHA" produces invalid HTML for the reCAPTCHA theme.
  # We must brute-force the proper HTML, instead.
# my %recaptcha_options = ();
# if (defined $ReCaptchaTheme)    { $recaptcha_options{theme} =    $ReCaptchaTheme; }
# if (defined $ReCaptchaTabIndex) { $recaptcha_options{tabindex} = $ReCaptchaTabIndex; }

  eval "use Captcha::reCAPTCHA";
  my $captcha_html = Captcha::reCAPTCHA->new()->get_html(
    $ReCaptchaPublicKey, undef, $ENV{'HTTPS'} eq 'on', undef);
  my $submit_html = $need_button ? $q->submit(-value=> T('Go!')) : '';
  my $options_html = '
<script type="text/javascript">
  var RecaptchaOptions = {
';
  if (defined $ReCaptchaTheme)    { $options_html .= "    theme : '$ReCaptchaTheme'\n"; }
  if (defined $ReCaptchaTabIndex) { $options_html .= "    tabindex : $ReCaptchaTabIndex\n"; }
  $options_html .= '  };
</script>';

  return $options_html.ReCaptchaGetQuestionHtml($captcha_html.$submit_html);
}

=head2 ReCaptchaGetQuestionHtml

Enclose the reCAPTCHA iframe in Oddmuse-specific HTML and CSS.

Wiki administrators are encouraged to replace this function with their own,
Wiki-specific function by redefining this function in B<config.pl>.

=cut
sub ReCaptchaGetQuestionHtml {
  my $question_html = shift;
  return $q->div({-class=> 'question'}, $ReCaptchaTheme eq 'clean'
    ? $q->p(T('Please type the following two words:')).$question_html
    : $q->p(T('Please answer this captcha:'         )).$question_html);
}

# ....................{ POSTING                            }....................
*OldReCaptchaDoPost = *DoPost;
*DoPost = *NewReCaptchaDoPost;

sub NewReCaptchaDoPost {
  my(@params) = @_;
  my $id = FreeToNormal(GetParam('title', undef));
  my $preview = GetParam('Preview', undef); # case matters!
  my $correct = 0;

  unless (UserIsEditor() or UserIsAdmin()
    or $ReCaptchaRememberAnswer && GetParam($ReCaptchaSecretKey, 0)
    or $preview
    or $correct = ReCaptchaCheckAnswer() # remember this!
    or ReCaptchaException($id)) {
    print GetHeader('', T('Edit Denied'), undef, undef, '403 FORBIDDEN');
    print $q->start_div({-class=>'error'});
    print $q->p(T('You did not answer correctly.'));
    print $q->start_form, ReCaptchaGetQuestion(1),
      (map { $q->hidden($_, '') }
       qw(title text oldtime summary recent_edit aftertext)), $q->end_form;
    print $q->end_div();
    PrintFooter();
    # logging to the error log file of the server
    # warn "Q: '$ReCaptchaQuestions[$question_num][0]', A: '$answer'\n";
    return;
  }

  if (not GetParam($ReCaptchaSecretKey, 0) and $correct) {
    SetParam($ReCaptchaSecretKey, 1);
  }

  return (OldReCaptchaDoPost(@params));
}

sub ReCaptchaCheckAnswer {
  eval "use Captcha::reCAPTCHA";
  my $result = Captcha::reCAPTCHA->new()->check_answer(
    $ReCaptchaPrivateKey,
    $ENV{'REMOTE_ADDR'},
    GetParam('recaptcha_challenge_field'),
    GetParam('recaptcha_response_field')
  );
  return $result->{is_valid};
}

# ....................{ ERROR-HANDLING                     }....................
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

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008             by B.w.Curry <http://www.raiazome.com>.
Copyright 2004, 2008       by Brock Wilcox <awwaiid@thelackthereof.org>.
Copyright 2006, 2007, 2008 by Alex Schroeder <alex@gnu.org>.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see L<http://www.gnu.org/licenses/>.

=cut
