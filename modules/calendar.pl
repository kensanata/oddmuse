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

$ModulesDescription .= '<p>$Id: calendar.pl,v 1.31 2004/12/20 06:11:29 as Exp $</p>';

use vars qw($CalendarOnEveryPage $CalendarUseCal);

$DefaultStyleSheet .= q{
div.month { float:right; margin:0; padding-left:1ex; padding-right:1ex; }
div.footer { clear:both; }
div.year div.month { float:left; }
div.month pre { margin:0; padding:0; background-color:#ffe; }
div.month a { text-decoration:none; color:inherit; }
div.month span.title a { background-color:inherit; }
div.month a.exact { background-color:#eef; }
div.month a.collection { background-color:#ccf; }
div.month a.today { background-color:#fcc; }
div.month a[class~="today"][class~="exact"] { background-color:#fcf; }
div.month a[class~="today"][class~="collection"] { background-color:#faf; }
@media print {
  div.month { display: none; }
  div.year div.month { display: block; }
  div.year div.month a { display: inline; }
}
} unless $DefaultStyleSheet =~ /div\.month/; # mod_perl?

$CalendarOnEveryPage = 1;
$CalendarUseCal = 1;

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
  my ($year, $mon, $unlink_year) = @_; # example: 2004, 12
  my ($sec_now, $min_now, $hour_now, $mday_now, $mon_now, $year_now) = localtime($Now);
  $mon_now += 1;
  $year_now += 1900;
  $year = $year_now unless $year;
  $mon = $mon_now unless $mon;
  my @pages = AllPagesList();
  my $cal = '';
  if ($CalendarUseCal) {
    $cal = `cal $mon $year`;
  }
  eval { require Date::Calc;
	 $cal = Date::Calc::Calendar( $year, $mon ); } unless $cal;
  eval { require Date::Pcalc;
	 $cal = Date::Pcalc::Calendar( $year, $mon ); } unless $cal;
  return T('Missing one of cal(1), Date::Calc(3), or Date::Pcalc(3) to produce the calendar.')
    unless $cal;
  $cal =~ s|\b([A-Z][a-z])\b|{ T($1); }|ge;
  $cal =~ s|\b( ?[ 0-9]?[0-9])\b|{
    my $day = $1;
    my $date = sprintf("%d-%02d-%02d", $year, $mon, $day);
    my $class = '';
    $class .= ' today' if $day == $mday_now and $mon == $mon_now and $year == $year_now;
    my @matches = grep(/^$date/, @pages);
    my $link;
    if (@matches == 0) { # not using GetEditLink because of $class
      $link = ScriptLink('action=edit;id=' . $date, $day, 'edit' . $class);
    } elsif (@matches == 1) { # not using GetPageLink because of $class
      $link = ScriptLink($matches[0], $day, 'local exact' . $class);
    } else {
      $link = ScriptLink('action=collect;match=' . $date, $day,  'local collection' . $class);
    }
    $link;
  }|ge;
  $cal =~ s|(\w+) (\d\d\d\d)|{
    my ($month_text, $year_text) = ($1, $2);
    $month_text = T($month_text);
    my $date = sprintf("%d-%02d", $year, $mon);
    if ($unlink_year) {
      $q->span({-class=>'title'}, ScriptLink('action=collect;match=' . $date,
					     "$month_text $year_text",  'local collection month'));
    } else {
      $q->span({-class=>'title'}, ScriptLink('action=collect;match=' . $date,
					     $month_text,  'local collection month') . ' '
	       . ScriptLink('action=calendar;year=' . $year,
			    $year_text,  'local collection year'));
    }
  }|e;
  return "<div class=\"cal month\"><pre>$cal</pre></div>";
}

$Action{collect} = \&DoCollect;

# inspired by journal
sub DoCollect {
  my $id = shift;
  my $match = GetParam('match', '');
  ReportError(T('The match parameter is missing.')) unless $match;
  print GetHeader('', Ts('Page Collection for %s', $match), '');
  my @pages = AllPagesList();
  my @matches = grep(/^$match/, @pages);
  if (!$CollectingJournal) {
    $CollectingJournal = 1;
    # Now save information required for saving the cache of the current page.
    local (%Page, $OpenPageName);
    print $q->start_div({-class=>'content journal collection'});
    PrintAllPages(1, 1, @matches);
    print $q->end_div();
  }
  $CollectingJournal = 0;
  PrintFooter();
}

push(@MyRules, \&CalendarRule);

sub CalendarRule {
  if (/\G(calendar:(\d\d\d\d))/gc) {
    my $oldpos = pos;
    Clean(CloseHtmlEnvironments() . $q->start_div({-class=>'cal year'}));
    Dirty($1);
    PrintYearCalendar($2);
    print $q->end_div() . AddHtmlEnvironment('p');
    pos = $oldpos;
    return '';
  } elsif (/\G(month:(\d\d\d\d)-(\d\d))/gc) {
    my $oldpos = pos;
    Dirty($1);
    print CloseHtmlEnvironments() . Cal($2, $3) . AddHtmlEnvironment('p');
    pos = $oldpos;
    return '';
  } elsif (/\G(month:([+-]\d\d?))/gc) {
    my $oldpos = pos;
    Dirty($1);
    my $delta = $2;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($Now);
    $year += 1900;
    $mon += 1 + $delta;
    while ($mon < 1) { $year -= 1; $mon += 12; };
    while ($mon > 12) { $year += 1; $mon -= 12; };
    print CloseHtmlEnvironments() . Cal($year, $mon) . AddHtmlEnvironment('p');
    pos = $oldpos;
    return '';
  }
  return undef;
}

sub PrintYearCalendar {
  my $year = shift;
  my @pages = AllPagesList();
  print $q->p({-class=>nav},
	      ScriptLink('action=calendar;year=' . ($year-1), T('Previous')),
	      '|',
	      ScriptLink('action=calendar;year=' . ($year+1), T('Next')));
  for $mon ((1..12)) {
    print Cal($year, $mon, 1);
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
