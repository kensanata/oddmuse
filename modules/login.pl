# Copyright (C) 2004  Fletcher T. Penney <fletcher@freeshell.org>
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

$ModulesDescription .= '<p>$Id: login.pl,v 1.8 2006/08/06 11:47:14 as Exp $</p>';

#use vars qw($RegistrationForm $MinimumPasswordLength $RegistrationsMustBeApproved $LoginForm $PasswordFile $PendingPasswordFile $RequireLoginToEdit $ConfirmEmailAddress $ConfirmEmailAddress $UncomfirmedPasswordFile $EmailSenderAddress $EmailCommand $NotifyPendingRegistrations $EmailConfirmationMessage $ResetPasswordMessage $RegistrationForm $LogoutForm $ResetForm $ChangePassForm $RequireCamelUserName);

my $EncryptedPassword = "";

push(@MyAdminCode, \&LoginAdminRule);

$EmailRegExp = '[\w\.\-]+@([\w\-]+\.)+[\w]+';
$UsernameRegExp = '([A-Z][a-z]+){2,}';
$RequireCamelUserName = 0 unless defined $RequireCamelUserName;

$RequireLoginToEdit = 1 unless defined $RequireLoginToEdit;
$MinimumPasswordLength = 6 unless defined $MinimumPasswordLength;
$PasswordFile = "$DataDir/passwords" unless defined $PasswordFile;

$RegistrationsMustBeApproved = 1 unless defined $RegistrationsMustBeApproved;
$PendingPasswordFile = "$DataDir/pending" unless defined $PendingPasswordFile;

$ConfirmEmailAddress = 1 unless defined $ConfirmEmailAddress;
$UncomfirmedPasswordFile = "$DataDir/uncomfirmed" unless defined $UncomfirmedPasswordFile;

$EmailSenderAddress = "fletcher\@freeshell.org" unless defined $EmailSenderAddress;
$EmailCommand = "/usr/sbin/sendmail -oi -t" unless defined $EmailCommand;

$NotifyPendingRegistrations = "fletcher\@mercury.local" unless defined $NotifyPendingRegistrations;

$EmailConfirmationMessage = qq!From: $EmailSenderAddress
Subject: $SiteName Registration Confirmation	

This email address was used to create an account at $SiteName.  If you did not register at this site, you do not need to do anything.

Otherwise, in order to confirm your account, follow the link below.

Thank you...

! unless defined $EmailConfirmationMessage;

$ResetPasswordMessage = qq!From: $EmailSenderAddress
Subject: $SiteName Password Reset

We received a request to reset your password on our website.  Your password has been reset (see below).  You may log in and change to a password of your choice.

Thank you...

! unless defined $ResetPasswordMessage;

$PasswordFileToUse = $RegistrationsMustBeApproved 
		? $PendingPasswordFile : $PasswordFile;

$PasswordFileToUse = $ConfirmEmailAddress
		? $UncomfirmedPasswordFile : $PasswordFileToUse;

$RegistrationForm = <<'EOT' unless defined $RegistrationForm;
<p>Your Username should be a CamelCase form of your real name, e.g. JohnDoe.</p>

<p>Your password must be at least 6 characters long.</p>

<p>Your email address must be real, as a confirmation email will be sent to you.   Your email address will not be shared with anyone else, or used for any other purpose.</p>

<form method="post">
	<input type="hidden" name="action" value="process_registration" />
	<table class="form">
		<tr><td class="label">
			Username:
		</td><td class="input">
			<input type="text" name="username" value="%username%" />
		</td></tr>
		<tr><td class="label">
			Password:
		</td><td class="input">
			<input type="password" name="pwd1" value="" />
		</td></tr>
		<tr><td class="label">
			Reenter:
		</td><td class="input">
			<input type="password" name="pwd2" value="" />
		</td></tr>
		<tr><td class="label">
			Email:
		</td><td class="input">
			<input type="text" name="email" value="%email%" />
		</td></tr>
		<tr><td colspan="2" class="button">
			<input type="submit" value="Register" />
		</td></tr>
	</table>
</form>
EOT

$LoginForm = <<'EOT' unless defined $LoginForm;
<form method="post">
	<input type="hidden" name="action" value="process_login" />
	<table class="form">
		<tr><td class="label">
			Username:
		</td><td class="input">
			<input type="text" name="username" value="%username%" />
		</td></tr>
		<tr><td class="label">
			Password:
		</td><td class="input">
			<input type="password" name="pwd" value="" />
		</td></tr>
		<tr><td colspan="2" class="button">
			<input type="submit" value="Login" />
		</td></tr>
	</table>
</form>
EOT

$LogoutForm = <<'EOT' unless defined $LogoutForm;
<form method="post">
	<input type="hidden" name="action" value="process_logout" />
	<input type="hidden" name="pwd" value="" />
	<table class="form">
		<tr><td colspan="2" class="button">
			<input type="submit" value="Logout" />
		</td></tr>
	</table>
</form>
EOT

$ResetForm = <<'EOT' unless defined $ResetForm;
<p>Submit your username in order to reset your password.</p>
<p>A temporary password will be mailed to you.</p>
<form method="post">
	<input type="hidden" name="action" value="reset_password" />
	<input type="hidden" name="pwd" value="" />
	<table class="form">
		<tr><td class="label">
			Username:
		</td><td class="input">
			<input type="text" name="username" value="%username%" />
		</td></tr>
		<tr><td colspan="2" class="button">
			<input type="submit" value="Reset" />
		</td></tr>
	</table>
</form>
EOT

$ChangePassForm = <<'EOT' unless defined $ChangePassForm;
<form method="post">
	<input type="hidden" name="action" value="change_password" />
	<table class="form">
		<tr><td class="label">
			Username:
		</td><td class="input">
			<input type="text" name="username" value="%username%" />
		</td></tr>
		<tr><td class="label">
			Old Password:
		</td><td class="input">
			<input type="password" name="oldpwd" value="" />
		</td></tr>
		<tr><td class="label">
			Password:
		</td><td class="input">
			<input type="password" name="pwd1" value="" />
		</td></tr>
		<tr><td class="label">
			Reenter:
		</td><td class="input">
			<input type="password" name="pwd2" value="" />
		</td></tr>
		<tr><td colspan="2" class="button">
			<input type="submit" value="Submit" />
		</td></tr>
	</table>
</form>
EOT

$Action{register} = \&DoRegister;

sub DoRegister {
	my $id = shift;
	print GetHeader('', Ts('Register for %s', $SiteName), '');
	print '<div class="content">';
    $RegistrationForm =~ s/\%([a-z]+)\%/GetParam($1)/ige;
    $RegistrationForm =~ s/\$([a-z]+)\$/$q->span({-class=>'param'}, GetParam($1))
      . $q->input({-type=>'hidden', -name=>$1, -value=>GetParam($1)})/ge;
	print $RegistrationForm;
	print '</div>';
	PrintFooter();
}


$Action{process_registration} = \&DoProcessRegistration;

sub DoProcessRegistration {
	my $id = shift;
	my $username = GetParam('username', '');
	my $pwd1 = GetParam('pwd1', '');
	my $pwd2 = GetParam('pwd2', '');
	my $email = GetParam('email', '');

	if ($RequireCamelUserName) {
		ReportError(T('Please choose a username of the form "FirstLast" using your real name.'))
		unless ($username =~ /$UsernameRegExp/);
	}
	ReportError(T('The passwords do not match.'))
		unless ($pwd1 eq $pwd2);
	ReportError(Ts('The password must be at least %s characters.', $MinimumPasswordLength))
		unless (length($pwd1) > ($MinimumPasswordLength-1));
	ReportError(T('That email address is invalid.'))
		unless ($email =~ /$EmailRegExp/);
	ReportError(Ts('The username %s has already been registered.',$username))
		if (UserExists($username));

	print GetHeader('', Ts('Register for %s', $SiteName), '');

	if ($RegistrationsMustBeApproved) {
		if (AddUser($username,$pwd1,$email,$PasswordFileToUse)) {
			print Ts('Your registration for %s has been submitted.', $SiteName);
			print "  ";
			print T('Please allow time for the webmaster to approve your request.');
			print "  ";
			if ($ConfirmEmailAddress) {
				print Ts('An email has been sent to "%s" with further instructions.', $email);
				print "  ";
			} else {
				SendNotification($username);
			}
		} else {
			ReportError(T('There was an error saving your registration.'));
		}
	} else {
		if (AddUser($username, $pwd1, $email,$PasswordFileToUse)) {
			print Ts('An account was created for %s.',$username);
			print "  ";
			if ($ConfirmEmailAddress) {
				print Ts('An email has been sent to "%s" with further instructions.', $email);
				print "  ";
			}
		} else {
			ReportError(T('There was an error saving your registration.'));
		}
	}
	
	SendConfirmationEmail($username,$email) if ($ConfirmEmailAddress);
	
	PrintFooter();
}

$Action{login} = \&DoLogin;

sub DoLogin {
	my $id = shift;
	print GetHeader('', Ts('Login to %s', $SiteName), '');
	print '<div class="content">';
    $LoginForm =~ s/\%([a-z]+)\%/GetParam($1)/ge;
    $LoginForm =~ s/\$([a-z]+)\$/$q->span({-class=>'param'}, GetParam($1))
      . $q->input({-type=>'hidden', -name=>$1, -value=>GetParam($1)})/ge;
	print $LoginForm;
	print '</div>';
	PrintFooter();
}

$Action{process_login} = \&DoProcessLogin;

sub DoProcessLogin {
	my $id = shift;
	my $username = GetParam('username', '');
	my $pwd = GetParam('pwd', '');
	my $email = GetParam('email', '');

	ReportError(T('Username and/or password are incorrect.'))
		unless (AuthenticateUser($username,$pwd));

	unlink($IndexFile);
	print GetHeader('', Ts('Register for %s', $SiteName), '');
	print '<div class="content">';
	print Ts('Logged in as %s.', $username);
	print '</div>';
	PrintFooter();
}

$Action{logout} = \&DoLogout;

sub DoLogout {
	my $id = shift;
	print GetHeader('', Ts('Logout of %s', $SiteName), '');
	print '<div class="content">';
	print '<p>' . Ts('Logout of %s?',$SiteName) . '</p>';
    $LogoutForm =~ s/\%([a-z]+)\%/GetParam($1)/ge;
    $LogoutForm =~ s/\$([a-z]+)\$/$q->span({-class=>'param'}, GetParam($1))
      . $q->input({-type=>'hidden', -name=>$1, -value=>GetParam($1)})/ge;
	print $LogoutForm;
	print '</div>';
	PrintFooter();
}

$Action{process_logout} = \&DoProcessLogout;

sub DoProcessLogout {
	SetParam('pwd','');
	SetParam('username','');
	unlink($IndexFile);		# I shouldn't have to do this...
	print GetHeader('', Ts('Logged out of %s', $SiteName), '');
	print '<div class="content">';
	print T('You are now logged out.');
	print '</div>';
	PrintFooter();
}

sub UserExists {
	my $username = shift;
	if (open (PASSWD, $PasswordFile)) {
		while ( <PASSWD> ) {
			if ($_ =~ /^$username:/) {
				return 1;
			}
		}
	}
	close PASSWD;
	
	if ($RegistrationsMustBeApproved) {
		if (open (PASSWD, $PendingPasswordFile)) {
			while ( <PASSWD> ) {
				if ($_ =~ /^$username:/) {
					return 1;
				}
			}
		}
		close PASSWD;
	}

	if ($ConfirmEmailAddress) {
		if (open (PASSWD, $UncomfirmedPasswordFile)) {
			while ( <PASSWD> ) {
				if ($_ =~ /^$username:/) {
					return 1;
				}
			}
		}
		close PASSWD;
	}

	return 0;
}

sub AddUser {
	my ($username, $pwd, $email, $FileToUse) = @_;
	
	my @salts = (a..z,A..Z,0..9,'.','/');
	my $salt=$salts[rand @salts];
	$salt.=$salts[rand @salts];
	my $encrypted = crypt($pwd,$salt);
	$EncryptedPassword = $encrypted;
	
	my %passwords = ();
	my %emails = ();
	my $key;
	
	if (open (PASSWD, $FileToUse)) {
		while ( <PASSWD> ) {
			if ($_ =~ /^(.*):(.*):(.*)$/) {
				$passwords{$1}=$2;
				$emails{$1}=$3;
			}
		}
	}
	close PASSWD;

	$passwords{$username} = $encrypted;
	$emails{$username} = $email;

	open (PASSWD, ">$FileToUse");
	foreach $key ( sort keys(%passwords)) {
		print PASSWD "$key:$passwords{$key}:$emails{$key}\n";
	}
	close PASSWD;
	
	return 1;
}


*OldUserCanEdit = *UserCanEdit;
*UserCanEdit = *LoginUserCanEdit;

sub LoginUserCanEdit {
	my ($id, $editing) = @_;

	my $user = GetParam('username', '');
	my $pwd  = GetParam('pwd', '');

	if ($RequireLoginToEdit) {
			if ($user and $pwd) {
					# If not logged in, return 0.  Otherwise, let Oddmuse d$
					return 0 unless AuthenticateUser($user, $pwd);
					return OldUserCanEdit($id, $editing);
			}
			return 0;
	}
	return OldUserCanEdit($id, $editing);
}

sub AuthenticateUser {
	my ($username, $password) = @_;
	my $line;
	
	if (open(PASSWD, $PasswordFile)) {
		while ($line = <PASSWD>) {
			if ($line =~ /^$username:(.*):(.*)/) {
				if (crypt($password,$1) eq $1) {
					close PASSWD;
					return 1;
				}
			}
		}
	}
	close PASSWD;
	return 0;
}

sub LoginAdminRule {
	($id, $menuref, *restref) = @_;
	
	push(@$menuref, ScriptLink('action=register', T('Register a new account'), 'register'));
	push(@$menuref, ScriptLink('action=login', T('Login'), 'login'));
	push(@$menuref, ScriptLink('action=logout', T('Logout'), 'logout'));
	push(@$menuref, ScriptLink('action=whoami', T('Who am I?'), 'whoami'));
	push(@$menuref, ScriptLink('action=reset', T('Forgot your password?'), 'reset'));
	push(@$menuref, ScriptLink('action=change', T('Change your password'), 'change'));
	
	if (UserIsAdmin()) {
		push(@$menuref, ScriptLink('action=approve_pending', T('Approve pending registrations'), 'approve'));
	}
}

sub SendConfirmationEmail {
	my ($username, $email) = @_;
	my $key = $EncryptedPassword;
	my @salts = (a..z,A..Z,0..9,'.','/');
	my $salt=$salts[rand @salts];
	$salt.=$salts[rand @salts];
	my $encrypted = crypt($key,$salt);
	
	$confirmationLink = "$FullUrl?action=confirm_registration;account=$username;key=$encrypted;";
	
	open (MAIL, "| $EmailCommand");	
	print MAIL "To: $email\n$EmailConfirmationMessage\n\nClick on the following link to confirm:\n\n$confirmationLink\n\n";
	close MAIL;
	
}

$Action{confirm_registration} = \&DoConfirmRegistration;

sub DoConfirmRegistration {
	my $id = shift;
	my $account = GetParam('account', '');
	my $key = GetParam('key', '');
	
	if ( ConfirmUser($account,$key)) {
		print GetHeader('', Ts('Confirm Registration for %s', $SiteName), '');

		print Ts('%s, your registration has been approved. You can now use your password to login and edit this wiki.',$account);
		
		PrintFooter();
		
	} else {
		ReportError(Ts('Confirmation failed.  Please email %s for help.', $EmailSenderAddress));
	}
}


sub ConfirmUser {
	my ($username, $key) = @_;
	my $FileToUse = $RegistrationsMustBeApproved 
		? $PendingPasswordFile : $PasswordFileToUse;

	if (open(PASSWD, $UncomfirmedPasswordFile)) {
		while (<PASSWD>) {
			if ($_ =~ /^$username:(.*):(.*)/) {
				if (crypt($1,$key) eq $key) {
					AddUser($username,$1,$2,$FileToUse);
					close PASSWD;
					RemoveUser($username,$UncomfirmedPasswordFile);
					if ($RegistrationsMustBeApproved) {
						SendNotification($username);
					}
					return 1;
				}
			}
		}
	}
	return 0;
}


sub RemoveUser {
	my ($username, $FileToUse) = @_;
	
	my %passwords = ();
	my %emails = ();
	my $key;
	
	if (open (PASSWD, $FileToUse)) {
		while ( <PASSWD> ) {
			if ($_ =~ /^(.*):(.*):(.*)$/) {
				next if ($1 eq $username);
				$passwords{$1}=$2;
				$emails{$1}=$3;
			}
		}
	}
	close PASSWD;

	open (PASSWD, ">$FileToUse");
	foreach $key ( sort keys(%passwords)) {
		print PASSWD "$key:$passwords{$key}:$emails{$key}\n";
	}
	close PASSWD;
	
	return 1;
}

$Action{whoami} = \&DoWhoAmI;

sub DoWhoAmI {
	print GetHeader('', T('Who Am I?'), '');
	my $user = GetParam('username', '');
	my $pwd  = GetParam('pwd', '');

	if (AuthenticateUser($user, $pwd)) {
		print Ts('You are logged in as %s.',GetParam('username', ''));
	} else {
		print T('You are not logged in.');
	}
	PrintFooter();
}


$Action{reset_password} = \&DoResetPassword;

sub DoResetPassword {
	my $id = shift;
	my $username = GetParam('username', '');

	if (UserExists($username)) {
		my ($newpass, $newhash) = newpass();
		
		my $email = ChangePassword($username,$newhash);
		
		if ($email ne "") {
			print GetHeader('', T('Reset Password'), '');
			print Ts('The password for %s was reset.  It has been emailed to the address on file.',$username);
			PrintFooter();
			SendResetEmail($email,$newpass);
		} else {
			ReportError(Ts('There was an error resetting the password for %s.',$username));
		}		
	} else {
		ReportError(Ts('The username "%s" does not exist.',$username));
	}
}

sub newpass {
	# Create a random password
	
	my @salts = (a..z,A..Z,0..9,'.','/'); 
	my $salt=$salts[rand @salts];
	$salt.=$salts[rand @salts];
	
	my $password = $salts[rand @salts];
	
	for ( $i=0; $i < 7; $i++) {
		$password .= $salts[rand @salts];
	}
	
	my $hash = crypt($password, $salt);
	
	return ($password, $hash); 
}

sub ChangePassword {
	my ($user, $hash) = @_;
	
	my %passwords = ();
	my %emails = ();
	my $key;
	
	if (open (PASSWD, $PasswordFile)) {
		while ( <PASSWD> ) {
			if ($_ =~ /^(.*):(.*):(.*)$/) {
				$passwords{$1}=$2;
				$emails{$1}=$3;
			}
		}
	}
	close PASSWD;

	$passwords{$user} = $hash;

	open (PASSWD, ">$PasswordFile");
	foreach $key ( sort keys(%passwords)) {
		print PASSWD "$key:$passwords{$key}:$emails{$key}\n";
	}
	close PASSWD;

	return $emails{$user};
}

$Action{reset} = \&DoReset;

sub DoReset {
	my $id = shift;
	print GetHeader('', Ts('Reset Password for %s', $SiteName), '');
	print '<div class="content">';
	print '<p>' . T('Reset Password?') . '</p>';
    $ResetForm =~ s/\%([a-z]+)\%/GetParam($1)/ge;
    $ResetForm =~ s/\$([a-z]+)\$/$q->span({-class=>'param'}, GetParam($1))
      . $q->input({-type=>'hidden', -name=>$1, -value=>GetParam($1)})/ge;
	print $ResetForm;
	print '</div>';
	PrintFooter();
}

sub SendResetEmail {
	my ($email, $newpass) = @_;
	
	open (MAIL, "| $EmailCommand");	
	print MAIL "To: $email\n$EmailConfirmationMessage\n\nYour new temporary password:\n\n$newpass\n\n";
	close MAIL;
	
}


$Action{change} = \&DoChangePassword;

sub DoChangePassword {
	my $id = shift;
	print GetHeader('', Ts('Change Password for %s', $SiteName), '');
	print '<div class="content">';
	print '<p>' . T('Change Password?') . '</p>';
    $ChangePassForm =~ s/\%([a-z]+)\%/GetParam($1)/ge;
    $ChangePassForm =~ s/\$([a-z]+)\$/$q->span({-class=>'param'}, GetParam($1))
      . $q->input({-type=>'hidden', -name=>$1, -value=>GetParam($1)})/ge;
	print $ChangePassForm;
	print '</div>';
	PrintFooter();
}

$Action{change_password} = \&DoProcessChangePassword;

sub DoProcessChangePassword {
	my $id = shift;
	my $username = GetParam('username', '');
	my $pwd1 = GetParam('pwd1', '');
	my $pwd2 = GetParam('pwd2', '');
	my $oldpwd = GetParam('oldpwd', '');

	ReportError(T('Your current password is incorrect.')) if
		(! AuthenticateUser($username,$oldpwd));

	ReportError(T('The passwords do not match.'))
		unless ($pwd1 eq $pwd2);
	ReportError(Ts('The password must be at least %s characters.', $MinimumPasswordLength))
		unless (length($pwd1) > ($MinimumPasswordLength-1));

	print GetHeader('', Ts('Register for %s', $SiteName), '');
	
	my @salts = (a..z,A..Z,0..9,'.','/');
	my $salt=$salts[rand @salts];
	$salt.=$salts[rand @salts];
	my $encrypted = crypt($pwd1,$salt);

	ChangePassword($username,$encrypted);
	
	print T('Your password has been changed.');
	PrintFooter();
}

sub SendNotification {
	my $NewUser = shift;
	
	open (MAIL, "| $EmailCommand");
	print MAIL "To: $NotifyPendingRegistrations\nFrom: $EmailSenderAddress\nSubject: New User at $SiteName\n\nYou have a new pending registration at $SiteName:\n\n$NewUser\n\n";
	close MAIL;
}


$Action{approve_pending} = \&DoApprovePending;

sub DoApprovePending {
	my $id = shift;
	my $count = 0;

	my $ToBeApproved = GetParam('user','');
	
	UserIsAdminOrError();
	
	print GetHeader('', Ts('Approve Pending Registrations for %s', $SiteName), '');
	
	if ($ToBeApproved) {
		if (ApproveUser($ToBeApproved)) {
			print Ts('%s has been approved.',$ToBeApproved);
		} else {
			print Ts('There was an error approving %s.',$ToBeApproved);
		}
	} else {
		print T('<ul>');
		if (open(PASSWD, $PendingPasswordFile)) {
			while (<PASSWD>) {
				if ($_ =~ /^(.*):(.*):(.*)$/) {
					print Tss('<li>%1 - %2</li>',ScriptLink("action=approve_pending;user=$1;",$1),"$3");
					$count++;
				}
			}
		}
		print T('</ul>');
	
		if ($count == 0) {
			print T('There are no pending registrations.');
		}
	}
	
	PrintFooter();
}


sub ApproveUser {
	my ($username) = @_;

	if (open(PASSWD, $PendingPasswordFile)) {
		while (<PASSWD>) {
			if ($_ =~ /^$username:(.*):(.*)/) {
				AddUser($username,$1,$2,$PasswordFile);
				close PASSWD;
				RemoveUser($username,$PendingPasswordFile);
				return 1;
			}
		}
	}
	return 0;
}
