# Copyright (C) 2003–2013  Alex Schroeder <alex@gnu.org>
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

use strict;
use v5.10;

AddModuleDescription('near-links.pl', 'Near Links');

our ($q, $Now, %AdminPages, %InterSite, $CommentsPrefix, $DataDir, $UseCache, @MyFooters, @MyMaintenance, @MyInitVariables, @Debugging, $InterSitePattern, @UserGotoBarPages, @IndexOptions);

=head1 Near Links

URL abbreviations facilitate linking to other wikis. For example, if
you define the abbreviation Community, you might link to
Community:WhyWikiWorks. Near Links takes this even further: If you use
an ordinary link to WhyWikiWorks, this will link to
Community:WhyWikiWorks if there is no local WhyWikiWorks page.

=cut

our (%NearSite, %NearSource, %NearLinksUsed, $NearDir, $NearMap,
%NearSearch, $SisterSiteLogoUrl, %NearLinksException);

=head2 Options

=cut

$NearMap = 'NearMap';
$NearDir = "$DataDir/near"; # for page indexes and .png files of other sites

=head2 Initialization

There are several steps required before Near Links work as expected.

You must have an B<InterMap> page to define URL abbreviations. There,
you associate a prefix with a partial URL on every line that starts
with a space:

 Community http://www.communitywiki.org/en/

You must have a B<NearMap> page. There, you associate some of the
prefixes defined on the InterMap page with an URL that tells Oddmuse
how to retrieve the list of all pages from the site. Again, only lines
starting with a single space are considered, allowing you to mix
explanatory paragraphs with data.

 Community http://www.communitywiki.org/en?action=index;raw=1

Remember to use the same key as on the InterMap page!

There is an optional third item you can place on that line telling
Oddmuse how to forward searches to the remote site.

You must run B<Maintenance> once. At the end of the maintenance output
you should see a line for every prefix on your NearMap telling you
that the list of pages is being retrieved: "Getting page index file
for Community." This page index file is created in the C<near>
directory in your data directory.

You can change the name of the NearMap page by setting the C<$NearMap>
option:

    $NearMap = 'Local_Near_Map';

You can change the directory used for caching the remote page index
files by setting the C<$NearDir> option:

    $NearDir = '/var/oddmuse/near';

=cut

push(@MyInitVariables, \&NearLinksInit);

sub NearLinksInit {
  $NearMap = FreeToNormal($NearMap); # just making sure
  $AdminPages{$NearMap} = 1;	# list it on the admin page
  %NearLinksUsed = ();	        # list of links used during this request
  %NearSite = ();
  %NearSearch = ();
  %NearSource = ();
  # Don't overwrite the values other modules might have set
  $NearLinksException{rc} = 1;
  $NearLinksException{rss} = 1;
  foreach (split(/\n/, GetPageContent($NearMap))) {
    if (/^ ($InterSitePattern)[ \t]+([^ ]+)(?:[ \t]+([^ ]+))?$/) {
      my ($site, $url, $search) = ($1, $2, $3);
      next unless $InterSite{$site};
      $NearSite{$site} = $url;
      $NearSearch{$site} = $search if $search;
      my ($status, $data) = ReadFile("$NearDir/$site");
      next unless $status;
      foreach my $page (split(/\n/, $data)) {
	push(@{$NearSource{$page}}, $site);
      }
    }
  }
}

=head2 Maintenance

C<NearLinksMaintenance> is added to C<@MyMaintenance> in order to
download all page indexes from the remote sites defined on the NearMap
page. The download is skipped if the existing page index for the
remote site is less than twelve hours old. If you want to force this,
you need to delete the page indexes in the cache directory. Look for
the C<near> directory in your data directory, unless you set
C<$NearDir>.

=cut

push(@MyMaintenance, \&NearLinksMaintenance);

sub NearLinksMaintenance {
  if (%NearSite) {
    CreateDir($NearDir);
    # skip if less than 12h old and caching allowed (the default)
    foreach my $site (keys %NearSite) {
      next if GetParam('cache', $UseCache) > 0
	and IsFile("$NearDir/$site")
	and $Now - Modified("$NearDir/$site") < 0.5;
      print $q->p(Ts('Getting page index file for %s.', $site));
      my $data = GetRaw($NearSite{$site});
      print $q->p($q->strong(Ts('%s returned no data, or LWP::UserAgent is not available.',
				$q->a({-href=>$NearSite{$site}},
				      $NearSite{$site})))) unless $data;
      WriteStringToFile("$NearDir/$site", $data);
    }
  }
}

=head2 Debugging Initialization

You can use the Debug Action to list the Near Links found in addition
to the Inter Links:

 http://localhost/cgi-bin/wiki?action=debug

If there are no Near Links defined, check the initialization
requirements listed above.

=cut

push(@Debugging, \&DoNearLinksList);

sub DoNearLinksList {
  print $q->h2(T('Near links:')),
    $q->p(join('; ',
	       map { GetPageLink($_) . ': ' . join(', ', @{$NearSource{$_}})}
	       sort keys %NearSource));
}

=head2 Name Resolution

We want Near Links only to have an effect for pages that do not exist
locally. It should not take precedence! Thus, we hook into
C<ResolveId>; this function returns a list of four elements: CSS
class, resolved id, title (eg. for popups), and a boolean saying
whether the page exists or not. If the second element is empty, then
no page exists and we check C<%NearSource> for a match. C<%NearSource>
uses the page id as a key and a list of sites as the value. We just
pick the first site on the list and return it as an URL (and using the
CSS class "near").

The pages explicitly excluded from being Near Links are the ones most
likely to confuse first users: All the pages on C<@UserGotoBarPages>
and all pages in C<%AdminPages>.

=cut

*OldNearLinksResolveId = \&ResolveId;
*ResolveId = \&NewNearLinksResolveId;

sub NewNearLinksResolveId {
  my $id = shift;
  my @result = OldNearLinksResolveId($id, @_);
  my %forbidden = map { $_ => 1 } @UserGotoBarPages, %AdminPages;
  $forbidden{$id} = 1 if $CommentsPrefix and $id =~ /^$CommentsPrefix/;
  if (not $result[1] and $NearSource{$id} and not $forbidden{$id}) {
    $NearLinksUsed{$id} = 1;
    my $site = $NearSource{$id}[0];
    return ('near', GetInterSiteUrl($site, $id), $site); # return source as title attribute
  } else {
    return @result;
  }
}

=head2 Search

This module allows you to send search terms to remote sites. You need
to tell Oddmuse how to do this, however. On the NearMap, this is what
you do: Lines starting with a single space and an URL abbreviation
(defined on the InterMap), an URL that retrieves the list of pages on
the remote site, and an URL that runs a search and returns the result
in RSS 3.0 format.

Here's an example. Remember that this should all go on a single line
starting with a single space:

 Community http://www.communitywiki.org/cw?action=index;raw=1
 http://www.communitywiki.org/cw?search=%s;raw=1;near=0

If you want to know more about the RSS 3.0 format, take a look at the
specification: L<http://www.aaronsw.com/2002/rss30>.

The effect is that when you search something, the search will be a
local search. There will be a link called "Search sites on the NearMap
as well" at the beginning of your local search results. Clicking on
the link will include search results from remote sites as well.

=head3 Development

C<%NearLinksException> is used to store all the actions where a search
should not result in the printing of pages. Theoretically we could use
the presence of the C<$func> parameter in the call to
C<SearchTitleAndBody>, but there are two problems with this approach:
We don't know what the code does. It might just be collecting data
without printing anything. And even if we did, and skipped the
printing, we'd be searching the near pages in vain in the case of
RecentChanges and RSS feeds, since the near pages have no change date
and therefore can never be presented chronologically. Developer input
will be necessary in all cases.

=cut

*OldNearLinksSearchMenu = \&SearchMenu;
*SearchMenu = \&NewNearLinksSearchMenu;

sub NewNearLinksSearchMenu {
  my $string = shift;
  my $result = OldNearLinksSearchMenu($string);
  $result .= ' ' . ScriptLink('near=2;search=' . UrlEncode($string),
			      Ts('Search sites on the %s as well', $NearMap))
    if %NearSearch and GetParam('near', 1) < 2;
  return $result;
}

*OldNearLinksSearchTitleAndBody = \&SearchTitleAndBody;
*SearchTitleAndBody = \&NewNearLinksSearchTitleAndBody;

sub NewNearLinksSearchTitleAndBody {
  my $string = shift;
  my @result = OldNearLinksSearchTitleAndBody($string, @_);
  my $action = GetParam('action', 'browse');
  @result = SearchNearPages($string, @result)
    if GetParam('near', 1) and not $NearLinksException{$action};
  return @result;
}

sub SearchNearPages {
  my $string = shift;
  my %found = map {$_ => 1} @_;
  my $regex = SearchRegexp($string);
  if (%NearSearch and GetParam('near', 1) > 1 and GetParam('context',1)) {
    foreach my $site (keys %NearSearch) {
      my $url = $NearSearch{$site};
      $url =~ s/\%s/UrlEncode($string)/eg or $url .= UrlEncode($string);
      print $q->hr(), $q->p(Ts('Fetching results from %s:', $q->a({-href=>$url}, $site)))
	unless GetParam('raw', 0);
      my $data = GetRaw($url);
      my @entries = split(/\n\n+/, $data);
      shift @entries; # skip head
      foreach my $entry (@entries) {
	my $entryPage = ParseData($entry); # need to pass reference
	my $name = $entryPage->{title};
	next if $found{$name}; # do not duplicate local pages
	$found{$name} = 1;
	PrintSearchResultEntry($entryPage, $regex); # with context and full search!
      }
    }
  }
  if (%NearSource and (GetParam('near', 1) or GetParam('context',1) == 0)) {
    my $intro = 0;
    foreach my $name (sort keys %NearSource) {
      next if $found{$name}; # do not duplicate local pages
      if (SearchString($string, NormalToFree($name))) {
	$found{$name} = 1;
	print $q->hr() . $q->p(T('Near pages:')) unless GetParam('raw', 0) or $intro;
	$intro = 1;
	PrintPage($name); # without context!
      }
    }
  }
  return keys(%found);
}

=head2 Index Of All Pages

The index of all pages will offer a new option called "Include near
pages". This uses the C<near> parameter. Example:
C<http://localhost/cgi-bin/wiki?action=index;near=1>.

We don't need to list remote pages that also exist locally, since the
index will resolve pages as they get printed. If we list remote pages,
all we'll do is have the name twice on the list, and they'll get
resolved to the same target (the local page), which is unexpected.

=cut


# IndexOptions must be set in MyInitVariables for translations to
# work.
push(@MyInitVariables, sub {
  push(@IndexOptions, ['near', T('Include near pages'), 0, \&ListNearPages])});

sub ListNearPages {
  my %pages = %NearSource;
  if (GetParam('pages', 1)) {
    foreach my $page (AllPagesList()) {
      delete $pages{$page};
    }
  }
  return keys %pages;
}

=head2 Defining Near Linked Pages

When Oddmuse links to a remote site via NearLinks, it is difficult to
create a local copy of the page. After all, there is no edit link.
That's why the appropriate edit links will be presented at the bottom
of the page. This list will be prefixed with a link to the page called
B<EditNearLinks>. This allows you to explain what's going on to your
users.

To change the name of this page, use translation:

    C<$Translate{EditNearLinks}='Define these pages locally';>

These edit links for local pages are inside a div with the class
"near".

=cut

push(@MyFooters, \&GetNearLinksUsed);

sub GetNearLinksUsed {
  if (%NearLinksUsed) {
    return $q->div({-class=>'near'},
		   $q->p(GetPageLink(T('EditNearLinks')) . ':',
			 map { GetEditLink($_, $_); } keys %NearLinksUsed));
  }
  return '';
}

=head2 Twin Pages

When looking at local pages that also exist on remote sites, Oddmuse
will add links to the various remote versions at the bottom of the
page. (These remote sites are sometimes also referred to as "sister
sites".)

You will need logos for these remote sites. You specify where the
logos are to be found by setting C<$SisterSiteLogoUrl>. The C<%s> will
be replaced by the URL abbreviation used.

Example:

    $SisterSiteLogoUrl = "http://www.emacswiki.org/pics/%s.png";

For the Community:WhyWikiWorks page, this will result in the URL
L<http://www.emacswiki.org/pics/Community.png>.

These logos for twin pages are inside a div with the class "sister".

=cut

push(@MyFooters, \&GetSisterSites);

$SisterSiteLogoUrl = 'file:///tmp/oddmuse/%s.png';

sub GetSisterSites {
  my $id = shift;
  if ($id and $NearSource{$id}) {
    my $sistersites = T('The same page on other sites:') . $q->br();
    foreach my $site (@{$NearSource{$id}}) {
      my $logo = $SisterSiteLogoUrl;
      $logo =~ s/\%s/$site/g;
      $sistersites .= $q->a({-href=>GetInterSiteUrl($site, $id),
			     -title=>"$site:$id"},
			    $q->img({-src=>$logo,
				     -alt=>"$site:$id"}));
    }
    return $q->div({-class=>'sister'}, $q->p($sistersites));
  }
  return '';
}
