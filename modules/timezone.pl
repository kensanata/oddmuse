# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2004  Zuytdorp Survivor
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

$ModulesDescription .= '<p>$Id: timezone.pl,v 1.1 2004/07/07 11:52:52 as Exp $</p>';

use vars qw($defaultTZ);

$defaultTZ = 0;

*OldCalcDay = *CalcDay;
*CalcDay = *NewCalcDay;
*OldCalcTime = *CalcTime;
*CalcTime = *NewCalcTime;

sub NewCalcDay {
  my ($sec, $min, $hour, $mday, $mon, $year) =
    gmtime((shift) + GetParam('time', $defaultTZ) * 3600);
  return sprintf('%4d-%02d-%02d', $year+1900, $mon+1, $mday);
}

sub NewCalcTime {
  my ($sec, $min, $hour, $mday, $mon, $year) =
    gmtime((shift) + GetParam('time', $defaultTZ) * 3600);
  return sprintf('%02d:%02d%s', $hour, $min, GetParam('time', $defaultTZ) ? '' : ' UTC');
}

$CookieParameters{time} = '';
