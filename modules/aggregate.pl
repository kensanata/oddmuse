# Copyright (C) 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: aggregate.pl,v 1.9 2007/06/26 09:40:41 as Exp $</p>';

push(@MyRules, \&AggregateRule);

sub AggregateRule {
  if ($bol && m/\G(&lt;aggregate\s+((("[^\"&]+",?\s*)+)|(sort\s+)?search\s+(.+?))&gt;)/gc) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my ($oldpos, $old_, $str, $sort, $search) = ((pos), $_, $3, $5, $6);
    my $master = $OpenPageName;
    local ($OpenPageName, %Page);
    print $q->start_div({class=>"aggregate journal"});
    my @pages = ();
    @pages = $str =~ m/"([^\"&]+)"/g if $str;
    @pages = SearchTitleAndBody($search) if $search;
    if ($sort) {
      if (defined &PageSort) {
	@pages = sort PageSort @pages;
      } else {
	@pages = sort(@pages);
      }
    }
    foreach my $id (@pages) {
      next if $id eq $master;
      my $title = $id;
      local $OpenPageName = FreeToNormal($id);
      my $page = GetPageContent($OpenPageName);
      my $size = length($page);
      my $i = index($page, "\n=");
      my $j = index($page, "\n----");
      $page = substr($page, 0, $i) if $i >= 0;
      $page = substr($page, 0, $j) if $j >= 0;
      $page =~ s/^=.*\n//; # if it starts with a header
      print $q->start_div({class=>"page"}),
	$q->h2(GetPageLink($OpenPageName, $title));
      ApplyRules(QuoteHtml($page), 1, 0, undef, 'p');
      print $q->p(GetPageLink($OpenPageName, T('Learn more...')))
	if length($page) < $size;
      print $q->end_div();
    }
    print $q->end_div();
    Clean(AddHtmlEnvironment('p'));
    ($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
    return '';
  }
  return undef;
}

$Action{aggregate} = \&DoAggregate;

sub DoAggregate {
  print GetHttpHeader('application/xml');
  my $frontpage = GetParam('id', $HomePage);
  my $title = $frontpage;
  $title =~ s/_/ /g;
  my $source = GetPageContent($frontpage);
  my $url = QuoteHtml($ScriptName);
  my $diffPrefix = $url . QuoteHtml("?action=browse;diff=1;id=");
  my $historyPrefix = $url . QuoteHtml("?action=history;id=");
  my $date = TimeToRFC822($LastUpdate);
  my $rss = qq{<?xml version="1.0" encoding="utf-8"?>};
  if ($RssStyleSheet =~ /\.(xslt?|xml)$/) {
    $rss .= qq{<?xml-stylesheet type="text/xml" href="$RssStyleSheet" ?>};
  } elsif ($RssStyleSheet) {
    $rss .= qq{<?xml-stylesheet type="text/css" href="$RssStyleSheet" ?>};
  }
  $rss .= qq{<rss version="2.0"
     xmlns:wiki="http://purl.org/rss/1.0/modules/wiki/"
     xmlns:creativeCommons="http://backend.userland.com/creativeCommonsRssModule">
<channel>
<docs>http://blogs.law.harvard.edu/tech/rss</docs>
};
  $rss .= "<title>" . QuoteHtml("$SiteName: $title") . "</title>\n";
  $rss .= "<link>" . $url . ($UsePathInfo ? "/" : "?") . UrlEncode($frontpage) . "</link>\n";
  $rss .= "<description>" . QuoteHtml($SiteDescription) . "</description>\n";
  $rss .= "<pubDate>" . $date. "</pubDate>\n";
  $rss .= "<lastBuildDate>" . $date . "</lastBuildDate>\n";
  $rss .= "<generator>Oddmuse</generator>\n";
  $rss .= "<copyright>" . $RssRights . "</copyright>\n" if $RssRights;
  if (ref $RssLicense eq 'ARRAY') {
      $rss .= join('', map {"<creativeCommons:license>$_</creativeCommons:license>\n"} @$RssLicense);
  } elsif ($RssLicense) {
    $rss .= "<creativeCommons:license>" . $RssLicense . "</creativeCommons:license>\n";
  }
  $rss .= "<wiki:interwiki>" . $InterWikiMoniker . "</wiki:interwiki>\n" if $InterWikiMoniker;
  if ($RssImageUrl) {
    $rss .= "<image>\n";
    $rss .= "<url>" . $RssImageUrl . "</url>\n";
    $rss .= "<title>" . QuoteHtml($SiteName) . "</title>\n";
    $rss .= "<link>" . $url . "</link>\n";
    $rss .= "</image>\n";
  }
  while ($source =~ m/<aggregate\s+((("[^\"&]+",?\s*)+)|(sort\s+)?search\s+(.+?))>/g) {
    my ($str, $sort, $search) = ($1, $5, $6);
    my @pages = ();
    @pages = $str =~ m/"([^\"&]+)"/g if $str;
    @pages = SearchTitleAndBody($search) if $search;
    if ($sort) {
      if (defined &PageSort) {
	@pages = sort PageSort @pages;
      } else {
	@pages = sort(@pages);
      }
    }
    foreach my $id (@pages) {
      my %data = ParseData(ReadFileOrDie(GetPageFile(FreeToNormal($id))));
      my $page = $data{text};
      my $size = length($page);
      my $i = index($page, "\n=");
      my $j = index($page, "\n----");
      $page = substr($page, 0, $i) if $i >= 0;
      $page = substr($page, 0, $j) if $j >= 0;
      $page =~ s/^=.*\n//; # if it starts with a header
      my $name = $id;
      $name =~ s/_/ /g;
      my $date = TimeToRFC822($data{ts});
      my $host = $data{host};
      my $username = $data{username};
      $username = QuoteHtml($username);
      $username = $host unless $username;
      my $minor = $data{minor};
      my $revision = $data{revision};
      my $cluster = GetCluster($page);
      my $description;
      {
	local *STDOUT;
	open(STDOUT, '>', \$description) or die "Can't open memory file: $!";
	ApplyRules(QuoteHtml($page), 1, 0, undef, 'p');
      }
      $description .= $q->p(GetPageLink($id, T('Learn more...')))
	if length($page) < $size;
      $rss .= "\n<item>\n";
      $rss .= "<title>" . QuoteHtml($name) . "</title>\n";
      $rss .= "<link>" . $url . (GetParam("all", 0)
        ? "?" . GetPageParameters("browse", $id, $revision, $cluster)
	: ($UsePathInfo ? "/" : "?") . UrlEncode($id)) . "</link>\n";
      $rss .= "<description>" . QuoteHtml($description) . "</description>\n";
      $rss .= "<pubDate>" . $date . "</pubDate>\n";
      $rss .= "<comments>" . $url . ($UsePathInfo ? "/" : "?")
	. $CommentsPrefix . UrlEncode($id) . "</comments>\n"
	  if $CommentsPrefix and $id !~ /^$CommentsPrefix/;
      $rss .= "<wiki:username>" . $username . "</wiki:username>\n";
      $rss .= "<wiki:status>" . (1 == $revision ? "new" : "updated") . "</wiki:status>\n";
      $rss .= "<wiki:importance>" . ($minor ? "minor" : "major") . "</wiki:importance>\n";
      $rss .= "<wiki:version>" . $revision . "</wiki:version>\n";
      $rss .= "<wiki:history>" . $historyPrefix . UrlEncode($id) . "</wiki:history>\n";
      $rss .= "<wiki:diff>" . $diffPrefix . UrlEncode($id) . "</wiki:diff>\n"
	if $UseDiff and GetParam("diffrclink", 1);
      $rss .= "</item>\n";
    }
    $rss .= "</channel>\n</rss>\n";
  }
  print $rss;
}
