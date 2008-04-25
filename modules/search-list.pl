# Copyright (C) 2006, 2007, 2008  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: search-list.pl,v 1.16 2008/04/25 12:55:50 weakish Exp $</p>';

push(@MyRules, \&SearchListRule);

sub SearchListRule {
  if ($bol && /\G(&lt;list (.*?)&gt;)/cgis) {
    # <list regexp>
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my ($oldpos, $old_) = (pos, $_);
    my $original = $OpenPageName;
    my $term = $2;
    if ($term eq "") {
        $term = GetId();
    }
    local ($OpenPageName, %Page);
    my %hash = ();
    foreach my $id (SearchTitleAndBody($term)) {
      $hash{$id} = 1 unless $id eq $original; # skip the page with the query
    }
    my @found = keys %hash;
    if (defined &PageSort) {
      @found = sort PageSort @found;
    } else {
      @found = sort(@found);
    }
    @found = map { $q->li(GetPageLink($_)) } @found;
    print $q->start_div({-class=>'search list'}),
      $q->ul(@found), $q->end_div;
    Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
    ($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
    return '';
  }
  return undef;
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
    my %hash = ();
    foreach my $id (grep(/$match/, $search
                    ? SearchTitleAndBody($search)
                    : AllPagesList()))  {
      $hash{$id} = 1;
    }
    my @found = keys %hash;
    if (defined &PageSort) {
      @found = sort PageSort @found;
    } else {
      @found = sort(@found);
    }
    @found = map { $q->li(GetPageLink($_)) } @found;
    print $q->start_div({-class=>'search list'}),
      $q->ul(@found), $q->end_div;  
  PrintFooter();
}

