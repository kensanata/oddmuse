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

$ModulesDescription .= '<p>$Id: atom.pl,v 1.8 2004/10/10 15:14:44 as Exp $</p>';

$Action{atom} = \&DoAtom;

sub DoAtom {
  print GetHttpHeader('application/xml');
  DoRc(\&GetRcAtom);
}

sub AtomTime {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf( "%4d-%02d-%02dT%02d:%02dZ",
		  $year+1900, $mon+1, $mday, $hour, $min);
}

sub AtomTag {
  my ($tag, $value, $escaped) = @_;
  return '' unless $value;
  if ($escaped) {
    return "<$tag mode=\"escaped\">$value</$tag>\n";
  } else {
    return "<$tag>$value</$tag>\n";
  }
}

sub GetRcAtom {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  # from http://www.ietf.org/internet-drafts/draft-ietf-atompub-format-01.txt
  print <<EOT;
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<?xml-stylesheet href="http://www.blogger.com/styles/atom.css" type="text/css"?>
<feed version="0.3" xmlns="http://purl.org/atom/ns#">
EOT
  my $title = $SiteName;
  my $link = $ScriptName;
  print AtomTag('title', QuoteHtml($title), 1);
  print "<link href=\"$link\" rel=\"alternate\" title=\"$title\" type=\"text/html\"/>\n";
  print AtomTag('author', AtomTag('name', $RssPublisher)) if $RssPublisher;
  print AtomTag('contributor', AtomTag('name', $RssContributor)) if $RssContributor;
  print "<generator url=\"http://www.oddmuse.org/\">Oddmuse</generator>\n";
  print AtomTag('copyright', QuoteHtml($RssRights), 1) if $RssRights;
  print <<EOT;
<info mode="xml" type="text/html">
<div xmlns="http://www.w3.org/1999/xhtml">This is an Atom formatted XML site feed. It is intended to be viewed in a Newsreader or syndicated to another site.</div>
</info>
EOT
  print AtomTag('modified', AtomTime($LastUpdate));
  my @excluded = ();
  if (GetParam('exclude', 1)) {
    foreach (split(/\n/, GetPageContent($RssExclude))) {
      if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
	push(@excluded, $1);
      }
    }
  }
  GetRc(sub {},
	sub {
	  my ($pagename, $timestamp, $host, $userName, $summary, $minor, $revision, $languages, $cluster) = @_;
	  return if grep(/$pagename/, @excluded);
	  my $title = FreeToNormal($pagename);
	  $title =~ s/_/ /g;
	  my $link = $ScriptName . ($UsePathInfo ? '/' : '?') . UrlEncode($pagename);
	  my $author = $userName;
	  $author = $host unless $author;
	  # output
	  print "<entry>\n",
	    AtomTag('title', QuoteHtml($title), 1),
	    "<link href=\"$link\" rel=\"alternate\" title=\"$title\" type=\"text/html\"/>\n",
	    "<id>$link</id>\n",
	    AtomTag('author', AtomTag('name', $author)),
	    AtomTag('modified', AtomTime($timestamp)),
	    AtomTag('issued', AtomTime($timestamp)),
	    AtomTag('summary', QuoteHtml($summary), 1);
	  if (GetParam('full', 0)) {
	    print '<content type="application/xhtml+xml">', "\n",
	      '<div xmlns="http://www.w3.org/1999/xhtml">', "\n";
	    OpenPage($pagename);
	    PrintPageDiff();
	    PrintPageHtml();
	    print "\n</div>\n</content>\n";
	  }
	  print "</entry>\n";
	},
	@_);
  print "</feed>\n";
  return '';
}
