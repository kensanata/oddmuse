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

$ModulesDescription .= '<p>$Id: login.pl,v 1.1 2005/04/12 21:53:52 fletcherpenney Exp $</p>';

use vars qw($RegistrationForm $MinimumPasswordLength $RegistrationsMustBeApproved
$LoginForm $PasswordFile $PendingPasswordFile);

$EmailRegExp = '[\w\.\-]+@([\w\-]+\.)+[\w]+';
$UsernameRegExp = '([A-Z][a-z]+){2,}';

$MinimumPasswordLength = 6 unless defined $MinimumPasswordLength;
$RegistrationsMustBeApproved = 0 unless defined $RegistrationsMustBeApproved;
$PasswordFile = "$DataDir/passwords" unless defined $PasswordFile;
$PendingPasswordFile = "$DataDir/pending" unless defined $PendingPasswordFile;

$RegistrationForm = <<'EOT' unless defined $RegistrationForm;
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


$Action{register} = \&DoRegister;

sub DoRegister {
	my $id = shift;
	print GetHeader('', Ts('Register for %s', $SiteName), '');
	print '<div class="content">';
    $RegistrationForm =~ s/\%([a-z]+)\%/GetParam($1)/ge;
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

	ReportError(T('Please choose a username of the form "FirstLast" using your real name.'))
		unless ($username =~ /$UsernameRegExp/);
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
		print Ts('Your registration for %s has been submitted.', $SiteName);
		print T('  Please allow time for the webmaster to approve your request.');
	} else {
		print Ts('An account was created for %s.',$username) 
			if AddUser($username, $pwd1, $email);
	}  
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
	if ($RegistrationsMustBeApproved) {
		print T('  Please allow time for the webmaster to approve your request.');
	} else {
	}  
	print '</div>';
	PrintFooter();
}

$Action{logout} = \&DoLogout;

sub DoLogout {
	my $id = shift;
	print GetHeader('', Ts('Logout of %s', $SiteName), '');
	print '<div class="content">';
	print Ts('Logout of %s?',$SiteName);
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
		my $user_found = 0;
		while ( <PASSWD> ) {
			if ($_ =~ /^$username:/) {
				return 1;
			}
		}
	}
	close PASSWD;
	return 0;
}

sub AddUser {
	my ($username, $pwd, $email) = @_;
	
	my @salts = (a..z,A..Z,0..9,'.','/');
	my $salt=$salts[rand @salts];
	$salt.=$salts[rand @salts];
	my $encrypted = crypt($pwd,$salt);
	
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

	$passwords{$username} = $encrypted;
	$emails{$username} = $email;

	open (PASSWD, ">$PasswordFile");
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


	if ($user and $pwd) {
		# If not logged in, return 0.  Otherwise, let Oddmuse decide
		return 0 unless AuthenticateUser($user, $pwd);
	}
	return OldUserCanEdit($id, $editing);
}

sub AuthenticateUser {
	my ($username, $password) = @_;
	
	if (open(PASSWD, $PasswordFile)) {
		while (<PASSWD>) {
			if ($_ =~ /^$username:(.*):(.*)/) {
				if (crypt($password,$1) eq $1) {
					return 1;
				}
			}
		}
	}
	return 0;
}