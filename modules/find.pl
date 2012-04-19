# Copyright (C) 2007, 2009  Alex Schroeder <alex@gnu.org>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/find.pl">find.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Find_Extension">Find Extension</a></p>';

$Action{find} = \&DoFind;

sub DoFind {
  my $string = GetParam('query','');
  my $raw = GetParam('raw','');
  if ($string eq '') {
    return DoIndex();
  }
  if ($raw) {
    print GetHttpHeader('text/plain'), RcTextItem('title', Ts('Search for: %s', $string)),
      RcTextItem('date', TimeToText($Now)), RcTextItem('link', $q->url(-path_info=>1, -query=>1)), "\n"
	if GetParam('context',1);
  } else {
    print GetHeader('', QuoteHtml(Ts('Search for: %s', $string))),
      $q->start_div({-class=>'content search'});
    my @elements = (ScriptLink('action=rc;rcfilteronly=' . UrlEncode($string),
			       T('View changes for these pages')));
    print $q->p({-class=>'links'}, @elements);
  }
  my $match = quotemeta($string);
  my @results = grep(/$match/i, AllPagesList());
  if (@results) {
    print $q->start_div({-class=>'title'}),
      $q->p({-class=>'intro'},
	    T('Matching page names:'));
    foreach (@results) { PrintPage($_) }
    print $q->end_div();
  }
  if (GetParam('context',1)) {
    push(@results, SearchTitleAndBody($string, \&PrintSearchResult, SearchRegexp($string)));
  } else {
    push(@results, SearchTitleAndBody($string, \&PrintPage));
  }
  print SearchResultCount($#results + 1), $q->end_div() unless $raw;
  PrintFooter() unless $raw;
}
