# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: calendar.pl,v 1.2 2004/01/30 21:35:44 as Exp $</p>';

*OldCalendarGetHeader = *GetHeader;
*GetHeader = *NewCalendarGetHeader;

sub NewCalendarGetHeader {
  my $header = OldCalendarGetHeader(@_);
  my $cal = Cal();
  $header =~ s/<div class="header">/$cal<div class="header">/;
  return $header;
}

sub Cal {
  my $cal = `cal`;
  return unless $cal;
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($Now);
  $cal =~ s|\b( ?\d?\d)\b|{
    my $day = $1;
    my $date = sprintf("%d-%02d-%02d", $year+1900, $mon+1, $day);
    my $class = ($day == $mday) ? 'today'
              : ($IndexHash{$date} ? 'exists' : 'wanted');
    "<a class=\"$class\" href=\"$ScriptName/$date\">$day</a>";
    }|ge;
  return "<div class=\"cal\"><pre>$cal</pre></div>";
}
