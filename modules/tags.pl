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

$ModulesDescription .= '<p>$Id: tags.pl,v 1.21 2011/10/23 18:53:40 as Exp $</p>';

=head1 CONFIGURATION

=head2 $TagUrl and $TagFeed

These variable will be used to link the tags. By default, they will
point at the wiki itself, using C<$ScriptName>. They use C<%s> as a
placeholder for the URL encoded tag.

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

=cut

use vars qw($TagUrl $TagFeed $TagFeedIcon $TagFile);

push(@MyInitVariables, \&TagsInit);

sub TagsInit {
  $TagUrl = ScriptUrl('action=rc;rcfilteronly=tag:%s') unless $TagUrl;
  $TagFeed = ScriptUrl('action=rss;rcfilteronly=tag:%s') unless $TagFeed;
  $TagFile = "$DataDir/tag.db";
}

sub TagsGetLink {
  my ($url, $id) = @_;
  $id = UrlEncode($id);
  $url =~ s/\%s/$id/g or $url .= $id;
  return $url;
}

push(@MyRules, \&TagsRule);

sub TagsRule {
  if (m/\G(\[\[tag:$FreeLinkPattern\]\])/cog
      or m/\G(\[\[tag:$FreeLinkPattern\|([^]|]+)\]\])/cog) {
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
				       -alt=>T('RSS')}));
    }
    return $html;
  }
  return undef;
}

=pod

When saving, a tags db is written to disk. If it doesn't exist, it
will be regenerated.

=cut

*OldTagSave = *Save;
*Save = *NewTagSave;

sub NewTagSave { # called within a lock!
  OldTagSave(@_);
  my $id = shift;
  # Within a tag, space is replaced by _ as in foo_bar.
  my %tag = map { lc(FreeToNormal($_)) => 1 }
    ($Page{text} =~ m/\[\[tag:$FreeLinkPattern\]\]/g,
     $Page{text} =~ m/\[\[tag:$FreeLinkPattern\|([^]|]+)\]\]/g);
  # open the DB file
  require DB_File;
  tie %h, "DB_File", $TagFile;

  # For each tag we list the files tagged. Add the current file for
  # all those tags where it is missing. Note that the values in %h is
  # an encoded string; the alternative would be to use a form of
  # freeze and thaw.
  foreach my $tag (keys %tag) {
    my %file = map {$_=>1} split(/$FS/, $h{$tag});
    if (not $file{$id}) {
      $file{$id} = 1;
      $h{$tag} = join($FS, keys %file);
    }
  }

  # For each file in our hash, we have a reverse lookup of all the
  # tags used. This allows us to delete the references that no longer
  # show up without looping through them all. The files are indexed
  # with a starting underscore because this is an illegal tag name.
  foreach my $tag (split (/$FS/, $h{"_$id"})) {
    # If the tag we're looking at is no longer listed, we have work to
    # do.
    if (!$tag{$tag}) {
      my %file = map {$_=>1} split(/$FS/, $h{$tag});
      delete $file{$id};
      if (%file) {
	$h{$tag} = join($FS, keys %file);
      } else {
	delete $h{$tag};
      }
    }
  }

  # Store the new reverse lookup of all the tags used on the current
  # page. If no more tags appear on this page, delete the entry.
  if (%tag) {
    $h{"_$id"} = join($FS, keys %tag);
  } else {
    delete $h{"_$id"};
  }

  untie %h;
}

=pod

When a page expires, the relevant pages and references have to be
removed from the tags db.

=cut

*OldTagDeletePage = *DeletePage;
*DeletePage = *NewTagDeletePage;

sub NewTagDeletePage { # called within a lock!
  my $id = shift;

  # open the DB file
  require DB_File;
  tie %h, "DB_File", $TagFile;

  # For each file in our hash, we have a reverse lookup of all the
  # tags used. This allows us to delete the references that no longer
  # show up without looping through them all.
  foreach my $tag (split (/$FS/, $h{"_$id"})) {
    my %file = map {$_=>1} split(/$FS/, $h{$tag});
    delete $file{$id};
    if (%file) {
      $h{$tag} = join($FS, keys %file);
    } else {
      delete $h{$tag};
    }
  }

  # Delete reverse lookup entry.
  delete $h{"_$id"};
  untie %h;

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
  require DB_File;
  tie %h, "DB_File", $TagFile;
  my %page;
  foreach my $tag (@tags) {
    foreach my $id (split(/$FS/, $h{lc($tag)})) {
      $page{$id} = 1;
    }
  }
  untie %h;
  return sort keys %page;
}

*OldTagGrepFiltered = *GrepFiltered;
*GrepFiltered = *NewTagGrepFiltered;

sub NewTagGrepFiltered { # called within a lock!
  my ($string, @pages) = @_;
  my %page = map { $_ => 1 } @pages;
  # this is based on the code in SearchRegexp()
  my @tagterms = map { FreeToNormal($_) } grep(/^-?tag:/, shift =~ /\"([^\"]+)\"|(\S+)/g);
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
  # filter out the tags from the search string
  $string = join(' ', grep(!/^-?tag:/, $string =~ /\"([^\"]+)\"|(\S+)/g));
  # if no query terms remain, just return the pages we found
  # return sort keys %page if $string eq '';
  # otherwise run grep
  return OldTagGrepFiltered($string, sort keys %page);
}

=pod

There remains a problem: The real search code will still be in
operation, and terms of the form -tag:foo will never match. That's why
the code that does the ordinary search has to be changed as well.
We're need to remove all tag terms (again) in order to not confuse it.

=cut

*OldTagSearchString = *SearchString;
*SearchString = *NewTagSearchString;

sub NewTagSearchString {
  # filter out the negative tags from the search string
  my $string = join(' ', map { NormalToFree($_) }
		    grep(!/^-tag:/, shift =~ /\"([^\"]+)\"|(\S+)/g));
  return 1 unless $string;
  return OldTagSearchString($string, @_);
}

=pod

We also want to provide a visual feedback of tag importance using a
"tag cloud" -- larger font size means that a tag has been used more
often.

=cut

$Action{tagcloud} = \&TagCloud;

sub TagCloud {
  print GetHeader('', T('Tag Cloud'), ''),
    $q->start_div({-class=>'content cloud'}) . '<p>';
  # open the DB file
  require DB_File;
  tie %h, "DB_File", $TagFile;
  my $max = 0;
  my $min = 0;
  my %count = ();
  foreach my $tag (grep !/^_/, keys %h) {
    $count{$tag} = split(/$FS/, $h{$tag});
    $max = $count{$tag} if $count{$tag} > $max;
    $min = $count{$tag} if not $min or $count{$tag} < $min;
  }
  untie %h;
  foreach my $tag (sort keys %count) {
    my $n = $count{$tag};
    print $q->a({-href  => "$ScriptName?search=tag:" . UrlEncode($tag),
		 -title => $n,
		 -style => 'font-size: '
		 . int(80+120*($max == $min ? 1 : ($n-$min)/($max-$min)))
		 . '%;',
		}, NormalToFree($tag)), T(' ... ');
  }
  print '</p></div>';
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
  if (!UserIsAdmin() && (-f $TagFile) && ((-M $TagFile) < 0.5)) {
    ReportError(T('Rebuilding index not done.'), '403 FORBIDDEN',
		0, T('(Rebuilding the index can only be done once every 12 hours.)'));
  }

  # Request the main lock, because we want to prevent anybody from
  # saving while we are reindexing.
  RequestLockOrError();

  print GetHttpHeader('text/plain');

  # open the DB file
  require DB_File;
  tie %h, "DB_File", $TagFile;
  %h = ();

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
      $h{$tag} = $h{$tag} ? $h{$tag} . $FS . $id : $id;
    }

    # Store the reverse lookup of all the tags used on the current
    # page.
    $h{"_$id"} = join($FS, keys %tag);
  }

  untie %h;
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
  require DB_File;
  tie %h, "DB_File", $TagFile;
  foreach my $id (sort keys %h) {
    print "$id: " . join(', ', split(/$FS/, $h{$id})) . "\n";
  }
  untie %h;
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
       . ', ' . ScriptLink('action=taglist', T('list tags'), 'taglist')
       . ', ' . ScriptLink('action=tagcloud', T('tag cloud'), 'tagcloud'));
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005, 2009  Alex Schroeder <alex@gnu.org>

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
