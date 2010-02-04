# Copyright (C) 2010  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: dates.pl,v 1.2 2010/02/04 16:45:34 as Exp $</p>';

push(@MyAdminCode, \&DatesMenu);

sub DatesMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=dates',
		  T('Extract all dates from the database'),
		  'dates'));
}

$Action{dates} = \&DoDates;

my $regex = '([0-9][0-9][0-9][0-9]-([0-9][0-9])-([0-9][0-9]))';

sub DoDates {
  print GetHeader('', T('Dates')), $q->start_div({-class=>'content dates'});
  print $q->p(T("No dates found.")) unless $q->p(SearchTitleAndBody($regex, \&DateCollector));
  DatesPrint();
  PrintFooter();
}

my %date_collection;
my $date_page;

*OldDatesSearchString = *SearchString;
*SearchString = *NewDatesSearchString;

sub NewDatesSearchString {
  $date_page = $_[1]; # save the page text!
  return OldDatesSearchString(@_);
}

sub DateCollector {
  my $id = shift;
  my $text = $date_page; # use the page text saved above!
  my ($ignore, $qtext) = split(/\n/, $text, 2);
  $qtext = QuoteHtml($qtext);
  while ($text =~ m/$regex/g) {
    my $date = $1;
    my $key = "$2-$3";
    my $context = SearchHighlight(SearchExtract($qtext, $date), $date);
    push(@{$date_collection{$key}}, [$id, $context]);
  }
}

sub DatesPrint {
  for my $key (sort keys %date_collection) {
    print $q->h2($key);
    print '<ul>';
    for my $item (@{$date_collection{$key}}) {
      my @item = @{$item};
      my $id = $item[0];
      my $context = $item[1];
      print $q->li(GetPageLink($id) . ': ' . $context);
    }
    print '</ul>';
  }
}
