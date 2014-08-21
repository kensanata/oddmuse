# form_timeout.pl - a form timeout based anti-spam module for Oddmuse
#
# Copyright (C) 2014 Aki Goto <tyatsumi@gmail.com>
#
# Original code is in PHP from http://textcaptcha.com/really
# by Rob Tuley <hello@rob.cx>. Used with permission.
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

AddModuleDescripton('form_timeout.pl');

=head1 DESCRIPTION

This is an anti-spam module for Oddmuse using form timeout method.
Edit permission is timed out in specified duration (default is 30 minutes)
after viewing the edit form. When edit content is posted directly by a spam bot
without viewing the edit form, edit will be denied.

=head1 CONFIGURATION

$FormTimeoutSalt
Mandatory. Token hash salt. Specify arbitrary string.
Default = undef.

$FormTimeoutTimeout
The form timeout in seconds.
Default = 60 * 30 (30 minutes).

=cut

use vars qw($FormTimeoutSalt $FormTimeoutTimeout);
use Digest::MD5 qw(md5_hex);

$FormTimeoutSalt = undef;
$FormTimeoutTimeout = 60 * 30; # 30 minutes

push(@MyInitVariables, \&FormTimeoutInitVariables);

sub FormTimeoutInitVariables {
  if (!defined($FormTimeoutSalt)) {
    ReportError(T('Set $FormTimeoutSalt.'), '500 INTERNAL SERVER ERROR');
  }
}

sub FormTimeoutGetHash {
  my ($when) = @_;
  return md5_hex($FormTimeoutSalt . $when);
}

sub FormTimeoutGetToken {
  return $Now . '#' . FormTimeoutGetHash($Now);
}

sub FormTimeoutGetTime {
  my ($token) = @_;
  my ($when, $hash) = split /#/, $token;
  my $valid_hash = FormTimeoutGetHash($when);
  if ($hash ne $valid_hash) {
    return '';
  }
  return $when;
}

sub FormTimeoutCheck {
  my $token = GetParam('form_timeout_token', '');
  my $when = FormTimeoutGetTime($token);
  if ($when eq '' || $when < $Now - $FormTimeoutTimeout) {
    return 0;
  }
  return 1;
}

*OldFormTimeoutGetFormStart = *GetFormStart;
*GetFormStart = *NewFormTimeoutGetFormStart;

sub NewFormTimeoutGetFormStart {
  my ($ignore, $method, $class) = @_;
  my $form = OldFormTimeoutGetFormStart($ignore, $method, $class);
  my $token = FormTimeoutGetToken();
  $form .= $q->input({-type=>'hidden', -name=>'form_timeout_token',
                      -value=>$token});
  return $form;
}

*OldFormTimeoutDoEdit = *DoEdit;
*DoEdit = *NewFormTimeoutDoEdit;

sub NewFormTimeoutDoEdit {
  my ($id, $newText, $preview) = @_;
  if (!FormTimeoutCheck()) {
    ReportError(T('Form Timeout'), '403 FORBIDDEN', undef,
    $q->p(Ts('Editing not allowed: %s is read-only.', NormalToFree($id))));
  }
  OldFormTimeoutDoEdit($id, $newText, $preview);
}
