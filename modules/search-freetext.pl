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

$ModulesDescription .= '<p>$Id: search-freetext.pl,v 1.2 2004/12/10 16:58:30 as Exp $</p>';

$Action{buildindex} = \&SearchFreeTextIndex;

$Action{search} = \&SearchFreeText;

sub SearchFreeTextIndex {
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
    $db->index_document($name, $Page{text});
  }
  $db->close_index();
  print T('Done.</p>');
  PrintFooter();
}

sub SearchFreeText {
  my $term = GetParam('term', '');
  ReportError(T('Search term missing.'), '400 BAD REQUEST') unless $term;
  require Search::FreeText;
  my $file = $DataDir . '/word.db';
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  $db->open_index();
  print GetHeader('', QuoteHtml(Ts('Searching for %s', $term)), ''),
    $q->start_div({-class=>'content search'});
  foreach ($db->search($term, 10)) {
    my ($id, $score) = ($_->[0], $_->[1]);
    my $title = $id;
    $title =~ s/_/ /g;
    PrintSearchResult($id, $term);
  };
  $db->close_index();
  print T('Done.</p>');
  PrintFooter();
}

*SearchFreeTextOldForm = *GetSearchForm;
*GetSearchForm = *SearchFreeTextNewForm;


sub SearchFreeTextNewForm {
  my $form = T('Search:') . ' '
    . GetHiddenValue('action', 'search')
    . $q->textfield(-name=>'term', -size=>20, -accesskey=>T('f')) . ' ';
  return GetFormStart(0, 1, 'search') . $q->p($form . $q->submit('dosearch', T('Go!'))) . $q->endform;
}
