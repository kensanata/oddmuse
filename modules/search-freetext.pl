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

$ModulesDescription .= '<p>$Id: search-freetext.pl,v 1.6 2004/12/21 22:24:34 as Exp $</p>';

use vars qw($SearchFreeTextNewForm);

$SearchFreeTextNewForm = 1;

$Action{buildindex} = \&SearchFreeTextIndex;

$Action{search} = \&SearchFreeText;

sub SearchFreeTextIndex {
  RequestLockOrError(); # fatal
  require Search::FreeText;
  my $file = $DataDir . '/word.db';
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  print GetHeader('', QuoteHtml(Ts('Updating %s', $file)), ''),
    $q->start_div({-class=>'content buildindex'} . '<p>');
  $db->open_index();
  $db->clear_index();
  foreach my $name (AllPagesList()) {
    OpenPage($name);
    next if ($Page{text} =~ /^#FILE / and $string !~ /^\^#FILE/); # skip files unless requested
    print $name, $q->br();
    $db->index_document($name, $OpenPageName . ' ' . $Page{text}); # don't forget to add the pagename!
  }
  $db->close_index();
  ReleaseLock();
  print T('Done.</p></div>');
  PrintFooter();
}

my $SearchFreeTextNum = 10; # results per page
my $SearchFreeTextMax = 10; # max. number of pages

sub SearchFreeText {
  my $term = GetParam('term', '');
  ReportError(T('Search term missing.'), '400 BAD REQUEST') unless $term;
  require Search::FreeText;
  my $file = $DataDir . '/word.db';
  my $page = GetParam('page', 1);
  my $limit = GetParam('limit', $SearchFreeTextNum);
  my $context = GetParam('context', 1);
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  $db->open_index();
  print GetHeader('', QuoteHtml(Ts('Searching for %s', $term)), ''),
    $q->start_div({-class=>'content search'});
  my @result = $db->search($term, $limit * $SearchFreeTextMax);
  if (@result) {
    print '<p>' unless $context;
    my $max = $page * $limit - 1;
    $max = @result - 1 if @result -1 < $max;
    my $count = ($page - 1) * $limit;
    foreach (@result[($page - 1) * $limit  .. $max]) {
      my ($id, $score) = ($_->[0], $_->[1]);
      my $title = $id;
      $title =~ s/_/ /g;
      if ($context) {
	PrintSearchResult($id, join('|', split(' ', $term)));
      } else {
	PrintPage($id);
      }
    }
    print '</p>' unless $context;
    my @links = ();
    my $i = 0;
    my $prev = '';
    my $next = '';
    while($i++ * $limit < @result) {
      if ($i == $page) {
	push(@links, $i);
      } else {
	my $action = 'action=search;term=' . UrlEncode($term);
	$action .= ';page=' . $i if $i != 1;
	$action .= ';context=0' unless $context;
	$action .= ';limit=' . $limit if $limit != $SearchFreeTextNum;
	push(@links, ScriptLink($action, $i));
	$prev = $action if ($i == $page - 1);
	$next = $action if ($i == $page + 1);
      }
    }
    unshift(@links, ScriptLink($prev, T('Previous'))) if $prev;
    push(@links, ScriptLink($next, T('Next'))) if $next;
    print $q->p(T('Result pages: '), @links);
  } else {
    print $q->p(T('No results found.'));
  }
  print $q->end_div();
  PrintFooter();
  $db->close_index();
}

*SearchFreeTextOldForm = *GetSearchForm;
*GetSearchForm = *SearchFreeTextNewForm;

sub SearchFreeTextNewForm {
  return SearchFreeTextOldForm() unless $SearchFreeTextNewForm;
  my $form = T('Search:') . ' '
    . GetHiddenValue('action', 'search')
    . $q->textfield(-name=>'term', -size=>20, -accesskey=>T('f')) . ' ';
  return GetFormStart(0, 1, 'search') . $q->p($form . $q->submit('dosearch', T('Go!'))) . $q->endform;
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
