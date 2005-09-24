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

$ModulesDescription .= '<p>$Id: search-freetext.pl,v 1.17 2005/09/24 10:13:01 as Exp $</p>';

use vars qw($SearchFreeTextNewForm);

$SearchFreeTextNewForm = 1;

push(@MyAdminCode, \&SearchFreeTextMenu);

sub SearchFreeTextMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=buildindex', T('Rebuild index for searching')));
}

$Action{buildindex} = \&SearchFreeTextIndex;

sub SearchFreeTextIndex {
  print GetHeader('', T('Rebuilding Index'), ''),
    $q->start_div({-class=>'content buildindex'} . '<p>');
  my $fname = "$DataDir/maintain";
  if (not eval { require Search::FreeText;  }) {
    my $err = $@;
    ReportError(T('Search::FreeText is not available on this system.'), '500 INTERNAL SERVER ERROR');
  }
  my $file = $DataDir . '/word.db';
  if (!UserIsAdmin()) {
    if ((-f $file) && ((-M $file) < 0.5)) {
      print $q->p(T('Rebuilding index not done.'),
		  T('(Rebuilding the index can only be done once every 12 hours.)')),
	     $q->end_div();
      PrintFooter();
      return;
    }
  }
  RequestLockOrError(); # fatal
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  $db->open_index();
  $db->clear_index();
  foreach my $name (AllPagesList()) {
    OpenPage($name);
    next if ($Page{text} =~ /^#FILE /); # skip files
    print $name, $q->br();
    $db->index_document($name, $OpenPageName . ' ' . $Page{text}); # don't forget to add the pagename!
  }
  $db->close_index();
  ReleaseLock();
  print T('Done.') . '</p></div>';
  PrintFooter();
}

# override old DoSearch

*SearchFreeTextOldDoSearch = *DoSearch;
*DoSearch = *SearchFreeTextNewDoSearch;

sub SearchFreeTextNewDoSearch {
  if (GetParam('old', 0) or (GetParam('replace', '')) or not $SearchFreeTextNewForm) {
    SearchFreeTextOldDoSearch(@_);
  } else {
    local *SearchTitleAndBody = *SearchFreeTextTitleAndBody;
    local *HighlightRegex = *SearchFreeTextNewHighlightRegex;
    SearchFreeTextOldDoSearch(@_);
  }
}

# new search

my $SearchFreeTextNum = 10;  # results per page
my $SearchFreeTextMax = 10;  # max. number of pages

sub SearchFreeTextTitleAndBody {
  my ($term, $func, @args) = @_;
  ReportError(T('Search term missing.'), '400 BAD REQUEST') unless $term;
  require Search::FreeText;
  my $file = $DataDir . '/word.db';
  my $page = GetParam('page', 1);
  my $context = GetParam('context', 1);
  my $limit = GetParam('limit', $SearchFreeTextNum);
  my $max = $page * $limit - 1;
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  # get results
  $db->open_index();
  my @found = $db->search($term);
  $db->close_index();
  # pmake sure phrases do in fact appear (phrases are multi-word
  # search terms in "double quotes")
  my @phrases = map { quotemeta } $term =~ m/"([^\"]+)"/g;
  my @result = ();
 PAGE: foreach (@found) {
    my ($id, $score) = ($_->[0], $_->[1]);
    if (@phrases) {
      OpenPage($id);
      foreach my $phrase (@phrases) {
	next PAGE unless $Page{text} =~ m/$phrase/;
      }
    }
    push(@result, $id);
  }
  # limit to the result page requested
  $max = @result - 1 if @result -1 < $max;
  my $count = ($page - 1) * $limit;
  my @items = @result[($page - 1) * $limit  .. $max];
  # print links, if this is is really a search
  my @links = ();
  if (GetParam('search', '') and @items) {
    my $pages = int($#result / $limit) + 1;
    my $prev = '';
    my $next = '';
    for my $p (1 .. $pages) {
      if ($p == $page) {
	push(@links, $p);
      } else {
	my $action = 'search=' . UrlEncode($term);
	$action .= ';page=' . $p if $p != 1;
	$action .= ';context=0' unless $context;
	$action .= ';limit=' . $limit if $limit != $SearchFreeTextNum;
	push(@links, ScriptLink($action, $p));
	$prev = $action if ($p == $page - 1);
	$next = $action if ($p == $page + 1);
      }
    }
    unshift(@links, ScriptLink($prev, T('Previous'))) if $prev;
    push(@links, ScriptLink($next, T('Next'))) if $next;
    print $q->p({-class=>'top pages'},
		T('Result pages: '), @links, Ts("(%s results)", $#result + 1));
  }
  # print result
  foreach my $id (@items) {
    &$func($id, @args) if $func;
  }
  # repeat result pages at the bottom
  if (GetParam('search', '') and @items) {
    print $q->p({-class=>'bottom pages'},
		T('Result pages: '), @links, Ts("(%s results)", $#result + 1));
  }
  return @items;
}

# highlighting changes if new search is used

sub SearchFreeTextNewHighlightRegex {
  $_ = shift;
  s/\"//g;
  return join('|', split);
}

# *SearchFreeTextOldSavePage = *SavePage;
# *SavePage = *SearchFreeTextNewSavePage;

# sub SearchFreeTextNewSavePage {
#   SearchFreeTextOldSavePage();
#   require Search::FreeText;
#   my $file = $DataDir . '/word.db';
#   my $db = new Search::FreeText(-db => ['DB_File', $file]);
#   $db->open_index();
#   $db->index_document($OpenPageName, $Page{text}) # dies with "Document already indexed"!
#   $db->close_index();
# }
