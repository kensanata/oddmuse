#! /usr/bin/perl
# Copyright (C) 2014–2022  Alex Schroeder <alex@gnu.org>

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

use strict;
use v5.10;

AddModuleDescription('post-instead-of-get.pl', 'POST instead of GET extension');

our ($q, $LastUpdate, @RcDays, $RcDefault, $ShowRollbacks, $ShowAll, $ShowEdits, %Languages);

# You should install nosearch.pl, too.

# Change the search from GET to POST
*PostOldGetSearchForm=*GetSearchForm;
*GetSearchForm=*PostNewGetSearchForm;

sub PostNewGetSearchForm {
  my $html = PostOldGetSearchForm(@_);
  $html =~ s/method="get"/method="post"/;
  return $html;
}

# Disable Recent Changes menu
sub RcHeader {}

# Change Recent Changes filter form to represent all options.
*PostOldGetFilterForm=*GetFilterForm;
*GetFilterForm=*PostNewGetFilterForm;

sub PostNewGetFilterForm {
  my $all = GetParam('all', $ShowAll);
  my $showedit = GetParam('showedit', $ShowEdits);
  my $rollback = GetParam('rollback', $ShowRollbacks);
  my $lang = GetParam('lang', '');
  my $form = GetFormStart(undef, 'post', 'filter') . $q->h2(T('Filters'));
  $form .= $q->input({-type=>'hidden', -name=>'action', -value=>'rc'});
  $form .= $q->radio_group(-name=>'days', -values=>\@RcDays, -default=> $RcDefault) . ' ' . T('days') . $q->br();
  $form .= $q->input({-type=>'checkbox', -id=>'all', -name=>'all', -value=>1, $all && '-checked'});
  $form .= $q->label({-for=>'all'}, ' ' . T('List all changes')) . $q->br();
  $form .= $q->input({-type=>'checkbox', -id=>'showedit', -name=>'showedit', -value=>1, $showedit && '-checked'});
  $form .= $q->label({-for=>'showedit'}, ' ' . T('Include minor changes')) . $q->br();
  $form .= $q->input({-type=>'checkbox', -id=>'rollback', -name=>'rollback', -value=>1, $rollback && '-checked'});
  $form .= $q->label({-for=>'rollback'}, ' ' . T('Include rollbacks')) . $q->br();
  foreach my $h (['match' => T('Title:')], ['rcfilteronly' => T('Title and Body:')],
     ['rcuseronly' => T('Username:')], ['rchostonly' => T('Host:')], ['followup' => T('Follow up to:')]) {
    $form .= $q->label({-for=>$h->[0], -style=>'width:20ch; display:inline-block'}, $h->[1]);
    $form .= $q->textfield(-name=>$h->[0], -id=>$h->[0], -size=>20);
    $form .= $q->br();
  }
  if (%Languages) {
    $form .= $q->label({-for=>'rclang', -style=>'width:20ch; display:inline-block'}, T('Language:'));
    $form .= $q->textfield(-name=>'lang', -id=>'rclang', -size=>20, -default=>$lang);
  }
  $form .= $q->br() . $q->submit('dofilter', T('Go!')) . $q->end_form;
  $form .= GetFormStart(undef, 'post', 'later');
  $form .= $q->input({-type=>'hidden', -name=>'all', -value=>1, $all && '-checked'});
  $form .= $q->input({-type=>'hidden', -name=>'showedit', -value=>1, $showedit && '-checked'});
  $form .= $q->p(T('List later changes') . ' ' . $q->submit('dofilter', T('Go!')));
  $form .= $q->end_form;
  $form .= $q->p({-class => 'documentation'}, T('Using the ｢rollback｣ button on this page will reset the wiki to that particular point in time, undoing any later changes to all of the pages.')) if UserIsAdmin() and $all;
  return $form;
}

1;
