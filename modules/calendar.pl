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

$ModulesDescription .= '<p>$Id: calendar.pl,v 1.10 2004/04/02 01:15:28 as Exp $</p>';

use vars qw($CalendarOnEveryPage);

$CalendarOnEveryPage = 1;

*OldCalendarGetHeader = *GetHeader;
*GetHeader = *NewCalendarGetHeader;

sub NewCalendarGetHeader {
  my $header = OldCalendarGetHeader(@_);
  return $header unless $CalendarOnEveryPage;
  my $cal = Cal();
  $header =~ s/<div class="header">/$cal<div class="header">/;
  return $header;
}

sub Cal {
  my $cal = `cal`;
  return unless $cal;
  my @pages = AllPagesList();
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime($Now);
  $cal =~ s|\b( ?\d?\d)\b|{
    my $day = $1;
    my $date = sprintf("%d-%02d-%02d", $year+1900, $mon+1, $day);
    my $class;
    $class = ' today' if $day == $mday;
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
    print '<div class="journal collection">';
    PrintAllPages(1, 1, @matches);
    print '</div>';
  }
  $CollectingJournal = 0;
  PrintFooter();
}

push(@MyRules, \&CalendarRule);

sub CalendarRule {
  if (/\Gcalendar:([0-9][0-9][0-9][0-9])/gc) {
    PrintYearCalendar($1);
  }
  return '';
}

sub PrintYearCalendar {
  my $year = shift;
  my @pages = AllPagesList();
  for $mon ((1..12)) {
    my $cal = `cal $mon $year`;
    $cal =~ s|\b( ?\d?\d)\b|
      {
       my $day = $1;
       my $date = sprintf("%d-%02d-%02d", $year, $mon, $day);
       my @matches = grep(/^$date/, @pages);
       my $link;
       if (@matches == 0) {
         $link = $day;
       } elsif (@matches == 1) {
         $link = GetPageLink($matches[0], $day);
       } else {
         $link = ScriptLink('action=collect;match=' . $date, $day);
       }
       $link;
      }|ge;
    print "<pre class=\"cal year\">$cal</pre>";
  }
}

