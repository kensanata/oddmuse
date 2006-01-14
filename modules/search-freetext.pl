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

$ModulesDescription .= '<p>$Id: search-freetext.pl,v 1.21 2006/01/14 17:51:56 as Exp $</p>';

push(@MyRules, \&SearchFreeTextTagsRule);

use vars qw($SearchFreeTextTagUrl $SearchFreeTextNewForm);

$SearchFreeTextTagUrl = 'http://technorati.com/tag/';
$SearchFreeTextNewForm = 1;

sub SearchFreeTextTagsRule {
  if (m/\G(\[\[tag:$FreeLinkPattern\]\])/cog
      or m/\G(\[\[tag:$FreeLinkPattern\|([^]|]+)\]\])/cog) {
    # [[tag:Free Link]], [[tag:Free Link|alt text]]
    my ($tag, $text) = ($2, $3);
    return $q->a({-href=>$SearchFreeTextTagUrl . UrlEncode($tag),
		  -class=>'outside tag',
		  -title=>T('Tag'),
		  -rel=>'tag'
		 }, $text || $tag);
  }
  return undef;
}

push(@MyAdminCode, \&SearchFreeTextMenu);

sub SearchFreeTextMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=buildindex', T('Rebuild index for searching')));
}

$Action{buildindex} = \&SearchFreeTextIndex;

sub SearchFreeTextIndex {
  print GetHeader('', T('Rebuilding Index'), ''),
    $q->start_div({-class=>'content buildindex'} . '<p>');
  if (not eval { require Search::FreeText;  }) {
    my $err = $@;
    ReportError(T('Search::FreeText is not available on this system.'), '500 INTERNAL SERVER ERROR');
  }
  my $wordfile = $DataDir . '/word.db';
  my $tagfile = $DataDir . '/tags.db';
  if (!UserIsAdmin()) {
    if ((-f $wordfile) && ((-M $wordfile) < 0.5)) {
      print $q->p(T('Rebuilding index not done.'),
		  T('(Rebuilding the index can only be done once every 12 hours.)')),
	     $q->end_div();
      PrintFooter();
      return;
    }
  }
  RequestLockOrError(); # fatal
  my $words = new Search::FreeText(-db => ['DB_File', $wordfile]);
  $words->open_index();
  $words->clear_index();
  my $tags = new Search::FreeText(-db => ['DB_File', $tagfile]);
  $tags->open_index();
  $tags->clear_index();
  foreach my $name (AllPagesList()) {
    OpenPage($name);
    next if ($Page{text} =~ /^#FILE /); # skip files
    print $name, $q->br();
    # don't forget to add the pagename to the page text, without
    # underscores
    my $page = $OpenPageName;
    $page =~ s/_/ /g;
    $words->index_document($name, $page . ' ' . $Page{text});
    my @tags = ($Page{text} =~ m/\[\[tag:$FreeLinkPattern\]\]/g,
		$Page{text} =~ m/\[\[tag:$FreeLinkPattern\|([^]|]+)\]\]/g);
    next unless @tags;
    $tags->index_document($name, join(' ', @tags)); # add tags
  }
  $words->close_index();
  $tags->close_index();
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

# override code for rcfilteronly

*SearchFreeTextOldGetRc = *GetRc;
*GetRc = *SearchFreeTextNewGetRc;

sub SearchFreeTextNewGetRc {
  if (GetParam('old', 0)) {
    SearchFreeTextOldGetRc(@_);
  } else {
    local *SearchTitleAndBody = *SearchFreeTextTitleAndBody;
    local *HighlightRegex = *SearchFreeTextNewHighlightRegex;
    SearchFreeTextOldGetRc(@_);
  }
}

# new search

my $SearchFreeTextNum = 10;  # results per page
my $SearchFreeTextMax = 10;  # max. number of pages

sub SearchFreeTextTitleAndBody {
  my ($term, $func, @args) = @_;
  ReportError(T('Search term missing.'), '400 BAD REQUEST') unless $term;
  require Search::FreeText;
  my $page = GetParam('page', 1);
  my $context = GetParam('context', 1);
  my $limit = GetParam('limit', $SearchFreeTextNum);
  my $max = $page * $limit - 1;
  my @wanted = $term  =~ m/(".*?"|tag:".*?"|\S+)/g;
  my @wanted_words = grep(!/^tag:/, @wanted);
  my @wanted_tags = map { substr($_, 4) } grep(/^tag:/, @wanted);
  my @words = SearchFreeTextGet($DataDir . '/word.db', @wanted_words);
  my @tags = SearchFreeTextGet($DataDir . '/tags.db', @wanted_tags);
  my @result = ();
  if (not @wanted_words and not @wanted_tags) {
    # do nothing
  } elsif (@wanted_words and not @wanted_tags) {
    @result = @words;
  } elsif (not @wanted_words and @wanted_tags) {
    @result = @tags;
  } else {
    # only return the pages in @tags if the page also exists in
    # @words: intersection!
    my %hash = map { $_ => 1 } @words;
    foreach my $id (@tags) {
      push @result, $id if $hash{$id};
    }
  }
  # limit to the result page requested
  $max = @result - 1 if @result -1 < $max;
  my $count = ($page - 1) * $limit;
  my @items = @result[($page - 1) * $limit  .. $max];
  # print links, if this is is really a search
  my $raw = GetParam('raw','');
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
    print $q->p({-class=>'top pages'}, T('Result pages: '), @links,
		Ts("(%s results)", $#result + 1)) unless $raw;
  }
  # print result
  foreach my $id (@items) {
    &$func($id, @args) if $func;
  }
  # repeat result pages at the bottom
  if (GetParam('search', '') and @items) {
    print $q->p({-class=>'bottom pages'}, T('Result pages: '), @links,
		Ts("(%s results)", $#result + 1)) unless $raw;
  }
  return @items;
}

sub SearchFreeTextGet {
  my $file = shift;
  my @wanted = @_;
  return unless @wanted; # shortcut
  my @result = ();
  # open file and get sorted list of arrays with page id and rank.
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  $db->open_index();
  my @found = $db->search(join(" ", @wanted));
  $db->close_index();
  # make sure that all double quoted phrases do in fact all appear.
  # to do this, we copy page ids from @found.
  my @phrases = map { quotemeta(substr($_,1,-1)) } grep(/^"/, @wanted);
 PAGE: foreach (@found) {
    my ($id, $score) = ($_->[0], $_->[1]);
    if (@phrases) {
      OpenPage($id);
      foreach my $phrase (@phrases) {
	# don't add it to @found by skipping to the next page
	next PAGE unless $Page{text} =~ m/$phrase/;
      }
    }
    push(@result, $id); # order is important, so no hashes
  }
  return @result;
}

# highlighting changes if new search is used

sub SearchFreeTextNewHighlightRegex {
  $_ = shift;
  s/\"//g;
  return join('|', split);
}
