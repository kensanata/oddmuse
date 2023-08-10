# Copyright (C) 2006–2023  Alex Schroeder <alex@gnu.org>
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

use strict;
use v5.10;

AddModuleDescription('search-list.pl', 'Search List Extension');

our ($q, $bol, %Action, %Page, $OpenPageName, @MyRules);

push(@MyRules, \&SearchListRule);

sub SearchListRule {
  if ($bol && /\G(&lt;(list|titlelist) (.*?)&gt;)/cgis) {
    # <list regexp> (search page titles and page bodies)
    # <titlelist regexp> (search page titles only)
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my ($oldpos, $old_) = (pos, $_);
    my $original = $OpenPageName;
    my $variation = $2;
    my $term = $3;
    if ($term eq "") {
      $term = GetId();
    }
    local ($OpenPageName, %Page);
    my @found;
    if ($variation eq 'list') {
      @found = grep { $_ ne $original } SearchTitleAndBody($term);
    } elsif ($variation eq 'titlelist') {
      @found = grep { $_ ne $original } Matched($term, AllPagesList());
    }
    if (defined &PageSort) {
      @found = sort PageSort @found;
    } else {
      @found = sort(@found);
    }
    @found = map { $q->li(GetPageLink($_)) } @found;
    print $q->start_div({-class=>"search $variation"}),
      $q->ul(@found), $q->end_div;
    Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
    ($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
    return '';
  }
  return;
}

# Add a new action list

$Action{list} = \&DoList;

sub DoList {
  my $id = shift;
  my $match = GetParam('match', '');
  my $search = GetParam('search', '');
  ReportError(T('The search parameter is missing.')) unless $match or $search;
  print GetHeader('', Ts('Page list for %s', $match||$search), '');
  local (%Page, $OpenPageName);
  my @found = Matched($match, $search ? SearchTitleAndBody($search) : AllPagesList());
  if (defined &PageSort) {
    @found = sort PageSort @found;
  } else {
    @found = sort(@found);
  }
  @found = map { $q->li(GetPageLink($_)) } @found;
  print $q->start_div({-class=>'search list'}), $q->ul(@found), $q->end_div;
  PrintFooter();
}
