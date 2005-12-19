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

$ModulesDescription .= '<p>$Id: tags.pl,v 1.3 2005/12/19 00:21:28 as Exp $</p>';

push(@MyRules, \&TagsRule);

use vars qw($TagUrl $TagSearch);

$TagUrl = 'http://technorati.com/tag/';
$TagSearch = 1;

sub TagsRule {
  if (m/\G(\[\[tag:$FreeLinkPattern\]\])/cog
      or m/\G(\[\[tag:$FreeLinkPattern\|([^]|]+)\]\])/cog) {
    # [[tag:Free Link]], [[tag:Free Link|alt text]]
    my ($tag, $text) = ($2, $3);
    return $q->a({-href=>$TagUrl . UrlEncode($tag),
		  -class=>'outside tag',
		  -title=>T('Tag'),
		  -rel=>'tag'
		 }, $text || $tag);
  }
  return undef;
}

push(@MyAdminCode, \&TagsSearchMenu);

sub TagsSearchMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=tagindex', T('Rebuild index for tags')));
}

$Action{tagindex} = \&TagsSearchIndex;

sub TagsSearchIndex {
  print GetHeader('', T('Rebuilding Index'), ''),
    $q->start_div({-class=>'content buildindex'} . '<p>');
  my $fname = "$DataDir/maintain";
  if (not eval { require Search::FreeText;  }) {
    my $err = $@;
    ReportError(T('Search::FreeText is not available on this system.'), '500 INTERNAL SERVER ERROR');
  }
  my $file = $DataDir . '/tags.db';
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
    my @tags = ($Page{text} =~ m/\[\[tag:$FreeLinkPattern\]\]/g,
		$Page{text} =~ m/\[\[tag:$FreeLinkPattern\|([^]|]+)\]\]/g);
    next unless @tags;
    print $name, ': ', join(', ', @tags), $q->br();
    $db->index_document($name, join(' ', @tags));
  }
  $db->close_index();
  ReleaseLock();
  print T('Done.') . '</p></div>';
  PrintFooter();
}

*TagsOldGetSearchForm = *GetSearchForm;
*GetSearchForm = *TagsNewGetSearchForm;

sub TagsNewGetSearchForm {
  my $form = TagsOldGetSearchForm(@_);
  $form .= GetFormStart(undef, 'get', 'tags')
    . $q->p($q->label({-for=>'tags'}, T('Tags:')) . ' '
	    . $q->input({-type=>'hidden', -name=>'action', -value=>'tags'})
	    . $q->textfield(-id=>'tags', -name=>'search', -size=>20, -accesskey=>T('t')) . ' '
	    . $q->submit('dotags', T('Go!'))) . $q->endform if $TagSearch;
  return $form;
}

$Action{'tags'} = \&TagsSearch;

sub TagsSearch {
  local *SearchTitleAndBody = *TagsSearchTitleAndBody;
  local *HighlightRegex = *TagsSearchNewHighlightRegex;
  warn "tag search";
  DoSearch(GetParam('search'));
}

# new search

my $TagsSearchNum = 10;  # results per page
my $TagsSearchMax = 10;  # max. number of pages

sub TagsSearchTitleAndBody {
  my ($term, $func, @args) = @_;
  ReportError(T('Search term missing.'), '400 BAD REQUEST') unless $term;
  require Search::FreeText;
  my $file = $DataDir . '/tags.db';
  my $page = GetParam('page', 1);
  my $context = GetParam('context', 1);
  my $limit = GetParam('limit', $TagsSearchNum);
  my $max = $page * $limit - 1;
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  # get results
  $db->open_index();
  my @found = $db->search($term);
  $db->close_index();
  # make sure phrases do in fact appear (phrases are multi-word search
  # terms in "double quotes")
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
	$action .= ';limit=' . $limit if $limit != $TagsSearchNum;
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

sub TagsSearchNewHighlightRegex {
  $_ = shift;
  s/\"//g;
  return join('|', split);
}
