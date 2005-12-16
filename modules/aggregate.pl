# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: aggregate.pl,v 1.1 2005/12/16 12:40:28 as Exp $</p>';

push(@MyRules, \&AggregateRule);

sub AggregateRule {
  if ($bol && m/\G(&lt;aggregate\s+((("[^\"&]+"),?\s*)+)&gt;)/gc) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my ($oldpos, $old_, $str) = ((pos), $_, $2);
    while ($str =~ m/"([^\"&]+)"/g) {
      local $OpenPageName = FreeToNormal($1);
      my $page = GetPageContent($OpenPageName);
      my $i = index($page, "\n=");
      my $j = index($page, "\n----");
      $page = substr($page, 0, $i) if $i;
      $page = substr($page, 0, $j) if $j;
      print $q->start_div({class=>"include aggregate $OpenPageName"});
      ApplyRules(QuoteHtml($page), 1, 0, undef, 'p');
      print $q->end_div();
    }
    Clean(AddHtmlEnvironment('p'));
    pos = $oldpos;
    return '';
  }
  return undef;
}
