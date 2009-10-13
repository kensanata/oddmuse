# Copyright (C) 2004, 2009  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2004  Zuytdorp Survivor
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: timezone.pl,v 1.2 2009/10/13 22:27:54 as Exp $</p>';

use DateTime;
use DateTime::TimeZone;

use vars qw($defaultTZ);

$defaultTZ = 'UTC';

$CookieParameters{time} = '';

sub TZget {
  my $dt = DateTime->from_epoch(epoch=>shift);
  my $tz = GetParam('time', '');
  # setting time= will use the (defined) empty string, so avoid that
  $tz = $defaultTZ unless $tz;
  # converting floating point hours used by a previous version of the
  # code
  $tz = sprintf("%d:%02d", int($tz), int(60*($tz-int($tz))))
    if $tz =~ /^[+-]?\d+\.?\d*$/;
  $dt->set_time_zone($tz);
  return $dt;
}

*OldTZCalcDay = *CalcDay;
*CalcDay = *NewTZCalcDay;

sub NewTZCalcDay {
  return TZget(shift)->ymd;
}

*OldTZCalcTime = *CalcTime;
*CalcTime = *NewTZCalcTime;

sub NewTZCalcTime {
  return substr(TZget(shift)->hms, 0, 5) # strip seconds
    . (GetParam('time', '') ? '' : ' UTC');
}

*OldTZGetFooterTimestamp = *GetFooterTimestamp;
*GetFooterTimestamp = *NewTZGetFooterTimestamp;

sub NewTZGetFooterTimestamp {
  my $html = OldTZGetFooterTimestamp(@_);
  $html =~ s/(\d\d:\d\d( UTC)?)/ScriptLink('action=tz', $1, 'tz')/e;
  return $html;
}

$Action{tz} = \&DoTZ;

sub DoTZ {
  print GetHeader(undef, T('Timezone'));
  print $q->start_div({-class=>'tz content'});
  print GetFormStart();
  my @names = DateTime::TimeZone->all_names;
  print $q->p(T('Pick your timezone:'),
	      $q->popup_menu(-name=>'time',
			     -values=>\@names,
			     -default=>GetParam('time', $defaultTZ)),
	      $q->submit('dotz', T('Set')));
  print $q->endform . $q->end_div();
  PrintFooter();
}
