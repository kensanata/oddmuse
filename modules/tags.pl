use strict;
use v5.10;

=encoding utf8

=head1 NAME

tags - an Oddmuse module that implements tagging of pages and
       searching for tagged pages

=head1 SYNOPSIS

This module recognises the pattern C<[[tag:foo]]> on a page and will
render this as a link to all pages tagged foo, as well as a link to
the RSS feed for all pages tagged foo.

Alternatively, the pattern C<[[tag:foo|bar]]> is also recognized. The
only difference is that this will look like a link to bar instead of
foo.

When searching for a term of the form C<tag:foo> the term "foo" be
searched in a separate tag index, making it much faster.

You can also negate this particular form by using C<-tag:foo>.

These searches will also work for Journal Pages, Recent Changes, and
RSS feed.

=head1 INSTALLATION

Installing a module is easy: Create a modules subdirectory in your
data directory, and put the Perl file in there. It will be loaded
automatically.

=cut

AddModuleDescription('tags.pl', 'Tagging Extension');

=head1 CONFIGURATION

=head2 $TagUrl and $TagFeed

These variable will be used to link the tags. By default, they will
point at the wiki itself, using C<$ScriptName>. They use C<%s> as a
placeholder for the tag.

Example:

    $TagUrl = 'http://technorati.com/tag/%s';
    $TagFeed = 'http://feeds.technorati.com/tag/%s';

By default, these two will point to the list of recent changes,
filtered by the appropriate tag, formatted as HTML or RSS
respectively.

=head2 $TagFeedIcon

This variable should point to an RSS icon. You can get one from
L<http://www.feedicons.com/>, for example.

Example:

    $TagFeedIcon = 'http://www.example.org/pics/rss.png';

=head2 $TagCloudSize

The number of most used tags when looking at the tag cloud. The
default is 50.

Example:

    $TagCloudSize = 20;

=cut

our ($q, $Now, %Action, %Page, $FreeLinkPattern, @MyInitVariables, @MyRules, @MyAdminCode, $DataDir, $ScriptName);
our ($TagUrl, $TagFeed, $TagFeedIcon, $TagFile, $TagCloudSize);

push(@MyInitVariables, \&TagsInit);

sub TagsInit {
  $TagUrl = ScriptUrl('action=rc;rcfilteronly=tag:%s') unless $TagUrl;
  $TagFeed = ScriptUrl('action=rss;rcfilteronly=tag:%s') unless $TagFeed;
  $TagCloudSize = 50 unless $TagCloudSize;
  $TagFile = "$DataDir/tag.db";
}

sub TagsGetLink {
  my ($url, $id) = @_;
  $id = UrlEncode($id);
  $url =~ s/\%s/$id/g or $url .= $id;
  return $url;
}

sub TagReadHash {
  require Storable;
  return %{ Storable::retrieve(encode_utf8($TagFile)) } if IsFile($TagFile);
}


# returns undef if encountering an error
sub TagWriteHash {
  my $h = shift;
  require Storable;
  return Storable::store($h, encode_utf8($TagFile));
}

push(@MyRules, \&TagsRule);

sub TagsRule {
  if (m/\G(\[\[tag:$FreeLinkPattern\]\])/cg
      or m/\G(\[\[tag:$FreeLinkPattern\|([^]|]+)\]\])/cg) {
    # [[tag:Free Link]], [[tag:Free Link|alt text]]
    my ($tag, $text) = ($2, $3);
    my $html = $q->a({-href=>TagsGetLink($TagUrl, $tag),
		      -class=>'outside tag',
		      -title=>T('Tag'),
		      -rel=>'tag'
		     }, $text || $tag);
    if ($TagFeedIcon) {
      $html .= ' ' . $q->a({-href=>TagsGetLink($TagFeed, $tag),
			    -class=>'feed tag',
			    -title=>T('Feed for this tag'),
			    -rel=>'feed'
			   }, $q->img({-src=>$TagFeedIcon,
				       -alt=>T('RSS'),
				       -loading=>'lazy'}));
    }
    return $html;
  }
  return;
}

=pod

When saving, a tags db is written to disk. If it doesn't exist, it
will be regenerated.

=cut

*OldTagSave = \&Save;
*Save = \&NewTagSave;

sub NewTagSave { # called within a lock!
  OldTagSave(@_);
  my $id = shift;
  # Within a tag, space is replaced by _ as in foo_bar.
  my %tag = map { lc(FreeToNormal($_)) => 1 }
    ($Page{text} =~ m/\[\[tag:$FreeLinkPattern\]\]/g,
     $Page{text} =~ m/\[\[tag:$FreeLinkPattern\|([^]|]+)\]\]/g);
  # open the DB file
  my %h = TagReadHash();

  # For each tag we list the files tagged. Add the current file for
  # all those tags where it is missing.
  foreach my $tag (keys %tag) {
    my %file = map {$_=>1} @{$h{$tag}};
    if (not $file{$id}) {
      $file{$id} = 1;
      $h{$tag} = [keys %file];
    }
  }

  # For each file in our hash, we have a reverse lookup of all the
  # tags used. This allows us to delete the references that no longer
  # show up without looping through them all. The files are indexed
  # with a starting underscore because this is an illegal tag name.
  foreach my $tag (@{$h{"_$id"}}) {
    # If the tag we're looking at is no longer listed, we have work to
    # do.
    if (!$tag{$tag}) {
      my %file = map {$_=>1} @{$h{$tag}};
      delete $file{$id};
      if (%file) {
	$h{$tag} = [keys %file];
      } else {
	delete $h{$tag};
      }
    }
  }

  # Store the new reverse lookup of all the tags used on the current
  # page. If no more tags appear on this page, delete the entry.
  if (%tag) {
    $h{"_$id"} = [keys %tag];
  } else {
    delete $h{"_$id"};
  }

  TagWriteHash(\%h);
}

=pod

When a page expires, the relevant pages and references have to be
removed from the tags db.

=cut

*OldTagDeletePage = \&DeletePage;
*DeletePage = \&NewTagDeletePage;

sub NewTagDeletePage { # called within a lock!
  my $id = shift;

  # open the DB file
  my %h = TagReadHash();

  # For each file in our hash, we have a reverse lookup of all the
  # tags used. This allows us to delete the references that no longer
  # show up without looping through them all.
  foreach my $tag (@{$h{"_$id"}}) {
    my %file = map {$_=>1} @{$h{$tag}};
    delete $file{$id};
    if (%file) {
      $h{$tag} = [keys %file];
    } else {
      delete $h{$tag};
    }
  }

  # Delete reverse lookup entry.
  delete $h{"_$id"};
  TagWriteHash(\%h);

  # Return any error codes?
  return OldTagDeletePage($id, @_);
}

=pod

When searching, the tags db is read and used. This works by scanning
the search string for tag:foo and -tag:bar elements, searching for
those, and then calling the grep filter code with the new list of
pages and a new search term without the tag terms.

=cut

sub TagFind {
  my @tags = @_;
  # open the DB file
  my %h = TagReadHash();
  my %page;
  foreach my $tag (@tags) {
    foreach my $id (@{$h{lc($tag)}}) {
      $page{$id} = 1;
    }
  }
  my @result = sort keys %page;
  return @result;
}

sub TagsTerms {
  my $string = shift;
  return grep(/./, $string =~ /\"([^\"]+)\"|(\S+)/g);
}

*OldTagFiltered = \&Filtered;
*Filtered = \&NewTagFiltered;

sub NewTagFiltered { # called within a lock!
  my ($string, @pages) = @_;
  my %page = map { $_ => 1 } @pages;
  # looking at all the "tag:SOME TERMS" and and tag:TERM
  my @tagterms = map { FreeToNormal($_) } grep(/^-?tag:/, TagsTerms($string));
  my @positives = map {substr($_, 4)} grep(/^tag:/, @tagterms);
  my @negatives = map {substr($_, 5)} grep(/^-tag:/, @tagterms);
  if (@positives) {
    my %found;
    foreach my $id (TagFind(@positives)) {
      $found{$id} = 1 if $page{$id};
    }
    %page = %found;
  }
  # remove the negatives
  foreach my $id (TagFind(@negatives)) {
    delete $page{$id};
  }
  # filter out the tags from the search string, and add quotes which might have
  # been stripped
  $string = join(' ', map { qq{"$_"} } grep(!/^-?tag:/, TagsTerms($string)));
  # run the old code for any remaining search terms
  return OldTagFiltered($string, sort keys %page);
}

=pod

There remains a problem: The real search code will still be in
operation, and terms of the form -tag:foo will never match. That's why
the code that does the ordinary search has to be changed as well.
We're need to remove all tag terms (again) in order to not confuse it.

=cut

*OldTagSearchString = \&SearchString;
*SearchString = \&NewTagSearchString;

sub NewTagSearchString {
  my ($string, @rest) = @_;
  # filter out the negative tags from the search string, and add quotes which
  # might have been stripped
  $string = join(' ', map { NormalToFree($_) } map { qq{"$_"} } grep(!/^-tag:/, TagsTerms($string)));
  return 1 unless $string;
  return OldTagSearchString($string, @rest);
}

=pod

We also want to provide a visual feedback of tag importance using a
"tag cloud" -- larger font size means that a tag has been used more
often.

=cut

$Action{tagcloud} = \&TagCloud;

sub TagCloud {
  print GetHeader('', T('Tag Cloud'), ''),
    $q->start_div({-class=>'content cloud'});
  require HTML::TagCloud;
  my $cloud = HTML::TagCloud->new;
  # open the DB file
  my %h = TagReadHash();
  foreach my $tag (grep !/^_/, keys %h) {
    $cloud->add(NormalToFree($tag), "$ScriptName?search=tag:" . UrlEncode($tag), scalar @{$h{$tag}});
  }
  print $cloud->html_and_css($TagCloudSize);
  print '</div>';
  PrintFooter();
}

=pod

Finally, we need to provide the means to reindex the entire site. The
Reindex Action will do this. This should only be necessary when you
install the module, and when you suspect that the tag.db is out of
sync such as after a restoration from backup.

Example:

    http://example.org/cgi-bin/wiki?action=reindex

=cut

$Action{reindex} = \&DoTagsReindex;

sub DoTagsReindex {
  if (not UserIsAdmin()
      and IsFile($TagFile)
      and $Now - Modified($TagFile) < 0.5) {
    ReportError(T('Rebuilding index not done.'), '403 FORBIDDEN',
		0, T('(Rebuilding the index can only be done once every 12 hours.)'));
  }

  # Request the main lock, because we want to prevent anybody from
  # saving while we are reindexing.
  RequestLockOrError();

  print GetHttpHeader('text/plain');

  # open the DB file
  require Storable;
  my %h = ();

  foreach my $id (AllPagesList()) {
    print "$id\n";
    OpenPage($id);

    my %tag = map { lc(FreeToNormal($_)) => 1 }
      ($Page{text} =~ m/\[\[tag:$FreeLinkPattern\]\]/g,
       $Page{text} =~ m/\[\[tag:$FreeLinkPattern\|([^]|]+)\]\]/g);
    next unless %tag;

    # For each tag we list the files tagged. Add the current file for
    # all tags.
    foreach my $tag (keys %tag) {
      push(@{$h{$tag}}, $id);
    }

    # Store the reverse lookup of all the tags used on the current
    # page.
    $h{"_$id"} = [keys %tag];
  }
  if (TagWriteHash(\%h)) {
    print "Saved tag file.\n";
  } else {
    print "Error saving tag file.\n";
  }
  ReleaseLock();
}

=pod

If you want to debug the data structure, use the Tag List Action. All
keys starting with an underscore are pagenames, the others are tags.

Example:

    http://example.org/cgi-bin/wiki?action=taglist

=cut

$Action{taglist} = \&TagList;

sub TagList {
  print GetHttpHeader('text/plain');
  # open the DB file
  my %h = TagReadHash();
  foreach my $id (sort keys %h) {
    print "$id: " . join(', ', @{$h{$id}}) . "\n";
  }
  TagWriteHash(\%h);
}

=pod

Both these actions are of course available from the Administration
menu.

=cut

push(@MyAdminCode, \&TagsMenu);

sub TagsMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=reindex', T('Rebuild tag index'), 'reindex')
       . ', ' . ScriptLink('action=tagcloud', T('tag cloud'), 'tagcloud'));
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005–2019  Alex Schroeder <alex@gnu.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

=cut
