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

$ModulesDescription .= '<p>$Id: aggregate.pl,v 1.3 2005/12/16 12:53:48 as Exp $</p>';

push(@MyRules, \&AggregateRule);

sub AggregateRule {
  if ($bol && m/\G(&lt;aggregate\s+((("[^\"&]+"),?\s*)+)&gt;)/gc) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my ($oldpos, $old_, $str) = ((pos), $_, $2);
    print $q->start_div({class=>"aggregate journal"});
    while ($str =~ m/"([^\"&]+)"/g) {
      my $title = $1;
      local $OpenPageName = FreeToNormal($1);
      my $page = GetPageContent($OpenPageName);
      my $size = length($page);
      my $i = index($page, "\n=");
      my $j = index($page, "\n----");
      $page = substr($page, 0, $i) if $i >= 0;
      $page = substr($page, 0, $j) if $j >= 0;
      $page =~ s/^=.*\n//; # if it starts with a header
      print $q->start_div({class=>"page"}),
	$q->h2(GetPageLink($OpenPageName, $title));
      ApplyRules(QuoteHtml($page), 1, 0, undef, 'p');
      print $q->p(GetPageLink($OpenPageName, T('Learn more...')))
	if length($page) < $size;
      print $q->end_div();
    }
    print $q->end_div();
    Clean(AddHtmlEnvironment('p'));
    pos = $oldpos;
    return '';
  }
  return undef;
}
