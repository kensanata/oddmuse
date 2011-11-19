# Copyright (C) 2004, 2005, 2006  Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2006  Ingo Belka
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

$ModulesDescription .= '<p>$Id: calendar.pl,v 1.58 2011/11/19 15:26:55 as Exp $</p>';

use vars qw($CalendarOnEveryPage $CalAsTable $CalStartMonday);

$CalendarOnEveryPage = 0;   # 1=on every page is a month-div situated in the header, use css to control
$CalAsTable = 0;            # 0=every month-div is "free", 1=every month-div is caught in a table, use css to control
$CalStartMonday = 0;        # 0=week starts with Su, 1=week starts with Mo

*OldCalendarGetHeader = *GetHeader;
*GetHeader = *NewCalendarGetHeader;

sub NewCalendarGetHeader {
  my $header = OldCalendarGetHeader(@_);
  return $header unless $CalendarOnEveryPage;
  my $action = GetParam('action', 'browse');
  return $header if grep(/^$action$/, ('calendar', 'edit'));
  my $cal = Cal();
  $header =~ s/<div class="header">/$cal<div class="header">/;
  return $header;
}

sub Cal {
  my ($year, $mon, $unlink_year, $id) = @_; # example: 2004, 12
  $id = FreeToNormal($id);
  my ($sec_now, $min_now, $hour_now, $mday_now, $mon_now, $year_now) = localtime($Now);
  $mon_now += 1;
  $mon = $mon_now unless $mon;
  $year_now += 1900;
  $year = $year_now unless $year;
  if ($year < 1) {
    return $q->p(T('Illegal year value: Use 0001-9999'));
  }
  my @pages = AllPagesList();
  my $cal = draw_month($mon, $year);
  $cal =~ s{( {1,2}\d{1,2})\b}{{
    my $day = $1;
    my $date = sprintf("%d-%02d-%02d", $year, $mon, $day);
    my $re = "^$date";
    $re .= ".*$id" if $id;
    my $page = $date;
    $page .= "_$id" if $id;
    my $class = '';
    $class .= ' today' if $day == $mday_now and $mon == $mon_now and $year == $year_now;
    my @matches = grep(/$re/, @pages);
    my $link;
    if (@matches == 0) { # not using GetEditLink because of $class
      $link = ScriptLink('action=edit;id=' . UrlEncode($page), $day, 'edit' . $class);
    } elsif (@matches == 1) { # not using GetPageLink because of $class
      $link = ScriptLink($matches[0], $day, 'local exact' . $class);
    } else {
      $link = ScriptLink('action=collect;match=' . UrlEncode($re), $day,  'local collection' . $class);
    }
    $link;
  }}ge;
  $cal =~ s{(\S+) (\d\d\d\d)}{{
    my ($month_text, $year_text) = ($1, $2);
    my $date = sprintf("%d-%02d", $year, $mon);
    if ($unlink_year) {
      $q->span({-class=>'title'}, ScriptLink('action=collect;match=%5e' . $date,
					     "$month_text $year_text",  'local collection month'));
    } else {
      $q->span({-class=>'title'}, ScriptLink('action=collect;match=%5e' . $date,
					     $month_text,  'local collection month') . ' '
	       . ScriptLink('action=calendar;year=' . $year,
			    $year_text,  'local collection year'));
    }
  }}e;
  return "<div class=\"cal month\"><pre>$cal</pre></div>";
}

$Action{collect} = \&DoCollect;

# inspired by journal
sub DoCollect {
  my $id = shift;
  my $match = GetParam('match', '');
  my $search = GetParam('search', '');
  ReportError(T('The match parameter is missing.')) unless $match or $search;
  print GetHeader('', Ts('Page Collection for %s', $match||$search), '');
  my @pages = (grep(/$match/, $search
		    ? SearchTitleAndBody($search)
		    : AllPagesList()));
  if (!$CollectingJournal) {
    $CollectingJournal = 1;
    # Now save information required for saving the cache of the current page.
    local (%Page, $OpenPageName);
    print $q->start_div({-class=>'content journal collection'});
    PrintAllPages(1, 1, undef, @pages);
    print $q->end_div();
  }
  $CollectingJournal = 0;
  PrintFooter();
}

push(@MyRules, \&CalendarRule);

sub CalendarRule {
  if (/\G(calendar:(\d\d\d\d))/gc) {
    my $oldpos = pos;
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    PrintYearCalendar($2);
    pos = $oldpos;
    return AddHtmlEnvironment('p');
  } elsif (/\G(month:(\d\d\d\d)-(\d\d))/gc) {
    my $oldpos = pos;
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    print Cal($2, $3);
    pos = $oldpos;
    return AddHtmlEnvironment('p');
  } elsif (/\G(month:([+-]\d\d?))/gc
	  or /\G(\[\[month:([+-]\d\d?) $FreeLinkPattern\]\])/gc) {
    my $oldpos = pos;
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my $delta = $2;
    my $id = $3;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($Now);
    $year += 1900;
    $mon += 1 + $delta;
    while ($mon < 1) { $year -= 1; $mon += 12; };
    while ($mon > 12) { $year += 1; $mon -= 12; };
    print Cal($year, $mon, undef, $id);
    pos = $oldpos;
    return AddHtmlEnvironment('p');
  }
  return undef;
}

sub PrintYearCalendar {
  my $year = shift;
  print $q->p({-class=>nav},
	      ScriptLink('action=calendar;year=' . ($year-1), T('Previous')),
	      '|',
	      ScriptLink('action=calendar;year=' . ($year+1), T('Next')));
  if ($CalAsTable) {
      print '<table><tr>';
      for $mon ((1..12)) {
        print '<td>'.Cal($year, $mon, 1).'</td>';
        if (($mon==3) or ($mon==6) or ($mon==9)) {
            print '</tr><tr>';
        }
      }
      print '</tr></table>';
  } else {
      for $mon ((1..12)) {
        print Cal($year, $mon, 1);
      }
  }
}

$Action{calendar} = \&DoYearCalendar;

sub DoYearCalendar {
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime($Now);
  $year += 1900;
  $year = GetParam('year', $year);

  print GetHeader('', Ts('Calendar %s', $year), '');
  print $q->start_div({-class=>'content cal year'});
  PrintYearCalendar($year);
  print $q->end_div();
  PrintFooter();
}

sub draw_month {
    my $month = shift;
    my $year = shift;
    my @weekday = (T('Su'), T('Mo'), T('Tu'), T('We'),
		     T('Th'), T('Fr'), T('Sa'));
    my ($day, $col, $monthdays, $monthplus, $mod);
    my $weekday = zeller(1,$month,$year);
    # select the starting day for the week
    if ($CalStartMonday){
        push @weekday, shift @weekday;
        if ($weekday) {
            $weekday = $weekday -1;
        } else {
            $weekday = 6;
        }
    }
    my $start = 1 - $weekday;
    my $space_count = int((21 - length(month_name($month).' '.sprintf("%04u",$year)))/2 + 0.5);
    # the Cal()-sub needs a 4 digit year working right
    my $output = (' ' x $space_count).month_name($month).' '.sprintf("%04u",$year)."\n";
    $col = 0;
    $monthdays = &month_days($month,&leap_year($year));
    if ((($monthdays-$start) < 42) and (($monthdays-$start) > 35)) {
        $monthplus=41 - ($monthdays-$start);
    } elsif ((($monthdays-$start)<35) and (($monthdays-$start)>28)) {
        $monthplus=34 - ($monthdays-$start);
    } else {
        $monthplus=0;
    }
    $output .= join('', map {" ".$_} @weekday);
    $output .= "\n";
    for ($day=$start;$day<=$monthdays+$monthplus;$day++) {
        $col++;
        if (($day < 1) or ($day>$monthdays)) {
            $output .= '   ';
        } else {
            $output .= sprintf("%3d", $day);
        }
        $mod=($col/7)-int($col/7);
        if ($mod == 0) {
            $output .= "\n";
        }
        if ($year==1582 and $month==10 and $day==4) {
            $day=14;
        }
    }
    $output .= "\n" x (8 - ($output =~ tr/\n//)); # every month has to have 8 lines as output
    return $output;
}

# formula of Zeller (Julius Christian Johannes Zeller * 1822, + 1899) for countig the day of week
# only works for all years greater then 0 and can handle 1582 the year Pope Gregor has changed the 
# calculation of times from the Julian calendar to the Gregorian calendar
sub zeller {
    my $t = shift;
    my $m = shift;
    my $year = shift;
    my ($h,$j,$w);
    $h=int($year/100);
    $j=$year%100;
    if ($m<3) {
        $m = $m+10;
        if ($j==0) {
            $j=99;
            $h=$h-1;
        } else {
            $j=$j-1;
        }
    } else {
        $m=$m-2;
    }
    if (($year > 0) and ($year < 1582)) {
        $w = $t + int((2.61 * $m) - 0.2) + $j + int($j/4) + 5 - $h;
    } elsif ($year==1582) {
        if ($m > 10) {
            $w = $t + int((2.61 * $m) - 0.2) + $j + int($j/4) + 5 - $h;
        } elsif ($m==8) {
            if ($t>=1 and $t<=4) {
                $w = $t + int((2.61 * $m) - 0.2) + $j + int($j/4) + 5 - $h;
            } elsif ($t>=15) {
                $w = $t + int((2.61 * $m) - 0.2) + $j + int($j/4) + int($h/4) - (2*$h);
            }
        } elsif ($m <= 10) {
            $w = $t + int((2.61 * $m) - 0.2) + $j + int($j/4) + int($h/4) - (2*$h);
        }
    } elsif ($year > 1582) {
        $w = $t + int((2.61 * $m) - 0.2) + $j + int($j/4) + int($h/4) - (2*$h);
    }
    if (($w % 7) >= 0) {
        $w = $w % 7;
    } else {
        $w = 7 - (-1 * ($w % 7));
    }
    return $w;
}

sub leap_year {
    my $year = shift;

    if ((($year % 4)==0) and !((($year % 100)==0) and (($year % 400) != 0))) {
        return 1;
    } else {
        return 0;
    }
}

sub month_days {
    my $month = shift;
    my $leap_year = shift;
    my @month_days = (31,28,31,30,31,30,31,31,30,31,30,31);
    if (($month == 2) and $leap_year) {
        return $month_days[$month - 1] + 1;
    } else {
        return $month_days[$month - 1];
    }
}

sub month_name {
    my $month = shift;
    my @month_name = (T('January'), T('February'), T('March'), T('April'),
		      T('May'), T('June'), T('July'), T('August'),
		      T('September'), T('October'), T('November'),
		      T('December'));
    return $month_name[$month-1];
}
