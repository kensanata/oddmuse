# Copyright (C) 2004, 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

=head1 Indexed Search using Search::FreeText

This package allows Oddmuse to use an index for its searches. This is
much faster than opening every page file and searching it
individually. The drawback is that the indexes require reindexing.

This module uses four index files in the data directory: word.db,
tags.db, word-update.db, and tags-update.db. Reindexing the site will
index all pages and use word.db for all words, and tags.db for tags
only. Whenever a page is saved, Oddmuse will reindex all pages newer
than the last modified date of word.db and create word-update.db and
tags-update.db. Whenever the entire site is reindexed, word-update.db
and tags-update.db will be cleared again.

=cut

package OddMuse::Tokenize;

sub new {
    my ($classname, @args) = @_;
    my $class = ref($classname) || $classname;
    my $self = { @args };
    $self = bless $self, $class;
    $self->initialize();
    return $self;
};

sub initialize {
  my ($self) = @_;
};

sub process {
  my ($self, $oldwords) = @_;
  my $string = join("\n", @$oldwords);
  my @words = map { lc } ($string =~ /[A-Za-z0-9\x80-\xff]+/g);
  return \@words;
};

package OddMuse;

$ModulesDescription .= '<p>$Id: search-freetext.pl,v 1.59 2007/10/11 10:51:54 as Exp $</p>';

=head2 User Interface

The rule to use is C<[[tag:some tag]]> and C<[[tag:some tag|some
descriptive text]]>.

Both the action allowing you to rebuild the index as well as the
action showing you the tag cloud are available from the Adminstration
menu.

=cut

push(@MyRules, \&SearchFreeTextTagsRule);

use vars qw($SearchFreeTextTagUrl);

$SearchFreeTextTagUrl = 'http://technorati.com/tag/';

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
  push(@$menuref,
       ScriptLink('action=buildindex', T('Rebuild index for searching'), 'buildindex'),
       ScriptLink('action=cloud', T('Tag Cloud'), 'cloud'));
}

=head2 Indexing

You reindex the pages by calling the buildindex action every now and
then. Usually you'd call it at least once every 24h. Here's an example
for a script you might call from your cron job:

    #!/bin/sh
    PW=`sed -n 's/\$AdminPass="\(.*\)";/\1/p' < config`
    perl ../cgi-bin/wiki action=buildindex pwd=$PW > reindex.log
    chmod o+rw *.db
    chmod o+r reindex.log

DoSearchFreeTextIndex is used as a wrapper around SearchFreeTextIndex
that prints progress as a plain text web page. The two data files and
a subroutine to print the pagename as well as the list of all pages
are passed on to SearchFreeTextIndex.

=cut

$Action{buildindex} = \&DoSearchFreeTextIndex;

sub DoSearchFreeTextIndex {
  if (not eval { require Search::FreeText;  }) {
    ReportError(T('Search::FreeText is not available on this system.'),
		'500 INTERNAL SERVER ERROR');
  }
  my $wordfile = $DataDir . '/word.db';
  my $tagfile = $DataDir . '/tags.db';
  if (!UserIsAdmin() && (-f $wordfile) && ((-M $wordfile) < 0.5)) {
    ReportError(T('Rebuilding index not done.'), '403 FORBIDDEN',
		0, T('(Rebuilding the index can only be done once every 12 hours.)'));
  }
  print GetHttpHeader('text/plain');
  SearchFreeTextIndex($wordfile, $tagfile, sub { print shift, "\n"; },
		      AllPagesList());
  # make sure the delta indexes are empty
  $wordfile = "$DataDir/word-update.db";
  $tagfile = "$DataDir/tags-update.db";
  SearchFreeTextIndex($wordfile, $tagfile);
  print T('Done.'), "\n";
}

sub SearchFreeTextIndex {
  my ($wordfile, $tagfile, $print, @pages) = @_;
  my $words = SearchFreeTextDB($wordfile . ".new");
  $words->open_index();
  $words->clear_index();
  my $tags = SearchFreeTextDB($tagfile . ".new");
  $tags->open_index();
  $tags->clear_index();
  foreach my $name (@pages) {
    OpenPage($name);
    &$print($name) if $print;
    # don't forget to add the pagename to the page text, without
    # underscores
    my $page = $OpenPageName;
    $page =~ s/_/ /g;
    # UrlEncode key because the internal datastructure uses commas, for example.
    my @tags = ($Page{text} =~ m/\[\[tag:$FreeLinkPattern\]\]/g,
		$Page{text} =~ m/\[\[tag:$FreeLinkPattern\|([^]|]+)\]\]/g);
    # add tags, even for files
    $tags->index_document(UrlEncode($name), join(' ', @tags)) if @tags;
    # no word index for files
    my $text = $page . ' ';
    my ($type) = TextIsFile($Page{text});
    $text .= $type ? $type : $Page{text};
    $words->index_document(UrlEncode($name), $text);
  }
  $words->close_index();
  $tags->close_index();
  rename($wordfile . ".new", $wordfile);
  rename($tagfile . ".new", $tagfile);
}

=head2 Updates

Whenever a page is saved, we want to update the index. Instead of
updating the datafiles, however, we just read the rc.log file and
produce a list of changed pages since the last update of the word.db
file. These pages are reindexed.

UpdateSearchFreeTextIndex is also a wrapper around SearchFreeTextIndex
that prints no progress. The two data files, an empty subroutine as
well as the list of changed pages are passed on to
SearchFreeTextIndex.

=cut

sub SearchFreeNewPages {
  my $ts = 0;
  $ts = (stat("$DataDir/word.db"))[9] if -f "$DataDir/word.db";
  my %index = ();
  foreach my $line (GetRcLines($ts)) {
    my ($ts, $id) = split(/$FS/o, $line);
    $index{$id} = 1;
  }
  return keys %index;
}

sub UpdateSearchFreeTextIndex {
  if (eval { require Search::FreeText;  }) {
    my $wordfile = "$DataDir/word-update.db";
    my $tagfile = "$DataDir/tags-update.db";
    SearchFreeTextIndex($wordfile, $tagfile, sub {}, SearchFreeNewPages());
  }
}

*OldSearchFreeTextSave = *Save;
*Save = *NewSearchFreeTextSave;

sub NewSearchFreeTextSave { # called within a lock!
  OldSearchFreeTextSave(@_);
  UpdateSearchFreeTextIndex();
}

=head2 Debugging Initialization

You can use the Debug Action to list the pages considered to be new:

 http://localhost/cgi-bin/wiki?action=debug

=cut

push(@Debugging, \&DoSearchFreeTextNewPages);

sub DoSearchFreeTextNewPages {
  print $q->h2(T('New Pages for Indexed Search:')),
    $q->p(join(', ', map { GetPageLink($_) } SearchFreeNewPages()));
}

=head2 Tag Cloud

This action delves into the internals of the data file (hack alert!)
used by the Search::FreeText module and extracts the number of
documents tagged per tag.

=cut

$Action{cloud} = \&SearchFreeTextCloud;

sub SearchFreeTextCloud {
  print GetHeader('', T('Tag Cloud'), ''),
    $q->start_div({-class=>'content cloud'}) . '<p>';
  if (not eval { require Search::FreeText;  }) {
    my $err = $@;
    ReportError(T('Search::FreeText is not available on this system.'), '500 INTERNAL SERVER ERROR');
  }
  my $tagfile = $DataDir . '/tags.db';
  my $tags = SearchFreeTextDB($tagfile);
  $tags->open_index();
  my $db = $tags->{_Database};
  my $max = 0;
  my $min = 0;
  my %count = ();
  # use Data::Dumper;
  # print Dumper($db), '<br />';
  foreach (keys %$db) {
    # next if /^[\t ]|[0-9:]/;
    next if /^[\t ]/;
    $count{$_} = split(/;/, $$db{$_});
    $max = $count{$_} if $count{$_} > $max;
    $min = $count{$_} if not $min or $count{$_} < $min;
    # print "$_: $$db{$_}<br />";
  }
  foreach (sort keys %count) {
    my $n = $count{$_};
    print $q->a({-href  => "$ScriptName?search=tag:" . UrlEncode($_),
		 -title => $n,
		 -style => 'font-size: '
		 . int(80+120*($max == $min ? 1 : ($n-$min)/($max-$min))) . '%;',
		}, $_), T(' ... ');
  }
  $tags->close_index();
  print '</p></div>';
  PrintFooter();
}

=head2 Search Results

The old C<SearchTitleAndBody> is replaced by a new subroutine that
searches the various data files.

=cut

# override the standard printing of results
*SearchResultCount = *SearchFreeTextNop;

sub SearchFreeTextNop { '' };

# new search

my $SearchFreeTextNum = 10;  # results per page
my $SearchFreeTextMax = 10;  # max. number of pages

*OldSearchFreeTextTitleAndBody = *SearchTitleAndBody;
*SearchTitleAndBody = *NewSearchFreeTextTitleAndBody;

sub NewSearchFreeTextTitleAndBody {
  return OldSearchFreeTextTitleAndBody(@_) if GetParam('old', 0);
  my ($term, $func, @args) = @_;
  ReportError(T('Search term missing.'), '400 BAD REQUEST') unless $term;
  require Search::FreeText;
  my $page = GetParam('page', 1);
  my $context = GetParam('context', 1);
  my $limit = GetParam('limit', $SearchFreeTextNum);
  my $max = $page * $limit - 1;
  my @wanted = $term  =~ m/(".*?"|tag:".*?"|\S+)/g;
  my @wanted_words = grep(!/^-?tag:/, @wanted);
  my @wanted_tags = map { substr($_, 4) } grep(/^tag:/, @wanted);
  my @unwanted_tags = map { substr($_, 5) } grep(/^-tag:/, @wanted);
  my @words = map {
    SearchFreeTextGet(SearchFreeTextDB($_), 0, @wanted_words);
  } ("$DataDir/word-update.db", "$DataDir/word.db");
  my @tags = map {
    SearchFreeTextGet(SearchFreeTextDB($_), 1, @wanted_tags);
  } ("$DataDir/tags-update.db", "$DataDir/tags.db");
  my @excluded_tags = map {
    SearchFreeTextGet(SearchFreeTextDB($_), 1, @unwanted_tags);
  } ("$DataDir/tags-update.db", "$DataDir/tags.db");
  my @result = ();
  if (not @wanted_words and not @wanted_tags and not @excluded_tags) {
    # do nothing
  } elsif (not @wanted_words and not @wanted_tags and @excluded_tags) {
    # exclude comes later
    @result = AllPagesList();
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
  if (@excluded_tags) {
    # remove matching pages without disturbing the order of @result!
    my %hash = map { $_ => 1 } @excluded_tags;
    my @copy = ();
    foreach my $id (@result) {
      unshift(@copy,$id) unless $hash{$id};
    }
    @result = @copy;
  }
  my $raw = GetParam('raw','');
  # limit to the result page requested
  $max = @result - 1 if @result -1 < $max;
  my $count = ($page - 1) * $limit;
  my @items = @result;
  @items = @items[($page - 1) * $limit  .. $max]
    unless $CollectingJournal or $raw              # no limit when building a journal,
      or GetParam('action', 'browse') eq 'rc'      # filtering recent changes or the
      or GetParam('action', 'browse') eq 'rss';    # rss feed.
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
    print $q->p({-class=>'top pages'}, T('Result pages: '), @links,
		Ts("(%s results)", $#result + 1)) if $func and not $raw;
  }
  # print result
  foreach my $id (@items) {
    &$func($id, @args) if $func;
  }
  # repeat result pages at the bottom
  if (GetParam('search', '') and @items) {
    print $q->p({-class=>'bottom pages'}, T('Result pages: '), @links,
		Ts("(%s results)", $#result + 1)) if $func and not $raw;
  }
  return @items;
}

sub SearchFreeTextGet {
  my ($db, $tags, @wanted) = @_;
  # Shortcut if there are no search terms.
  return unless @wanted;
  my @result = ();
  # open file and get sorted list of arrays with page id and rank.
  $db->open_index();
  # Hack alert: If the index is empty, Search::FreeText 0.5 dies with
  # an "Empty index" error. In order to avoid this, we make the same
  # test here and return.
  return unless $db->{_Database}->{" "};
  my @found = $db->search(join(" ", @wanted));
  $db->close_index();
  # Make sure that all double quoted phrases do in fact all appear. To
  # do this, we copy page ids from @found. Quote potential regular
  # expressions in search strings. Backlink searches are already
  # quoted, however -- thus only do it if no backslash is found.
  my @phrases = map {
    $_ = substr($_,1,-1);
    $_ = QuoteRegexp($_) unless index('\\', $_);
    $_;
  } grep(/^"/, @wanted);
  @phrases = map { "\\[\\[tag:$_\\]\\]" } @phrases if $tags;
 PAGE: foreach (@found) {
    my ($id, $score) = (UrlDecode($_->[0]), $_->[1]);
    if (@phrases) {
      OpenPage($id);
      my $text = $OpenPageName;
      $text =~ s/_/ /g;
      $text .= "\n" . $Page{text};
      foreach my $phrase (@phrases) {
	# don't add it to @found by skipping to the next page
	next PAGE unless $text =~ m/$phrase/;
      }
    }
    push(@result, $id); # order is important, so no hashes
  }
  return @result;
}

sub SearchFreeTextDB {
  my $file = shift;
  my $db = new Search::FreeText(-db => ['DB_File', $file]);
  # The following is terrible hacking because we cannot pass an
  # internal filter along to the constructor. If you look at
  # LexicalAnalyser's initialize method, you'll see that it will
  # require the appropriate file (which we don't have). So we hook
  # into the internals, here. Terrible. This hack tested on
  # Search::FreeText 0.05.
  my $search = $db->{LexicalAnalyser}->{-search};
  my $tokenizer = new OddMuse::Tokenize(-search => $search);
  my @filters = ($tokenizer);
  $db->{LexicalAnalyser}->{-filters} = [ qw(OddMuse::Tokenize)];
  $db->{LexicalAnalyser}->{_Filters} = \@filters;
  return $db;
}

# highlighting changes if new search is used

*OldSearchFreeTextNewHighlightRegex = *HighlightRegex;
*HighlightRegex = *NewSearchFreeTextNewHighlightRegex;

sub NewSearchFreeTextNewHighlightRegex {
  return OldSearchFreeTextNewHighlightRegex(@_) if GetParam('old', 0);
  $_ = shift;
  s/\"//g;
  return join('|', split);
}

# tagging of uploaded files

*OldSearchFreePrintFooter = *PrintFooter;
*PrintFooter = *NewSearchFreePrintFooter;

sub NewSearchFreePrintFooter {
  my ($id, $rev, $comment) = @_;
  if (defined &SearchFreeTextTagsRule and TextIsFile($Page{text})) {
    my @tags = $Page{text} =~ /\[\[tag:$FreeLinkPattern\]\]/g;
    if ($rev eq 'edit') {
      print $q->div({-class=>'edit tags'}, GetFormStart(),
		    $q->p(GetHiddenValue('id', $id), GetHiddenValue('action', 'retag'),
			  T('Tags:'), $q->br(), GetTextArea('tags', join(' ', @tags), 2),
			  $q->br(), $q->submit(-name=>'Save', -value=>T('Save'))),
		    $q->endform());
    } elsif ($id and @tags) {
      print $q->div({-class=>'tags'},
		    $q->p(T('Tags:'), map { $_ = "\[\[tag:$_\]\]";
					    SearchFreeTextTagsRule(); } @tags));
    }
  }
  OldSearchFreePrintFooter(@_);
}

=head2 Retagging

It is possible to retag pages. Since ordinary pages can be retagged by
just editing the page, the retagging action is only really useful to
tag uploaded files. This will append the tag line after the end of the
MIME encoded block where they are invisible. Use the browse action
with raw=1 to display the MIME encoded block followed by the tags.

Example output:

    #FILE image/png
    iVBORw0KGgoAAAA

    Tags: [[tag:drink]] [[tag:food]]

=cut

$Action{retag} = \&SearchFreeDoTag;

sub SearchFreeDoTag {
  my $id = shift;
  my $name = $id;
  $name =~ s/_/ /g;
  my $tags = GetParam('tags', '');
  my $summary = Ts('Tags: %s.', $tags) || T('No tags');
  $tags = join(' ', map { "\[\[tag:$_\]\]" } split(' ', $tags));
  OpenPage($id);
  my $text = $Page{text};
  $text =~ s/\[\[tag:$FreeLinkPattern\]\]\s*//g; # remove all existing tags
  $text =~ s/\n\nTags: /\n\nTags: $tags/ or $text .= "\n\nTags: $tags" if $tags;
  RequestLockOrError(); # fatal
  Save($id, $text, $summary, 1, 1); # treat as upload: no diffs and no language
  ReleaseLock();
  ReBrowsePage($id);
}
