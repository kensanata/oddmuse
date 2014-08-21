# Joiner - a user registration module for Oddmuse
#
# Copyright (C) 2014 Aki Goto <tyatsumi@gmail.com>
#
# Based on Login Module for Oddmuse (login.pl)
# Copyright (C) 2004  Fletcher T. Penney <fletcher@freeshell.org>
#
# Codes included from questionasker.pl for Oddmuse
# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
# Copyright (C) 2006, 2007  Alex Schroeder <alex@gnu.org>
#
# Codes included from ReCaptcha Extension for Oddmuse
# Copyleft  2008             by B.w.Curry <http://www.raiazome.com>.
# Copyright 2004, 2008       by Brock Wilcox <awwaiid@thelackthereof.org>.
# Copyright 2006, 2007, 2008 by Alex Schroeder <alex@gnu.org>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

AddModuleDescripton('joiner.pl', 'Joiner Extension');

=head1 DESCRIPTION

This is a user registration module for Oddmuse based on Fletcher's login.pl.
File locking and some functions are improved.

=head1 MENUS

When not logged in, 'Login' and 'Register' menus are shown on UserGotoBar.
When logged in, 'Logout' and 'Account Settings' menus are shown on UserGotoBar.
In 'Account Settings', you can change password and email address.
'Forgot Password?' menu is in 'Login' menu.

In Administration menu, 'Account Management' menu is shown.
In this menu, you can ban accounts.

=head1 REGISTRATION

To register account, use 'Register' menu.
You have to confirm the email address entered by visiting the link
on the confirmation email sent to the address.

=head1 CONFIGURATION

You can set configuration variables below.

$JoinerSalt:
To increase security for storing passwords, specify arbitrary string.
Default = ''.

$JoinerGeneratorSalt:
To increase security for auto generated passwords and ticket keys,
specify arbitrary string.
Default = ''.

$JoinerEmailSenderAddress
The sender address of the emails sent by this module.
Default = 'www-data@example.net'.

$JoinerCommentAllowed
If 0, you must loggin to write comments.
Default = 1.

$JoinerMinimumPasswordLength
Default = 6.

$JoinerWait
Retrying the email-sending commands is restricted to certain frequency.
Specify the waiting duration for retry in seconds.
Default = 60 * 10.

$JoinerQuestionModule
Specify cooperative anti-spam extension.
Supported values are 'Questionasker', 'ReCaptcha' and 'GdSecurityImage'.
Corresponding anti-spam extension need to be installed separately.
Default = (auto detect).

$JoinerDataDir
When using with Namespaces Extension, specify original root data directory
to concentrate Joiner data files in it.
Default = $DataDir.

$JoinerEmailCommand
The command used to send email.
Default = '/usr/sbin/sendmail -oi -t'.

$JoinerEmailRegExp
Email address format.
Default = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+$'.

=head1 DATA STRUCTURE

Account data is stored in $DataDir/joiner directory.
Registration pending email data is stored in $DataDir/joiner_email directory.
Their data format is same as wiki page's.

=cut

use vars qw($JoinerSalt $JoinerGeneratorSalt $JoinerEmailSenderAddress
  $JoinerCommentAllowed $JoinerMinimumPasswordLength $JoinerWait
  $JoinerQuestionModule $JoinerDataDir $JoinerEmailCommand $JoinerEmailRegExp);
use vars qw($JoinerDir $JoinerEmailDir $JoinerMessage $JoinerLoggedIn);

use Digest::MD5;

$Action{joiner_register} = \&JoinerDoRegister;
$Action{joiner_process_registration} = \&JoinerDoProcessRegistration;
$Action{joiner_confirm_registration} = \&JoinerDoConfirmRegistration;
$Action{joiner_login} = \&JoinerDoLogin;
$Action{joiner_process_login} = \&JoinerDoProcessLogin;
$Action{joiner_ticket} = \&JoinerDoProcessLogin;
$Action{joiner_logout} = \&JoinerDoLogout;
$Action{joiner_account_settings} = \&JoinerDoAccountSettings;
$Action{joiner_change_password} = \&JoinerDoChangePassword;
$Action{joiner_process_change_password} = \&JoinerDoProcessChangePassword;
$Action{joiner_forgot_password} = \&JoinerDoForgotPassword;
$Action{joiner_process_forgot_password} = \&JoinerDoProcessForgotPassword;
$Action{joiner_recover} = \&JoinerDoProcessLogin;
$Action{joiner_change_email} = \&JoinerDoChangeEmail;
$Action{joiner_process_change_email} = \&JoinerDoProcessChangeEmail;
$Action{joiner_confirm_email} = \&JoinerDoConfirmEmail;
$Action{joiner_manage} = \&JoinerDoManage;
$Action{joiner_ban} = \&JoinerDoBan;
$Action{joiner_process_ban} = \&JoinerDoProcessBan;

push(@MyAdminCode, \&JoinerAdminCode);
push(@MyInitVariables, \&JoinerInitVariables);

sub JoinerGetPasswordHash {
  my ($raw_password) = @_;
  return Digest::MD5::md5_hex($JoinerSalt . $raw_password);
}

sub JoinerRequestLockOrError {
  my ($name) = @_;
  # 10 tries, 3 second wait, die on error
  return RequestLockDir($name, 10, 3, 1);
}

sub JoinerGetEmailFile {
  my ($email) = @_;
  return "$JoinerEmailDir/$email.email";
}

sub JoinerGetAccountFile {
  my ($username) = @_;
  return "$JoinerDir/$username.account";
}

# Always call JoinerCreateAccount within a lock.
sub JoinerCreateAccount {
  my ($username, $password, $email, $key) = @_;

  my ($account_status, $account_data)
    = ReadFile(JoinerGetAccountFile($username));
  if ($status) {
    return T('Username:') . ' ' .
      Ts('The username %s already exists.', $username);
  }

  my ($email_status, $email_data) = ReadFile(JoinerGetEmailFile($email));
  my %email_page = ();
  if ($email_status) {
    %email_page = ParseData($email_data);
    if ($email_page{confirmed}) {
      return Ts('The email address %s has already been used.', $email);
    }
    if ($email_page{registration_time} + $JoinerWait > $Now) {
      my $min = 1 + int(($email_page{registration_time} + $JoinerWait - $Now) / 60);
      return Ts('Wait %s minutes before try again.', $min);
    }
  }
  %email_page = ();
  $email_page{username} = $username;
  $email_page{email} = $email;
  $email_page{confirmed} = 0;
  $email_page{registration_time} = $Now;
  CreateDir($JoinerEmailDir);
  WriteStringToFile(JoinerGetEmailFile($email), EncodePage(%email_page));

  my %page;
  $page{username} = $username;
  $page{password} = $password;
  $page{email} = $email;
  $page{key} = $key;
  $page{confirmed} = 0;
  $page{registration_time} = $Now;
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  return '';
}

sub JoinerSendRegistrationConfirmationEmail {
  my ($email, $username, $key) = @_;

  my $link = "$FullUrl?action=joiner_confirm_registration&joiner_username=" . UrlEncode($username) . "&joiner_key=$key";

  open (EMAIL, "| $JoinerEmailCommand");
  print EMAIL "To: $email\n";
  print EMAIL "From: $JoinerEmailSenderAddress\n";
  print EMAIL "Subject: $SiteName " . T('Registration Confirmation') . "\n";
  print EMAIL "\n";
  print EMAIL T('Visit the link blow to confirm registration.') . "\n";
  print EMAIL "\n";
  print EMAIL "$link\n";
  print EMAIL "\n";
  close EMAIL;
}

sub JoinerSendRecoverAccountEmail {
  my ($email, $username, $key) = @_;

  my $link = "$FullUrl?action=joiner_recover&joiner_username=" . UrlEncode($username) . "&joiner_key=$key";

  open (EMAIL, "| $JoinerEmailCommand");
  print EMAIL "To: $email\n";
  print EMAIL "From: $JoinerEmailSenderAddress\n";
  print EMAIL "Subject: " . T('Recover Account') . " - $SiteName\n";
  print EMAIL "\n";
  print EMAIL T('You can login by following the link below. Then set new password.') . "\n";
  print EMAIL "\n";
  print EMAIL "$link\n";
  print EMAIL "\n";
  close EMAIL;
}

sub JoinerSendChangeEmailEmail {
  my ($email, $username, $key) = @_;

  my $link = "$FullUrl?action=joiner_confirm_email&joiner_username=" . UrlEncode($username) . "&joiner_key=$key";

  open (EMAIL, "| $JoinerEmailCommand");
  print EMAIL "To: $email\n";
  print EMAIL "From: $JoinerEmailSenderAddress\n";
  print EMAIL "Subject: " . T('Change Email Address') . " - $SiteName\n";
  print EMAIL "\n";
  print EMAIL T('To confirm changing email address, follow the link below.') . "\n";
  print EMAIL "\n";
  print EMAIL "$link\n";
  print EMAIL "\n";
  close EMAIL;
}

sub JoinerQuestionaskerGetQuestion {
  my $need_button = shift;
  my $button = $need_button ? $q->submit(-value=>T('Go!')) : '';
  my $question_number = int(rand(scalar(@QuestionaskerQuestions)));
  return $q->div({-class=>'question'},
                 $q->p(T('To submit this form you must answer this question:')),
                 $q->blockquote($q->p($QuestionaskerQuestions[$question_number][0]),
                                $q->p($q->input({-type=>'text', -name=>'answer'}),
                                      $q->input({-type=>'hidden', -name=>'question_num',
                                                 -value=>$question_number}),
                                      $button)));
}

sub JoinerQuestionaskerCheck {
  my $question_num = GetParam('question_num', undef);
  my $answer = GetParam('answer', undef);
  unless (UserIsEditor()
          or $QuestionaskerRememberAnswer && GetParam($QuestionaskerSecretKey, 0)
          or $QuestionaskerQuestions[$question_num][1]($answer)) {
    # logging to the error log file of the server
    # warn "Q: '$QuestionaskerQuestions[$question_num][0]', A: '$answer'\n";
    return 0;
  }
  # Set the secret key only if a question has in fact been answered
  if (not GetParam($QuestionaskerSecretKey, 0)
      and $QuestionaskerQuestions[$question_num][1]($answer)) {
    SetParam($QuestionaskerSecretKey, 1)
  }
  return 1;
}

sub JoinerReCaptchaCheck {
  my $correct = 0;

  unless (UserIsEditor() or UserIsAdmin()
    or $ReCaptchaRememberAnswer && GetParam($ReCaptchaSecretKey, 0)
    or $correct = ReCaptchaCheckAnswer() # remember this!
    ) {
    # logging to the error log file of the server
    # warn "Q: '$ReCaptchaQuestions[$question_num][0]', A: '$answer'\n";
    return 0;
  }

  if (not GetParam($ReCaptchaSecretKey, 0) and $correct) {
    SetParam($ReCaptchaSecretKey, 1);
  }
  return 1;
}

sub JoinerGetQuestion {
  if ($JoinerQuestionModule eq 'Questionasker') {
    if (not $QuestionaskerRememberAnswer && GetParam($QuestionaskerSecretKey, 0)
        and not UserIsEditor()) {
      return JoinerQuestionaskerGetQuestion();
    }
  } elsif ($JoinerQuestionModule eq 'ReCaptcha') {
    if (not $ReCaptchaRememberAnswer && GetParam($ReCaptchaSecretKey, 0)
        and not UserIsEditor()) {
      return ReCaptchaGetQuestion();
    }
  } elsif ($JoinerQuestionModule eq 'GdSecurityImage') {
    return GdSecurityImageGetHtml();
  }
  return '';
}

sub JoinerCheckQuestion {
  if ($JoinerQuestionModule eq 'Questionasker') {
    if (!JoinerQuestionaskerCheck()) {
      $JoinerMessage = T('Question:') . ' ' . T('You did not answer correctly.');
      return 0;
    }
  } elsif ($JoinerQuestionModule eq 'ReCaptcha') {
    if (!JoinerReCaptchaCheck()) {
      $JoinerMessage = T('CAPTCHA:') . ' ' . T('You did not answer correctly.');
      return 0;
    }
  } elsif ($JoinerQuestionModule eq 'GdSecurityImage') {
    if (!GdSecurityImageCheck()) {
      $JoinerMessage = T('CAPTCHA:') . ' ' . T('Please type the six characters from the anti-spam image');
      return 0;
    }
  }
  return 1;
}

sub JoinerDoRegister {
  print GetHeader('', T('Registration'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print $q->start_p();
  print T('The username must be valid page name.');
  print $q->end_p();
  print $q->start_p();
  print T('Confirmation email will be sent to the email address.');
  print $q->end_p();

  print GetFormStart(undef, undef, undef);
  print $q->input({-type=>'hidden', -name=>'action', -value=>'joiner_process_registration'});
  my $table = '';
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_username'}, T('Username:'))),
    $q->td($q->textfield(-name=>'joiner_username', -id=>'joiner_username')));
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_password'}, T('Password:'))),
    $q->td($q->password_field(-name=>'joiner_password', -id=>'joiner_password')));
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_repeated_password'}, T('Repeat Password:'))),
    $q->td($q->password_field(-name=>'joiner_repeated_password', -id=>'joiner_repeated_password')));
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_email'}, T('Email:'))),
    $q->td($q->textfield(-name=>'joiner_email', -id=>'joiner_email')));
  $table .= $q->Tr($q->td(), $q->td($q->submit(-name=>'Submit', -value=>T('Submit'))));
  print $q->table($table);
  print JoinerGetQuestion();
  print $q->endform;

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoProcessRegistration {
  my $username = GetParam('joiner_username', '');
  my $password = GetParam('joiner_password', '');
  my $repeated_password = GetParam('joiner_repeated_password', '');
  my $email = GetParam('joiner_email', '');
  my $message;

  $message = ValidId($username);
  if ($message ne '') {
    $JoinerMessage = T('Username:') . ' ' . $message;
    JoinerDoRegister();
    return;
  }

  if (!($email =~ /$JoinerEmailRegExp/)) {
    $JoinerMessage = T('Email:') . ' ' . T('Bad email address format.');
    JoinerDoRegister();
    return;
  }

  if (length($password) < $JoinerMinimumPasswordLength) {
    $JoinerMessage = T('Password:') . ' ' . Ts('Password needs to have at least %s characters.', $JoinerMinimumPasswordLength);
    JoinerDoRegister();
    return;
  }
  if ($repeated_password ne $password) {
    $JoinerMessage = T('Password:') . ' ' . T('Repeat Password:') . ' ' . T('Passwords differ.');
    JoinerDoRegister();
    return;
  }

  if (!JoinerCheckQuestion()) {
    JoinerDoRegister();
    return;
  }

  my $hash = JoinerGetPasswordHash($password);
  my $key = Digest::MD5::md5_hex($JoinerGeneratorSalt . rand());
  JoinerRequestLockOrError('joiner');
  $message = JoinerCreateAccount($username, $hash, $email, $key);
  ReleaseLockDir('joiner');
  if ($message ne '') {
    $JoinerMessage = $message;
    JoinerDoRegister();
    return;
  }

  JoinerSendRegistrationConfirmationEmail($email, $username, $key);

  print GetHeader('', T('Email Sent'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print Ts('Confirmation email has been sent to %s. Visit the link on the mail to confirm registration.', $email);
  print $q->end_p();

  print $q->end_div();
  PrintFooter();
}

sub JoinerShowRegistrationConfirmationFailed {
  print GetHeader('', T('Failed to Confirm Registration'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoConfirmRegistration {
  my $username = GetParam('joiner_username', '');
  my $key = GetParam('joiner_key', '');

  $message = ValidId($username);
  if ($message ne '') {
    $JoinerMessage = T('Username:') . ' ' . $message;
    JoinerShowRegistrationConfirmationFailed();
    return;
  }

  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerMessage = T('Invalid key.');
    JoinerShowRegistrationConfirmationFailed();
    return;
  }
  my %page = ParseData($data);

  if ($key ne $page{key}) {
    $JoinerMessage = T('Invalid key.');
    JoinerShowRegistrationConfirmationFailed();
    return;
  }

  if ($page{registration_time} + $JoinerWait < $Now) {
    $JoinerMessage = T('The key expired.');
    JoinerShowRegistrationConfirmationFailed();
    return;
  }

  $page{key} = '';
  $page{confirmed} = 1;
  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  ReleaseLockDir('joiner');

  my $email = $page{email};
  JoinerRequestLockOrError('joiner');
  my ($email_status, $email_data) = ReadFile(JoinerGetEmailFile($email));
  ReleaseLockDir('joiner');
  if ($email_status) {
    my %email_page = ParseData($email_data);
    $email_page{confirmed} = 1;
    JoinerRequestLockOrError('joiner');
    CreateDir($JoinerEmailDir);
    WriteStringToFile(JoinerGetEmailFile($email), EncodePage(%email_page));
    ReleaseLockDir('joiner');
  }

  print GetHeader('', T('Registration Confirmed'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print T('Now, you can login by using username and password.');
  print $q->end_p();

  print $q->start_p();
  print ScriptLink('action=joiner_login', T('Login'));
  print $q->end_p();

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoLogin {
  print GetHeader('', T('Login'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print GetFormStart(undef, undef, undef);
  print $q->input({-type=>'hidden', -name=>'action', -value=>'joiner_process_login'});
  my $table = '';
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_username'}, T('Username:'))),
    $q->td($q->textfield(-name=>'joiner_username', -id=>'joiner_username')));
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_password'}, T('Password:'))),
    $q->td($q->password_field(-name=>'joiner_password', -id=>'joiner_password')));
  $table .= $q->Tr($q->td(), $q->td($q->submit(-name=>'Submit', -value=>T('Submit'))));
  print $q->table($table);
  print JoinerGetQuestion();
  print $q->endform;

  print $q->start_p();
  print ScriptLink('action=joiner_forgot_password', T('Forgot your password?'));
  print $q->end_p();

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoProcessLogin {
  my $username = GetParam('joiner_username', '');
  my $password = GetParam('joiner_password', '');
  my $key = GetParam('joiner_key', '');

  my $message = ValidId($username);
  if ($message ne '') {
    $JoinerMessage = T('Username:') . ' ' . $message;
    JoinerDoLogin();
    return;
  }

  if (!($key ne '' && $password eq '') && !JoinerCheckQuestion()) {
    JoinerDoLogin();
    return;
  }

  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerMessage = T('Login failed.');
    JoinerDoLogin();
    return;
  }
  my %page = ParseData($data);
  my $hash = JoinerGetPasswordHash($password);
  if ($hash eq $page{password}) {
    $page{recover} = 0;
    SetParam('joiner_recover', 0);
  } elsif ($key ne '' && $key eq $page{recover_key}) {
    if ($page{recover_time} + $JoinerWait < $Now) {
      $JoinerMessage = T('The key expired.');
      JoinerDoLogin();
      return;
    }
    $page{recover} = 1;
    SetParam('joiner_recover', 1);
  } else {
    $JoinerMessage = T('Login failed.');
    JoinerDoLogin();
    return;
  }
  if ($page{banned}) {
    $JoinerMessage = T('You are banned.');
    JoinerDoLogin();
    return;
  }

  if (!$page{confirmed}) {
    $JoinerMessage = T('You must confirm email address.');
    JoinerDoLogin();
    return;
  }

  my $session = Digest::MD5::md5_hex(rand());
  $page{session} = $session;
  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  ReleaseLockDir('joiner');

  SetParam('username', $username);
  SetParam('joiner_session', $session);

  print GetHeader('', T('Logged in'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print Ts('%s has logged in.', $username);
  print $q->end_p();

  if ($page{recover}) {
    print $q->start_p();
    print T('You should set new password immediately.');
    print $q->end_p();

    print $q->start_p();
    print ScriptLink('action=joiner_change_password', T('Change Password'));
    print $q->end_p();
  }

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoLogout {
  my $username = GetParam('username', '');

  SetParam('username', '');
  SetParam('joiner_session', '');

  print GetHeader('', T('Logged out'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print Ts('%s has logged out.', $username);
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoAccountSettings {
  if (!JoinerIsLoggedIn()) {
    JoinerDoLogin();
    return;
  }

  my $username = GetParam('username', '');

  print GetHeader('', T('Account Settings'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print T('Username:') . ' ' . $username;
  print $q->end_p();

  print $q->start_p();
  print ScriptLink('action=joiner_logout', T('Logout'));
  print $q->end_p();

  print $q->start_p();
  print ScriptLink('action=joiner_change_password', T('Change Password'));
  print $q->end_p();

  print $q->start_p();
  print ScriptLink('action=joiner_change_email', T('Change Email Address'));
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoChangePassword {
  if (!JoinerIsLoggedIn()) {
    JoinerDoLogin();
    return;
  }

  my $username = GetParam('username', '');
  my $recover = GetParam('joiner_recover', '');

  print GetHeader('', T('Change Password'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print GetFormStart(undef, undef, undef);
  print $q->input({-type=>'hidden', -name=>'action', -value=>'joiner_process_change_password'});
  my $table = '';
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_username'}, T('Username:'))),
    $q->td($username));
  if (!$recover) {
    $table .= $q->Tr($q->td($q->label({-for=>'joiner_current_password'}, T('Current Password:'))),
      $q->td($q->password_field(-name=>'joiner_current_password', -id=>'joiner_current_password')));
  }
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_new_password'}, T('New Password:'))),
    $q->td($q->password_field(-name=>'joiner_new_password', -id=>'joiner_new_password')));
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_repeat_new_password'}, T('Repeat New Password:'))),
    $q->td($q->password_field(-name=>'joiner_repeat_new_password', -id=>'joiner_repeat_new_password')));
  $table .= $q->Tr($q->td(), $q->td($q->submit(-name=>'Submit', -value=>T('Submit'))));
  print $q->table($table);
  print $q->endform;

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoProcessChangePassword {
  if (!JoinerIsLoggedIn()) {
    JoinerDoLogin();
    return;
  }

  my $username = GetParam('username', '');
  my $current_password = GetParam('joiner_current_password', '');
  my $new_password = GetParam('joiner_new_password', '');
  my $repeat_new_password = GetParam('joiner_repeat_new_password', '');

  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerMessage = T('Login failed.');
    JoinerDoChangePassword();
    return;
  }
  my %page = ParseData($data);
  my $hash = JoinerGetPasswordHash($current_password);
  if (!$page{recover} && $hash ne $page{password}) {
    $JoinerMessage = T('Current Password:') . ' ' . T('Password is wrong.');
    JoinerDoChangePassword();
    return;
  }

  if (length($new_password) < $JoinerMinimumPasswordLength) {
    $JoinerMessage = T('New Password:') . ' ' . Ts('Password needs to have at least %s characters.', $JoinerMinimumPasswordLength);
    JoinerDoChangePassword();
    return;
  }
  if ($repeat_new_password ne $new_password) {
    $JoinerMessage = T('New Password:') . ' ' . T('Repeat New Password:') . ' ' . T('Passwords differ.');
    JoinerDoChangePassword();
    return;
  }

  $page{password} = JoinerGetPasswordHash($new_password);
  $page{key} = '';
  $page{recover} = '';
  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  ReleaseLockDir('joiner');

  SetParam('joiner_recover', 0);

  print GetHeader('', T('Password Changed'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print T('Your password has been changed.');
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoForgotPassword {
  print GetHeader('', T('Forgot Password'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print $q->start_p();
  print T('Enter email address, and recovery login ticket will be sent.');
  print $q->end_p();

  print GetFormStart(undef, undef, undef);
  print $q->input({-type=>'hidden', -name=>'action', -value=>'joiner_process_forgot_password'});
  my $table = '';
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_email'}, T('Email:'))),
    $q->td($q->textfield(-name=>'joiner_email', -id=>'joiner_email')));
  $table .= $q->Tr($q->td(), $q->td($q->submit(-name=>'Submit', -value=>T('Submit'))));
  print $q->table($table);
  print JoinerGetQuestion();
  print $q->endform;

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoProcessForgotPassword {
  my $email = GetParam('joiner_email', '');

  if (!($email =~ /$JoinerEmailRegExp/)) {
    $JoinerMessage = T('Email:') . ' ' . T('Bad email address format.');
    JoinerDoForgotPassword();
    return;
  }

  if (!JoinerCheckQuestion()) {
    JoinerDoForgotPassword();
    return;
  }

  JoinerRequestLockOrError('joiner');
  my ($email_status, $email_data) = ReadFile(JoinerGetEmailFile($email));
  ReleaseLockDir('joiner');
  if (!$email_status) {
    $JoinerMessage = T('Email:') . ' ' . T('Not found.');
    JoinerDoForgotPassword();
    return;
  }
  my %email_page = ParseData($email_data);

  my $username = $email_page{username};
  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerMessage = T('Username:') . ' ' . T('Not found.');
    JoinerDoForgotPassword();
    return;
  }
  my %page = ParseData($data);

  if ($email ne $page{email}) {
    $JoinerMessage = T('The mail address is not valid anymore.');
    JoinerDoForgotPassword();
    return;
  }

  if ($page{recover_time} + $JoinerWait > $Now) {
    my $min = 1 + int(($page{recover_time} + $JoinerWait - $Now) / 60);
    $JoinerMessage = Ts('Wait %s minutes before try again.', $min);
    JoinerDoForgotPassword();
    return;
  }

  my $key = Digest::MD5::md5_hex($JoinerGeneratorSalt . rand());
  $page{recover_time} = $Now;
  $page{recover_key} = $key;
  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  ReleaseLockDir('joiner');

  JoinerSendRecoverAccountEmail($email, $username, $key);

  print GetHeader('', T('Email Sent'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print Ts('An email has been sent to %s with further instructions.', $email);
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoChangeEmail {
  if (!JoinerIsLoggedIn()) {
    JoinerDoLogin();
    return;
  }

  my $username = GetParam('username', '');

  print GetHeader('', T('Change Email Address'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print GetFormStart(undef, undef, undef);
  print $q->input({-type=>'hidden', -name=>'action', -value=>'joiner_process_change_email'});
  my $table = '';
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_username'}, T('Username:'))),
    $q->td($username));
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_email'}, T('New Email Address:'))),
    $q->td($q->textfield(-name=>'joiner_email', -id=>'joiner_email')));
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_password'}, T('Password:'))),
    $q->td($q->password_field(-name=>'joiner_password', -id=>'joiner_password')));
  $table .= $q->Tr($q->td(), $q->td($q->submit(-name=>'Submit', -value=>T('Submit'))));
  print $q->table($table);
  print $q->endform;

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoProcessChangeEmail {
  if (!JoinerIsLoggedIn()) {
    JoinerDoLogin();
    return;
  }

  my $username = GetParam('username', '');
  my $email = GetParam('joiner_email', '');
  my $password = GetParam('joiner_password', '');

  if (!($email =~ /$JoinerEmailRegExp/)) {
    $JoinerMessage = T('Email:') . ' ' . T('Bad email address format.');
    JoinerDoChangeEmail();
    return;
  }

  JoinerRequestLockOrError('joiner');
  my ($email_status, $email_data) = ReadFile(JoinerGetEmailFile($email));
  ReleaseLockDir('joiner');
  if ($email_status) {
    my %email_page = ParseData($email_data);
    if ($email_page{confirmed} && $email_page{username} ne $username) {
      $JoinerMessage = T('Email:') . ' ' .
        Ts('The email address %s has already been used.', $email);
      JoinerDoChangeEmail();
      return;
    }
  }

  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerMessage = T('Failed to load account.');
    JoinerDoChangeEmail();
    return;
  }
  my %page = ParseData($data);

  if ($page{change_email_time} + $JoinerWait > $Now) {
    my $min = 1 + int(($page{change_email_time} + $JoinerWait - $Now) / 60);
    $JoinerMessage = Ts('Wait %s minutes before try again.', $min);
    JoinerDoChangeEmail();
    return;
  }

  my $hash = JoinerGetPasswordHash($password);
  if ($hash ne $page{password}) {
    $JoinerMessage = T('Password:') . ' ' . T('Password is wrong.');
    JoinerDoChangeEmail();
    return;
  }

  my $key = Digest::MD5::md5_hex(rand());
  $page{change_email} = $email;
  $page{change_email_key} = $key;
  $page{change_email_time} = $Now;
  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  ReleaseLockDir('joiner');

  JoinerSendChangeEmailEmail($email, $username, $key);

  print GetHeader('', T('Email Sent'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print Ts('An email has been sent to %s with a login ticket.', $email);
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerShowConfirmEmailFailed {
  print GetHeader('', T('Confirmation Failed'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print $q->start_p();
  print T('Failed to confirm.');
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoConfirmEmail {
  my $username = GetParam('joiner_username', '');
  my $key = GetParam('joiner_key', '');

  $message = ValidId($username);
  if ($message ne '') {
    $JoinerMessage = $message;
    JoinerShowConfirmEmailFailed();
    return;
  }

  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerMessage = T('Failed to load account.');
    JoinerShowConfirmEmailFailed();
    return;
  }
  my %page = ParseData($data);

  if ($key ne $page{change_email_key}) {
    $JoinerMessage = T('Invalid key.');
    JoinerShowConfirmEmailFailed();
    return;
  }

  my $new_email = $page{change_email};
  $page{email} = $new_email;
  $page{change_email} = '';
  $page{change_email_key} = '';
  $page{change_email_time} = '';
  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  ReleaseLockDir('joiner');

  my %email_page = ();
  $email_page{username} = $username;
  $email_page{email} = $new_email;
  $email_page{confirmed} = 1;
  $email_page{registration_time} = $Now;
  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerEmailDir);
  WriteStringToFile(JoinerGetEmailFile($new_email), EncodePage(%email_page));
  ReleaseLockDir('joiner');

  print GetHeader('', T('Email Address Changed'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print Tss('Email address for %1 has been changed to %2.', $username, $new_email);
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoManage {
  UserIsAdminOrError();

  print GetHeader('', T('Account Management'), '');
  print $q->start_div({-class=>'joiner'});

  print $q->start_p();
  print ScriptLink('action=joiner_ban', T('Ban Account'));
  print $q->end_p();

  print $q->end_div();
  print PrintFooter();
}

sub JoinerDoBan {
  UserIsAdminOrError();

  print GetHeader('', T('Ban Account'), '');
  print $q->start_div({-class=>'joiner'});

  if ($JoinerMessage) {
    print $q->start_p() . $q->b($JoinerMessage) . $q->end_p();
  }

  print $q->start_p();
  print T('Enter username of the account to ban:');
  print $q->end_p();

  print GetFormStart(undef, undef, undef);
  print $q->input({-type=>'hidden', -name=>'action', -value=>'joiner_process_ban'});
  print $q->input({-type=>'hidden', -name=>'joiner_ban', -value=>'1'});
  my $table = '';
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_username'}, T('Username:'))),
    $q->td($q->textfield(-name=>'joiner_username', -id=>'joiner_username')));
  $table .= $q->Tr($q->td(), $q->td($q->submit(-name=>'Ban', -value=>T('Ban'))));
  print $q->table($table);
  print $q->endform;

  print $q->start_p();
  print T('Enter username of the account to unban:');
  print $q->end_p();

  print GetFormStart(undef, undef, undef);
  print $q->input({-type=>'hidden', -name=>'action', -value=>'joiner_process_ban'});
  print $q->input({-type=>'hidden', -name=>'joiner_ban', -value=>'0'});
  my $table = '';
  $table .= $q->Tr($q->td($q->label({-for=>'joiner_username'}, T('Username:'))),
    $q->td($q->textfield(-name=>'joiner_username', -id=>'joiner_username')));
  $table .= $q->Tr($q->td(), $q->td($q->submit(-name=>'Unban', -value=>T('Unban'))));
  print $q->table($table);
  print $q->endform;

  print $q->end_div();
  PrintFooter();
}

sub JoinerDoProcessBan {
  UserIsAdminOrError();

  $username = GetParam('joiner_username', '');
  $ban = GetParam('joiner_ban', '');

  $message = ValidId($username);
  if ($message ne '') {
    $JoinerMessage = $message;
    JoinerDoBan();
    return;
  }

  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerMessage = T('Failed to load account.');
    JoinerDoBan();
    return;
  }
  my %page = ParseData($data);

  if ($ban) {
    if ($page{banned}) {
      $JoinerMessage = Ts('%s is already banned.', $username);
      JoinerDoBan();
      return;
    }
    $page{banned} = 1;
    $page{session} = '';
    $JoinerMessage = Ts('%s has been banned.', $username);
  } else {
    if (!$page{banned}) {
      $JoinerMessage = Ts('%s is not banned.', $username);
      JoinerDoBan();
      return;
    }
    $page{banned} = 0;
    $JoinerMessage = Ts('%s has been unbanned.', $username);
  }

  JoinerRequestLockOrError('joiner');
  CreateDir($JoinerDir);
  WriteStringToFile(JoinerGetAccountFile($username), EncodePage(%page));
  ReleaseLockDir('joiner');

  JoinerDoBan();
}

sub JoinerIsLoggedIn {
  if ($JoinerLoggedIn ne '') {
    return $JoinerLoggedIn;
  }

  my $username = GetParam('username', '');
  my $session = GetParam('joiner_session', '');

  my $message = ValidId($username);
  if ($message ne '') {
    $JoinerLoggedIn = 0;
    return $JoinerLoggedIn;
  }

  JoinerRequestLockOrError('joiner');
  my ($status, $data) = ReadFile(JoinerGetAccountFile($username));
  ReleaseLockDir('joiner');
  if (!$status) {
    $JoinerLoggedIn = 0;
    return $JoinerLoggedIn;
  }
  my %page = ParseData($data);
  if (!$page{confirmed}) {
    $JoinerLoggedIn = 0;
    return $JoinerLoggedIn;
  }
  if ($session ne $page{session}) {
    $JoinerLoggedIn = 0;
    return $JoinerLoggedIn;
  }
  if ($page{banned}) {
    $JoinerLoggedIn = 0;
    return $JoinerLoggedIn;
  }

  $JoinerLoggedIn = 1;
  return $JoinerLoggedIn;
}

*OldJoinerUserCanEdit = *UserCanEdit;
*UserCanEdit = *NewJoinerUserCanEdit;

sub NewJoinerUserCanEdit {
  my ($id, $editing, $comment) = @_;
  if (!OldJoinerUserCanEdit($id, $editing, $comment)) {
    return 0;
  }

  return 1 if UserIsAdmin();
  return 1 if UserIsEditor();
  return 1 if $JoinerCommentAllowed and ($comment or (GetParam('aftertext', '') and not GetParam('text', '')));

  return JoinerIsLoggedIn();
}

*OldJoinerGetHeader = *GetHeader;
*GetHeader = *NewJoinerGetHeader;

sub NewJoinerGetHeader {
  if (JoinerIsLoggedIn()) {
    $UserGotoBar = ScriptLink('action=joiner_logout', T('Logout')) . ' ' .
      ScriptLink('action=joiner_account_settings', T('Account Settings')) . ' ' .
      $UserGotoBar;
  } else {
    $UserGotoBar = ScriptLink('action=joiner_login', T('Login')) . ' ' .
      ScriptLink('action=joiner_register', T('Register')) . ' ' .
      $UserGotoBar;
  }

  my ($id, $title, $oldId, $nocache, $status) = @_;
  return OldJoinerGetHeader($id, $title, $oldId, $nocache, $status);
}

sub JoinerAdminCode {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=joiner_manage', T('Account Management')));
}

sub JoinerInitVariables {
  $JoinerSalt = '' unless defined $JoinerSalt;
  $JoinerGeneratorSalt = '' unless defined $JoinerGeneratorSalt;
  $JoinerEmailSenderAddress = 'www-data@example.net' unless defined $JoinerEmailSenderAddress;
  $JoinerCommentAllowed = 1 unless defined $JoinerCommentAllowed;
  $JoinerMinimumPasswordLength = 6 unless defined $JoinerMinimumPasswordLength;
  $JoinerWait = 60 * 10 unless defined $JoinerWait;
  if (!defined($JoinerQuestionModule)) {
    if (defined &QuestionaskerInit) {
      $JoinerQuestionModule = 'Questionasker';
    } elsif (defined &ReCaptchaInit) {
      $JoinerQuestionModule = 'ReCaptcha';
    } elsif (defined &GdSecurityImageInitVariables) {
      $JoinerQuestionModule = 'GdSecurityImage';
    } else {
      $JoinerQuestionModule = '';
    }
  }
  $JoinerDataDir = $DataDir unless defined $JoinerDataDir;
  $JoinerEmailCommand = '/usr/sbin/sendmail -oi -t' unless defined $JoinerEmailCommand;
  $JoinerEmailRegExp = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+$' unless defined $JoinerEmailRegExp;

  $JoinerDir = "$JoinerDataDir/joiner";
  $JoinerEmailDir = "$JoinerDataDir/joiner_email";
  $JoinerLoggedIn = '';

  $CookieParameters{'joiner_session'} = '';
  $InvisibleCookieParameters{'joiner_session'} = 1;
  $CookieParameters{'joiner_recover'} = '';
  $InvisibleCookieParameters{'joiner_recover'} = 1;
}
