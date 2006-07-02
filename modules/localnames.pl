# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: localnames.pl,v 1.20 2006/07/02 12:17:12 as Exp $</p>';

use vars qw($LocalNamesPage $LocalNamesInit %LocalNames $LocalNamesCollect
	    $LocalNamesCollectMaxWords $LnDir $LnCacheHours);

$LocalNamesPage = 'LocalNames';
$LocalNamesCollect = 0;
$LocalNamesCollectMaxWords = 2;
# LN caching is written very similar to the RSS file caching
$LnDir = "$DataDir/ln";
$LnCacheHours = 12;

sub GetLnFile {
  return $LnDir . '/' . UrlEncode(shift);
}

push (MyMaintenance, \&LnMaintenance);

sub LnMaintenance {
  if (opendir(DIR, $RssDir)) { # cleanup if they should expire anyway
    foreach (readdir(DIR)) {
      unlink "$RssDir/$_" if $Now - (stat($_))[9] > $LnCacheHours * 3600;
    }
    closedir DIR;
  }
}

# render [[ln:url]] as something clickable
push(@MyRules, \&LocalNamesRule);

sub LocalNamesRule {
  if (m/\G\[\[ln:$FullUrlPattern\s*([^\]]*)\]\]/cog) {
    # [[ln:url text]], [[ln:url]]
    return $q->a({-class=>'url outside ln', -href=>$1}, $2||$1);
  }
  return undef;
}

# do this later so that the user can customize $LocalNamesPage
push(@MyInitVariables, \&LocalNamesInit);

*OldLocalNamesReInit = *ReInit;
*ReInit = *NewLocalNamesReInit;

sub NewLocalNamesReInit {
  my $id = shift;
  OldLocalNamesReInit($id, @_);
  $LocalNamesInit = 0 if not $id or $id eq $LocalNamesPage;
}

# Just hook into NearLink stuff -- whenever near links are
# initialized, we initialize as well.  Add our stuff first, because
# local names have priority over near links.

sub LocalNamesInit {
  return if $LocalNamesInit; # just once, mod_perl!
  $LocalNamesInit = 1;
  %LocalNames = ();
  $LocalNamesPage = FreeToNormal($LocalNamesPage); # spaces to underscores
  push(@AdminPages, $LocalNamesPage);
  my $data = GetPageContent($LocalNamesPage);
  while ($data =~ m/\[$FullUrlPattern\s+([^\]]+?)\]/go) {
    my ($page, $url) = ($2, $1);
    my $id = FreeToNormal($page);
    # The entries in %NearSource will make sure that ResolveId will
    # call GetInterSiteUrl for our pages.
    $LocalNames{$id} = $url;
    # Add at the front to override near links.
    unshift(@{$NearSource{$id}}, $LocalNamesPage);
    # %NearSite is for fetching the list of pages -- we don't need that.
    # %NearSearch is for searching remote sites -- we don't need that.
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
    my ($previous_name, $previous_url);
    foreach my $line (split(/[\r\n]+/, $data{$ln})) {
      if ($line =~ /^LN "$FreeLinkPattern" "$FullUrlPattern"$/) {
	my ($name, $url) = ($1, $2);
	$name = $previous_name if $name eq "." and $previous_name;
	$url = $previous_url if $url eq "." and $previous_url;
	$previous_name = $name;
	$previous_url = $url;
	# We ignore the spec at
	# http://ln.taoriver.net/spec-1.2.html#Syntax when it comes to
	# the names we allow, since Oddmuse will have to do the
	# [[name]] thing!
	my $id = FreeToNormal($name);
	# Only store this, if not already stored!
	if (not $LocalNames{$id}) {
	  # The entries in %NearSource will make sure that ResolveId will
	  # call GetInterSiteUrl for our pages.
	  $LocalNames{$id} = $url;
	  # Add at the front to override near links.
	  unshift(@{$NearSource{$id}}, $LocalNamesPage);
	  # %NearSite is for fetching the list of pages -- we don't need that.
	  # %NearSearch is for searching remote sites -- we don't need that.
	}
      }
      # elsif ($line =~ /^NS "(.*)" "$FullUrlPattern"$/g) {
      # }
    }
  }
}

# Allow interlinks: We cannot just use %InterSite, because that would
# result in the same ULR for $LocalNamesPage all the time.

*OldLocalNamesGetInterSiteUrl = *GetInterSiteUrl;
*GetInterSiteUrl = *NewLocalNamesGetInterSiteUrl;

sub NewLocalNamesGetInterSiteUrl {
  my ($site, $page, $quote) = @_;
  if ($site eq $LocalNamesPage and $LocalNames{$page}) {
    return $LocalNames{$page}
  } else {
    return OldLocalNamesGetInterSiteUrl($site, $page, $quote);
  }
}

*LocalNamesOldSave = *Save;
*Save = *LocalNamesNewSave;

sub LocalNamesNewSave {
  LocalNamesOldSave(@_);
  my ($currentid, $text) = @_;
  # avoid recursion
  return if $currentid eq $LocalNamesPage or not $LocalNamesCollect;
  my $currentname = $currentid;
  $currentname =~ s/_/ /g;
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
