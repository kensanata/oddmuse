# Copyright (C) 2005  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2005  Tilmann Holst
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/localtime.pl">localtime.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Localtime_Extension">Localtime Extension</a></p>';

*CalcDay     = *NewCalcDay;
*CalcTime    = *NewCalcTime;

sub NewCalcDay {
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime(shift);
    return sprintf('%4d-%02d-%02d', $year + 1900, $mon + 1, $mday);
}

sub NewCalcTime {
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime(shift);
    return sprintf('%02d:%02d', $hour, $min);
}
