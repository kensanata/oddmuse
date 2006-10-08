# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: referrer-rss.pl,v 1.1 2006/10/08 15:59:54 as Exp $</p>';

$Action{"refer-rss"} = \&DoRefererRss;

sub DoRefererRss {
  my $url = QuoteHtml($ScriptName);
  my $date = TimeToRFC822($LastUpdate);
  my $limit = GetParam("rsslimit", 15); # Only take the first 15 entries
  my $count = 0;
  print GetHttpHeader('application/xml');
  print qq{<?xml version="1.0" encoding="utf-8"?>};
  if ($RssStyleSheet =~ /\.(xslt?|xml)$/) {
    print qq{<?xml-stylesheet type="text/xml" href="$RssStyleSheet" ?>};
  } elsif ($RssStyleSheet) {
    print qq{<?xml-stylesheet type="text/css" href="$RssStyleSheet" ?>};
  }
  print qq{<rss version="2.0">
<channel>
<docs>http://blogs.law.harvard.edu/tech/rss</docs>
};
  print "<title>" . QuoteHtml($SiteName) . " " . T("Referrers") . "</title>\n";
  print "<link>$url?action=refer</link>\n";
  print "<description>" . QuoteHtml($SiteDescription) . "</description>\n";
  print "<pubDate>" . $date. "</pubDate>\n";
  print "<lastBuildDate>" . $date . "</lastBuildDate>\n";
  print "<generator>Oddmuse</generator>\n";
  if ($RssImageUrl) {
    print "<image>\n";
    print "<url>" . $RssImageUrl . "</url>\n";
    print "<title>" . QuoteHtml($SiteName) . "</title>\n";
    print "<link>" . $url . "</link>\n";
    print "</image>\n";
  }
  my %when = ();
  my %where = ();
  for my $id (AllPagesList()) {
    ReadReferers($id);
    # $Referers{url} = time for each $id
    foreach my $url (keys %Referers) {
      # $where{$url} = HomePage, AlexSchroeder, What_Is_A_Wiki
      push(@{$where{$url}}, $id);
      # $when{$url} = last time
      $when{$url} = $Referers{$url}
	if $when{$url} < $Referers{$url};
    }
  }
  foreach my $url (sort { $when{$b} <=> $when{$a} } keys %when) {
    print "\n<item>\n";
    print "<title>" . QuoteHtml($url) . "</title>\n";
    print "<link>" . QuoteHtml($url) . "</link>\n";
    print "<description>" . join(", ", map {
      QuoteHtml(GetPageLink($_));
    } @{$where{$url}}) . ", " . CalcDay($when{$url}) . " " . CalcTime($when{$url}) . "</description>\n";
    print "<pubDate>" . $date . "</pubDate>\n";
    print "</item>\n";
  }
  print "</channel>\n</rss>\n";
}
