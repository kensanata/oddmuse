# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#               2004  Tilmann Holst <spam@tholst.de>
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

# You may need to set $calcmd below.
# Without the cal program (shipped with almost every unix) this extension
# is useless. This extension will not work under Windows/IIS unless cal
# is installed.

$ModulesDescription .= '<p>$Id: cal3.pl,v 1.1 2004/04/29 11:39:03 groogel Exp $</p>';

*OldCalendarGetHeader = *GetHeader;
*GetHeader = *NewCalendarGetHeader;

sub NewCalendarGetHeader {
  my ($csec, $cmin, $chour, $cmday, $cmon, $cyear) = gmtime();
  $cyear += 1900;
  $cmon += 1;

  my qw($cal $prevmon $prevyear $nextmon $nextyear);
  
  # check if previous month is in previous year
  if ($cmon == 1){
    $prevmon = "12";
    $prevyear = ($cyear - 1);
  } else {
    $prevmon = ($cmon - 1);
    $prevyear = $cyear;
  }
  # check if next month is in next year
  if ($cmon == "12") {
    $nextmon = "1";
    $nextyear = ($cyear + 1);
  } else {
  $nextmon = ($cmon + 1);
  $nextyear = $cyear;
  }
  my $header = OldCalendarGetHeader(@_);

  # commenting out the last line of this paragraph makes cal3 a cal2
  # extension.
  $cal = Cal($nextmon,$nextyear);
  $cal .= Cal($cmon,$cyear);
  $cal .= Cal($prevmon,$prevyear);

  $header =~ s/<div class="header">/$cal<div class="header">/;
  return $header;
}

sub Cal {
  my ($month,$year) = @_;
  # set $calcmd to an appropriate value
  my $calcmd = 'cal'; # week starts with sunday
  # my $calcmd = 'cal -m'; # week starts with monday
  # my $calcmd = 'export LC_ALL=de_DE.UTF-8;/insert/path/here/cal -m'; # example with different path to cal and different locale
  my $cal = `$calcmd $month $year`;
  return unless $cal;
  my ($sec, $min, $hour, $mday, $mon, $myyear) = gmtime($Now);
  $cal =~ s|\b( ?\d?\d)\b|{
    my $day = $1;
    my $date = sprintf("%d-%02d-%02d", $year, $month, $day);
    my $class;
    if ($month == ($mon + 1)) {
      $class = ($day == $mday) ? 'today'
             : ($IndexHash{$date} ? 'exists' : 'wanted');
    } else {
      $class = ($IndexHash{$date} ? 'exists' : 'wanted');
    }	      
    "<a class=\"$class\" href=\"$ScriptName/$date\">$day</a>";
    }|ge;
  return "<div class=\"cal\"><pre>$cal</pre></div>";
}


