# Copyright (C) 2004, 2005, 2007  Alex Schroeder <alex@emacswiki.org>
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: localnames.pl,v 1.37 2011/05/11 13:48:08 as Exp $</p>';

=head1 Local Names

This module allows you to centrally define redirections. Thus you can
define that whenever somebody links to the page Foo the link will
point to http://example.com/. These redirects are defined on special
page called LocalNames. You can change the name of that page by
setting C<$LocalNamesPage>.

You can also link to external lists of such redirections, as long as
they use the namespace description format developed by Lion Kimbro.
Basically you can "import" redirections. These external lists are
cached in a directory called C<ln> inside the data directory. You can
change the directory by setting C<$LnDir>.

=cut

use vars qw($LocalNamesPage %LocalNames $LocalNamesCollect
	    $LocalNamesCollectMaxWords $LnDir $LnCacheHours
	    %WantedPages);

$LocalNamesPage = 'LocalNames';
$LocalNamesCollect = 0;
$LocalNamesCollectMaxWords = 2;
# LN caching is written very similar to the RSS file caching
$LnDir = "$DataDir/ln";
$LnCacheHours = 12;

sub GetLnFile {
  return $LnDir . '/' . UrlEncode(shift);
}

=head2 Maintenance

Whenever maintenance runs, all the cached external lists of
redirections are deleted whenever they are older than twelve hours.
You can change this expiry time by setting C<$LnCacheHours>.

=cut

push (MyMaintenance, \&LnMaintenance);

sub LnMaintenance {
  if (opendir(DIR, $RssDir)) { # cleanup if they should expire anyway
    foreach (readdir(DIR)) {
      unlink "$RssDir/$_" if $Now - (stat($_))[9] > $LnCacheHours * 3600;
    }
    closedir DIR;
  }
}

=head2 Defining Local Names

Local Names are defined on the LocalNames page.

If you create ordinary named external links such as
C<[http://ln.taoriver.net/ Local Names Website]> on the LocalNames
page, you will have defined a new Local Name. If you write C<[[Local
Names Website]]> elsewhere on the site (and the page does not exist),
that link will point to the website you specified.

You can link from the LocalNames page to existing namespace
descriptions. These other namespace descriptions must use the
namespace description format developed by Lion Kimbro. If you write
C<[[ln:URL]]> or C<[[ln:URL text]]>, this will import all the Local
Names defined there into your wiki.

Example: C<[[ln:http://ln.taoriver.net/localnames.txt Lion's Example
Localnames List]]>.

Currently only LN records with absolute URLs are parsed correctly. All
other record types are ignored.

If you want to learn more about local names, see
L<http://ln.taoriver.net/>.

=cut

# render [[ln:url]] as something clickable
push(@MyRules, \&LocalNamesRule);

sub LocalNamesRule {
  if (m/\G\[\[ln:$FullUrlPattern\s*([^\]]*)\]\]/cog) {
    # [[ln:url text]], [[ln:url]]
    return $q->a({-class=>'url outside ln', -href=>$1}, $2||$1);
  }
  return undef;
}

=head2 Initialization

The LocalNames page is added to C<%AdminPages> so that the
Administration page will list a link to it. The LocalNames page will
be read and parsed for every request. The result is that the
C<%LocalNames> hash has pagenames as keys and URLs to redirect to as
values.

If the LocalNames page refers to external lists of redirections, these
will be read from the cache or fetched anew if older than twelve
hours. If you use the cache=0 parameter in an URL or set C<$UseCache>
to zero or less, Oddmuse will B<fetch the lists of redirections every
single time>. Using the cache=0 parameter is a way to force Oddmuse to
expire the cache. Setting C<$UseCache> to 0 should not be used on a
live site.

Definitions of redirections on the LocalNames take precedence over
redirections defined on remote sites. Earlier lists of redirections
take precedence over later lists.

We ignore the spec at L<http://ln.taoriver.net/spec-1.2.html#Syntax>
when considering what names we allow, since Oddmuse will parse them as
regular links anyway.

=cut

push(@MyInitVariables, \&LocalNamesInit);

sub LocalNamesInit {
  %WantedPages = (); # list of missing pages used during this request
  %LocalNames = ();
  $LocalNamesPage = FreeToNormal($LocalNamesPage); # spaces to underscores
  $AdminPages{$LocalNamesPage} = 1;
  my $data = GetPageContent($LocalNamesPage);
  while ($data =~ m/\[$FullUrlPattern\s+([^\]]+?)\]/go) {
    my ($page, $url) = ($2, $1);
    my $id = FreeToNormal($page);
    $LocalNames{$id} = $url;
  }
  # Now read data from ln links, checking cache if possible. For all
  # URLs not in the cache or with invalid cache, fetch the file again,
  # and save it in the cache.
  my @ln = $data =~ m/\[\[ln:$FullUrlPattern[^\]]*?\]\]/go;
  my %todo = map {$_, GetLnFile($_)} @ln;
  my %data = ();
  if (GetParam('cache', $UseCache) > 0) {
    foreach my $uri (keys %todo) { # read cached rss files if possible
      if ($Now - (stat($todo{$uri}))[9] < $LnCacheHours * 3600) {
	$data{$uri} = ReadFile($todo{$uri});
	delete($todo{$uri}); # no need to fetch them below
      }
    }
  }
  my @need_cache = keys %todo;
  if (keys %todo > 1) { # try parallel access if available
    eval { # see code example in LWP::Parallel, not LWP::Parllel::UserAgent (no callbacks here)
      require LWP::Parallel::UserAgent;
      my $pua = LWP::Parallel::UserAgent->new();
      foreach my $uri (keys %todo) {
	if (my $res = $pua->register(HTTP::Request->new('GET', $uri))) {
	  warn $res->error_as_HTML;
	}
      }
      %todo = (); # because the uris in the response may have changed due to redirects
      my $entries = $pua->wait();
      foreach (keys %$entries) {
	my $uri = $entries->{$_}->request->uri;
	$data{$uri} = $entries->{$_}->response->content;
      }
    }
  }
  foreach my $uri (keys %todo) { # default operation: synchronous fetching
    $data{$uri} = GetRaw($uri);
  }
  if (GetParam('cache', $UseCache) > 0) {
    CreateDir($LnDir);
    foreach my $uri (@need_cache) {
      WriteStringToFile(GetLnFile($uri), $data{$uri});
    }
  }
  # go through the urls in the right order, this time
  foreach my $ln (@ln) {
    my ($previous_type, $previous_url);
    foreach my $line (split(/[\r\n]+/, $data{$ln})) {
      if ($line =~ /^LN\s+"$FreeLinkPattern"\s+(?:"$FullUrlPattern"|\.)$/
	  or $previous_type eq 'LN'
	  and $line =~ /^\.\s+"$FreeLinkPattern"\s+(?:"$FullUrlPattern"|\.)$/) {
	my ($name, $url) = ($1, $2);
	$url = $previous_url if not $url and $previous_url;
	$previous_url = $url;
	$previous_type = 'LN';
	my $id = FreeToNormal($name);
	# Only store this, if not already stored!
	if (not $LocalNames{$id}) {
	  $LocalNames{$id} = $url;
	}
      } else {
	$previous_type = undef;
      }
      # elsif ($line =~ /^NS "(.*)" "$FullUrlPattern"$/g) {
      # }
    }
  }
}

=head2 Name Resolution

We want Near Links only to have an effect for pages that do not exist
locally. It should not take precedence! Thus, we hook into
C<ResolveId>; this function returns a list of four elements: CSS
class, resolved id, title (eg. for popups), and a boolean saying
whether the page exists or not. If the second element is empty, then
no page exists and we check C<%LocalNames> for a match. If there is a
match, we return the URL using the CSS class "near" and the title
"LocalNames". The CSS class is the same that is used for Near Links
because the effect is so similar.

Note: Existing local pages take precedence over local names, but local
names take precedence over Near Links.

We also keep track of wanted pages (links to missing pages) so that we
can printe a list of definition links at the bottom using the Define
Action (see below).

=cut

*OldLocalNamesResolveId = *ResolveId;
*ResolveId = *NewLocalNamesResolveId;

sub NewLocalNamesResolveId {
  my $id = shift;
  my ($class, $resolved, @rest) = OldLocalNamesResolveId($id, @_);
  if ((not $resolved or $class eq 'near') and $LocalNames{$id}) {
    return ('near', $LocalNames{$id}, $LocalNamesPage);
  } else {
    $WantedPages{$id} = 1 if not $resolved; # this is provisional!
    return ($class, $resolved, @rest);
  }
}

=head2 Automatically Defining Local Names

It is possible to have Oddmuse automatically define local names as you
edit pages. In order to enable this, set C<$LocalNamesCollect> to 1.
Once you this, every time you save a page with a named external link
such as C<[http://www.emacswiki.org/alex/ Alex]>, this will add or
update the corresponding entry on the LocalNames page.

In order to reduce the number of entries thus collected, only external
links with a name consisting of one or two words are used. You can
change this word limit by setting C<$LocalNamesCollectMaxWords>.

The default limit of two words assumes that you might want to make
C<Alex> a link, or C<Alex Schroeder>, but not C<the example on Alex’s
blog> (five “words”, since the code looks at whitespace only).

=cut

*LocalNamesOldSave = *Save;
*Save = *LocalNamesNewSave;

sub LocalNamesNewSave {
  LocalNamesOldSave(@_);
  my ($currentid, $text) = @_;
  # avoid recursion
  return if $currentid eq $LocalNamesPage or not $LocalNamesCollect;
  my $currentname = $currentid;
  $currentname =~ s/_/ /g;
  local ($OpenPageName, %Page);
  OpenPage($LocalNamesPage);
  my $localnames = $Page{text};
  my %map = ();
  while ($text =~ /\[$FullUrlPattern\s+(([^ \]]+?\s*){1,$LocalNamesCollectMaxWords})\]/g) {
    my ($page, $url) = ($2, $1);
    my $id = FreeToNormal($page);
    $map{$id} = () unless defined $map{$id};
    $map{$id}{$url} = 1;
  }
  my %collection = ();
  foreach my $id (keys %map) {
    # canonical form with trimmed spaces and no underlines
    my $page = $id;
    $page =~ s/_/ /g;
    # skip if the mapping from id to url already defined matches at
    # least one of the definitions on the current page.
    next if $map{$id}{$LocalNames{$id}};
    $collection{$page} = 1;
    # pick a random url from the list
    my @urls = keys %{$map{$id}};
    my $url = $urls[0];
    # if a different mapping exists already; change the old mapping to the new one
    # if the change fails (eg. the page name is not in canonical form), don't skip!
    next if $LocalNames{$id}
      and $localnames =~ s/\[$LocalNames{$id}\s+$page\]/[$url $page]/g;
    # add a new entry at the end
    $localnames .= "\n\n* [$url $page]"
      . Ts(" -- defined on %s", "[[$currentname]]");
    $LocalNames{$id} = $url; # prevent multiple additions
  }
  # minor change
  my @collection = sort keys %collection;
  Save($LocalNamesPage, $localnames,
       Tss("Local names defined on %1: %2", $currentname,
	   length(@collection > 1)
	   ? join(', and ',
		  join(', ', @collection[0 .. $#collection-1]),
		  @collection[-1])
	   : @collection), 1)
    unless $localnames eq $Page{text};
}

=head2 Local Names Format

The Ln Action lists all the local pages in the local names format
defined in the specification. Example URL:
C<http://localhost/cgi-bin/wiki?action=ln>.

If you want to learn more about local names and the format used, see
L<http://ln.taoriver.net/>.

=cut

$Action{ln} = \&DoLocalNames;

sub DoLocalNames {
  print GetHttpHeader('text/plain');
  print "X VERSION 1.2\n";
  print "# Local Pages\n";
  foreach my $id (AllPagesList()) {
    my $title = $id;
    $title =~ s/_/ /g;
    my $url = $ScriptName . ($UsePathInfo ? '/' : '?') . $id;
    print qq{LN "$title" "$url"\n};
  }
  if (GetParam('expand', 0)) {
    print "# Local names defined on $LocalNamesPage:\n";
    my $data = GetPageContent($LocalNamesPage);
    while ($data =~ m/\[$FullUrlPattern\s+([^\]]+?)\]/go) {
      my ($title, $url) = ($2, $1);
      my $id = FreeToNormal($title);
      print qq{LN "$title" "$url"\n};
    }
    print "# Namespace delegations defined on $LocalNamesPage:\n";
    while ($data =~ m/\[\[ln:$FullUrlPattern([^\]]*)?\]\]/go) {
      my ($title, $url) = ($2, $1);
      my $id = FreeToNormal($title);
      print qq{NS "$title" "$url"\n};
    }
  } else {
    print "# Local names defined on $LocalNamesPage:\n";
    foreach my $id (keys %LocalNames) {
      my $title = $id;
      $title =~ s/_/ /g;
      print qq{LN "$title" "$LocalNames{$id}"\n};
    }
  }
}

=head2 Define Action

The Define Action allows you to interactively add local names using a
form. Example URL: C<http://localhost/cgi-bin/wiki?action=define>.

You can also provide the C<name> and C<link> parameters yourself if
you want to use this action from a script.

As wanted pages (links to missing pages) come up, you will get links
to appropriate define actions in your footer.

=cut

$Action{define} = \&DoDefine;

sub DoDefine {
  if (GetParam('link', '') and GetParam('name', '')) {
    SetParam('title', $LocalNamesPage);
    SetParam('text', GetPageContent($LocalNamesPage) . "\n* ["
	     . GetParam('link', '') . ' ' . GetParam('name', '')
	     . "]\n");
    SetParam('summary', 'Defined ' . GetParam('name'));
    return DoPost($LocalNamesPage);
  } else {
    print GetHeader('', T('Define')),
      $q->start_div({-class=>'content define'}),
	GetFormStart(undef, 'get', 'def');
    my $go = T('Go!');
    print $q->p($q->label({-for=>"defined"}, T('Name: ')),
		$q->textfield(-name=>"name", -id=>"defined",
			      -tabindex=>"1", -size=>20));
    print $q->p($q->label({-for=>"definition"}, T('URL: ')),
		$q->textfield(-name=>"link", -id=>"definition",
			      -tabindex=>"2", -size=>20));
    print $q->p($q->submit(-label=>$go, -tabindex=>"3"),
		GetHiddenValue('action', 'define'),
		GetHiddenValue('recent_edit', 'on'));
    print $q->end_form, $q->end_div();
    PrintFooter();
  }
}

push(@MyAdminCode, sub {
       my ($id, $menuref, $restref) = @_;
       push(@$menuref, ScriptLink('action=define', T('Define Local Names'),
				  'define'));
     });

# link to define action for non-existing pages



push(@MyFooters, \&GetWantedPages);

sub GetWantedPages {
  # skip admin pages
  foreach my $id (@UserGotoBarPages, keys %AdminPages) {
    delete $WantedPages{$id};
  }
  # skip comment pages
  if ($CommentsPrefix) {
    foreach my $id (keys %WantedPages) {
      delete $WantedPages{$id} if $id =~ /^$CommentsPrefix/o;
    }
  }
  # now something more complicated: if near-links.pl was loaded, then
  # %WantedPages may contain pages that will in fact resolve. That's
  # why we try to resolve all the wanted ids again. And since
  # resolving ids will do stuff to %WantedPages, we need to make a
  # copy of the ids we're looking at.
  my @wanted;
  foreach my $id (keys %WantedPages) {
    my ($class, $resolved)  = ResolveId($id);
    push(@wanted, $id) unless $resolved;
  }
  # if any wanted pages remain, print them
  if (@wanted) {
    return $q->div({-class=>'definition'},
		   $q->p(T('Define external redirect: '),
			 map { my $page = NormalToFree($_);
			       ScriptLink('action=define;name='
					  . UrlEncode($page),
					  $page,
					  'define');
			     } @wanted));
  }
  return '';
}
