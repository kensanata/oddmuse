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

$ModulesDescription .= '<p>$Id: atom.pl,v 1.4 2004/08/11 10:55:20 as Exp $</p>';

$Action{atom} = \&DoAtom;

sub DoAtom {
  print GetHttpHeader('application/xml');
  DoRc(\&GetRcAtom);
}

sub AtomTime {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf( "%4d-%02d-%02dT%02d:%02d:%02d+00:00 UTC",
		  $year+1900, $mon+1, $mday, $hour, $min, $sec);
}

sub AtomTag {
  my ($tag, $value) = @_;
  return "<$tag>$value</$tag>\n" if $value;
}

sub GetRcAtom {
  # from http://www.ietf.org/internet-drafts/draft-ietf-atompub-format-01.txt
  print <<EOT;
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<?xml-stylesheet href="http://www.blogger.com/styles/atom.css" type="text/css"?>
<feed version="0.3" xmlns="http://purl.org/atom/ns#">
EOT
  my $title = $SiteName;
  my $link = $ScriptName;
  print AtomTag('title', $title);
  print "<link href=\"$link\" rel=\"alternate\" title=\"$title\" type=\"text/html\" />\n";
  print AtomTag('author', "<person><name>$RssPublisher</name></person>")
    if $RssPublisher;
  print AtomTag('contributor', "<person><name>$RssContributor</name></person>")
    if $RssContributor;
  print "<generator url=\"http://www.oddmuse.org/\">Oddmuse</generator>\n";
  print AtomTag('copyright', $RssRights)
    if $RssRights;
  print <<EOT;
<info mode="xml" type="text/html">
<div xmlns="http://www.w3.org/1999/xhtml">This is an Atom formatted XML site feed. It is intended to be viewed in a Newsreader or syndicated to another site.</div>
</info>
EOT
  print AtomTag('modified', AtomTime($LastUpdate));
  GetRc(sub {},
	sub {
	  my ($pagename, $timestamp, $host, $userName, $summary, $minor, $revision, $languages, $cluster) = @_;
	  my $title = FreeToNormal($pagename);
	  $title =~ s/_/ /g;
	  my $link = $ScriptName . ($UsePathInfo ? '/' : '?') . $pagename;
	  my $author = $userName;
	  $author = $host unless $author;
	  # output
	  print "<entry>\n",
	    AtomTag('title', $title),
	    "<link href=\"$link\" rel=\"alternate\" title=\"$title\" type=\"text/html\" />\n",
	    AtomTag('author', "<person><name>$author</name></person>"),
	    AtomTag('modified', AtomTime($timestamp)),
	    AtomTag('issued', AtomTime($timestamp)),
	    AtomTag('summary', $summary),
	    "<content type=\"text/html\" mode=\"escaped\">\n",
	    AtomPage($pagename),
	    "\n</content>\n",
	    "</entry>\n";
	},
	@_);
  print "</feed>\n";
  return '';
}

sub AtomPage {
  my $id = shift;
  my $result = '';
  local *STDOUT;
  open(STDOUT, '>', \$result) or die "Can't open memory file: $!";
  OpenPage($id);
  if ($Page{blocks} && $Page{flags}) {
    PrintCache();
  } else {
    PrintWikiToHTML($Page{text}, 1); # save cache, current revision, no main lock
  }
  return QuoteHtml($result);
}
