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

$ModulesDescription .= '<p>$Id: search-freetext.pl,v 1.8 2004/12/25 16:23:16 as Exp $</p>';

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
    next if ($Page{text} =~ /^#FILE /); # skip files
    print $name, $q->br();
    $db->index_document($name, $OpenPageName . ' ' . $Page{text}); # don't forget to add the pagename!
  }
  $db->close_index();
  ReleaseLock();
  print T('Done.</p></div>');
  PrintFooter();
}

sub SearchFreeText {
  local *SearchTitleAndBody = *SearchFreeTextTitleAndBody;
  return DoSearch(GetParam('term', ''));
}

sub SearchFreeTextTitleAndBody {
  my ($term, $func, @args) = @_;
  ReportError(T('Search term missing.'), '400 BAD REQUEST') unless $term;
  require Search::FreeText;
  my $file = $DataDir . '/word.db';
  my $page = GetParam('page', 1);
  my $context = GetParam('context', 1);
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  $db->open_index();
  my @found = $db->search($term);
  foreach (@found) {
    my ($id, $score) = ($_->[0], $_->[1]);
    &$func($id, @args) if $func;
  }
  $db->close_index();
  return @found;
}

*SearchFreeTextOldHighlightRegex = *HighlightRegex;
*HighlightRegex = *SearchFreeTextNewHighlightRegex;

sub SearchFreeTextNewHighlightRegex {
  return join('|', split(/ /, shift));
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

*SearchFreeTextOldGetSearchLink = *GetSearchLink;
*GetSearchLink = *SearchFreeTextNewGetSearchLink;

sub SearchFreeTextNewGetSearchLink {
  my ($text, $class, $name, $title) = @_;
  my $id = UrlEncode($text);
  $name = UrlEncode($name);
  $text =~ s/_/ /g;
  return ScriptLink('action=search;term=' . $id, $text, $class, $name, $title);
}
