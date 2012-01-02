=head1 NAME

honeypot - an Oddmuse module that reduces wiki spam

=head1 SYNOPSIS

This module adds parameters to the page edit form. These parameters are special
because they are invisible to humans (using style information). If a spam bot
sets these parameters to anything, the edit will be rejected. Another hidden
parameter contains a timestamp. If a spam bot plays back recorded actions and
provides the timestamp of the recording, the edit will be rejected because it is
too old.

More information:
L<http://nedbatchelder.com/text/stopbots.html>

=head1 INSTALLATION

Installing a module is easy: Create a modules subdirectory in your
data directory, and put the Perl file in there. It will be loaded
automatically.

=cut

$ModulesDescription .= '<p>$Id: honeypot.pl,v 1.6 2012/01/02 22:47:01 as Exp $</p>';

=head1 CONFIGURATION

=head2 $HoneyPotOk and $HoneyPotTimestamp

C<$HoneyPotOkThis> is used to hold the timestamp. If a form is posted with a
timestamp older than C<$HoneyPotTimestamp> seconds, it will be rejected.

Example:

    $HoneyPotOkThis = 'friend';
    $HoneyPotTimestamp = 6 * 60 * 60; # six hours

By default, the parameter is called "ok" and the timestamp may not be older than
one hour (3600 seconds).

=head2 $HoneyPotIdiot1 and $HoneyPotIdiot2

These two variables should not be posted or they should be empty. Providing any
values will result in the form being rejected.

Example:

    $HoneyPotIdiot1 = 'spam';
    $HoneyPotIdiot2 = 'scum';

By default, these have the values of "idiot" and "looser", for obvious reasons.

=cut

package OddMuse;

use vars qw($HoneyPotOk $HoneyPotIdiot $HoneyPotTimestamp);

$HoneyPotOk = 'ok';
$HoneyPotIdiot1 = 'idiot';
$HoneyPotIdiot2 = 'looser';
$HoneyPotTimestamp = 3600;

*HoneyPotOldGetFormStart = *GetFormStart;
*GetFormStart = *HoneyPotNewGetFormStart;

my $HoneyPotWasHere = 0;

sub HoneyPotNewGetFormStart {
  my $html = HoneyPotOldGetFormStart(@_);
  my ($ignore, $method) = @_;
  return $html unless not $method or lc($method) eq 'post';
  if (not $HoneyPotWasHere) {
    $HoneyPotWasHere = 1;
    $html .= '<div style="display: none">';
    $html .= $q->textfield({-name=>$HoneyPotOk, -id=>$HoneyPotOk,
			    -default=>time,
			    -size=>40, -maxlength=>250}) if $HoneyPotOk;
    $html .= $q->label({-for=>$HoneyPotIdiot1}, 'Leave empty:'), ' ',
      $q->textfield({-name=>$HoneyPotIdiot1, -id=>$HoneyPotIdiot1,
		     -size=>40, -maxlength=>250}) if $HoneyPotIdiot1;
    $html .= $q->textarea(-name=>$HoneyPotIdiot2, -id=>$HoneyPotIdiot2,
			  -rows=>5, -columns=>78) if $HoneyPotIdiot2;
    $html .= '</div>';
  }
  return $html;
}

# kill requests that contain the idiot or looser parameters
# and requests that have a timestamp that is too old

push(@MyInitVariables, \&HoneyPotInspection);

sub HoneyPotInspection {
  if (not UserIsEditor()
      # we're making an edit
      and GetParam('title', '')
      # override from questionasker.pl
      and not ($QuestionaskerRememberAnswer and GetParam($QuestionaskerSecretKey, 0))
      # the parameters we use in our form
      and (GetParam($HoneyPotIdiot1) or GetParam($HoneyPotIdiot2)
	   or ($HoneyPotOk
	       and $Now - GetParam($HoneyPotOk) > $HoneyPotTimestamp))) {
    ReportError(T('Edit Denied'), '403 FORBIDDEN');
  }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011  Alex Schroeder <alex@gnu.org>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.

=cut
