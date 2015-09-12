# Copyright (C) 2004, 2006, 2008, 2014  Alex Schroeder <alex@gnu.org>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

use XML::Atom;
use XML::Atom::Entry;
use XML::Atom::Link;
use XML::Atom::Person;

AddModuleDescription('atom.pl', 'Atom Extension');

our ($q, %Page, %Action, $CommentsPrefix, $ScriptName, $SiteName, $MaxPost, $UseDiff, $DeletedPage, @MyInitVariables, @MyMacros, $FS, $BannedContent, $RssStyleSheet, $RssRights, $RssLicense, $RssImageUrl, $RssExclude, $RCName, @UploadTypes, $UploadAllowed, $UsePathInfo, $SiteDescription, $LastUpdate, $InterWikiMoniker);

push(@MyInitVariables, \&AtomInit);

sub AtomInit {
  SetParam('action', 'atom') if $q->path_info =~ m|/atom\b|;
}

$Action{atom} = \&DoAtom;

sub DoAtom {
  my $id = shift;
  if ($q->request_method eq 'POST') {
    DoAtomSave('POST');
  } elsif (GetParam('info', 0) or $id eq 'info') {
    DoAtomIntrospection();
  } elsif (GetParam('wiki', 0)) {
    if ($q->request_method eq 'PUT') {
      DoAtomSave('PUT', $id);
    } elsif ($q->request_method eq 'DELETE') {
      DoAtomDelete($id);
    } else {
      DoAtomGet($id);
    }
  } else {
    SetParam($id, 1); # /atom/full should work, too
    print GetHttpHeader('application/atom+xml');
    print GetRcAtom();
  }
}

# from http://www.ietf.org/internet-drafts/draft-ietf-atompub-protocol-10.txt
sub DoAtomIntrospection {
  print GetHttpHeader('application/atomserv+xml');
  my @types = ('entry', );
  push(@types, @UploadTypes) if $UploadAllowed;
  my $upload = '<accept>' . join(', ', @types) . '</accept>';
  print <<EOT;
<?xml version="1.0" encoding='UTF-8'?>
<service xmlns="http://purl.org/atom/app#">
<workspace title="Wiki" >
<collection title="$SiteName" href="$ScriptName/atom/wiki">
$upload
</collection>
</workspace>
</service>
EOT
}

sub AtomTag {
  my ($tag, $value) = @_;
  return '' unless $value;
  return "<$tag>$value</$tag>\n";
}

# based on GetRcRss
sub GetRcAtom {
  my $url = QuoteHtml($ScriptName) . ($UsePathInfo ? "/" : "?");
  my $diffPrefix = QuoteHtml($ScriptName) . "?action=browse;diff=1;id=";
  my $historyPrefix = QuoteHtml($ScriptName) . "?action=history;id=";
  my $limit = GetParam("rsslimit", 15); # Only take the first 15 entries
  my $count = 0;
  my $feed = qq{<?xml version="1.0" encoding="UTF-8"?>\n};
  if ($RssStyleSheet =~ /\.(xslt?|xml)$/) {
    $feed .= qq{<?xml-stylesheet type="text/xml" href="$RssStyleSheet" ?>\n};
  } elsif ($RssStyleSheet) {
    $feed .= qq{<?xml-stylesheet type="text/css" href="$RssStyleSheet" ?>\n};
  }
  $feed .= qq{<feed xmlns="http://www.w3.org/2005/Atom"
     xmlns:wiki="http://purl.org/rss/1.0/modules/wiki/"
     xmlns:cc="http://backend.userland.com/creativeCommonsRssModule">\n};
  $feed .= AtomTag('title', QuoteHtml($SiteName) . ': ' . GetParam('title', QuoteHtml($RCName)));
  $feed .= qq{<link href="} . $url . UrlEncode($RCName) .  qq{"/>\n};
  $feed .= AtomTag('subtitle', QuoteHtml($SiteDescription));
  $feed .= AtomTag('updated', TimeToW3($LastUpdate));
  $feed .= qq{<generator uri="http://www.oddmuse.org/">Oddmuse</generator>\n};
  $feed .= AtomTag('rights', $RssRights) if $RssRights;
  $feed .= join('', map { AtomTag('<cc:license>', QuoteHtml($_)) }
		(ref $RssLicense eq 'ARRAY' ? @$RssLicense : $RssLicense));
  $feed .= AtomTag('wiki:interwiki', $InterWikiMoniker) if $InterWikiMoniker;
  $feed .= AtomTag('logo', $RssImageUrl) if $RssImageUrl;
  my %excluded = ();
  if (GetParam("exclude", 1)) {
    foreach (split(/\n/, GetPageContent($RssExclude))) {
      if (/^ ([^ ]+)[ \t]*$/) { # only read lines with one word after one space
	$excluded{$1} = 1;
      }
    }
  }
  # Now call GetRc with some blocks of code as parameters:
  ProcessRcLines(sub {}, sub {
      my ($pagename, $timestamp, $host, $username, $summary, $minor, $revision, $languages, $cluster) = @_;
      return if $excluded{$pagename} or ($limit ne 'all' and $count++ >= $limit);
      my $name = NormalToFree($pagename);
      $username = QuoteHtml($username);
      $username = $host unless $username;
      $feed .= "\n<entry>\n";
      $feed .= AtomTag('title', QuoteHtml($name));
      $feed .= qq{<link rel="alternate" href="}
        . (GetParam('all', $cluster)
    	? QuoteHtml($ScriptName) . "?" . GetPageParameters('browse', $pagename, $revision, $cluster)
    	: $url . UrlEncode($pagename)) . qq{"/>\n};
      $feed .= AtomLink("$ScriptName/atom/wiki/$pagename");
      $feed .= AtomTag('summary', QuoteHtml($summary));
      $feed .= qq{<content type="xhtml">\n<div xmlns="http://www.w3.org/1999/xhtml">\n}
        . PageHtml($pagename, 50*1024,$q->div(T('This page is too big to send over RSS.')))
          . qq{\n</div>\n</content>\n} if GetParam('full', 0);
      $feed .= AtomTag('published', TimeToW3($timestamp));
      $feed .= qq{<link rel="replies" href="} . $url . $CommentsPrefix . UrlEncode($pagename) . qq{"/>\n}
        if $CommentsPrefix and $pagename !~ /^$CommentsPrefix/;
      $feed .= AtomTag('author', substr(AtomTag('name', $username), 0, -1)); # strip one newline
      $feed .= AtomTag('wiki:username', $username);
      $feed .= AtomTag('wiki:status', 1 == $revision ? 'new' : 'updated');
      $feed .= AtomTag('wiki:importance', $minor ? 'minor' : 'major');
      $feed .= AtomTag('wiki:version', $revision);
      $feed .= AtomTag('wiki:history', $historyPrefix . UrlEncode($pagename));
      $feed .= AtomTag('wiki:diff', $diffPrefix . UrlEncode($pagename))
        if $UseDiff and GetParam('diffrclink', 1);
      $feed .= "</entry>\n";
    });
  $feed .= "</feed>\n";
  return $feed;
}

# Based on DoPost
sub DoAtomSave {
  my ($type, $oldid) = @_;
  my $entry = AtomEntry($type);
  my $title = $entry->title();
  my $author = $entry->author();
  SetParam('username', $author->name) if $author; # Used in Save()
  my $id = FreeToNormal($title);
  UserCanEditOrDie($id);
  $oldid = $id unless $oldid;
  ValidIdOrDie($oldid);
  my $summary = $entry->summary();
  # Lock before getting old page to prevent races
  RequestLockOrError();		# fatal
  OpenPage($oldid);
  my $old = $Page{text};
  # FIXME: Assuming XML Type content, because that's what
  # XML::Atom::Client does. Sent mail to the maintainers, asking for
  # clarification.
  $_ = $entry->content()->{elem}->getChildrenByTagName('div')->[0]->textContent;
  foreach my $macro (@MyMacros) {
    &$macro;
  }
  my $string = $_;
  # Massage the string
  $string =~ s/\r//g;
  $string .= "\n"  if ($string !~ /\n$/);
  $string =~ s/$FS//g;
  # Banned Content
  if (not UserIsEditor()) {
    my $rule = BannedContent($string) || BannedContent($summary);
    ReportError(T('Edit Denied'), '403 FORBIDDEN', undef,
		$q->p(T('The page contains banned text.')),
		$q->p(T('Contact the wiki administrator for more information.')),
		$q->p($rule . ' ' . Ts('See %s for more information.', GetPageLink($BannedContent))))
      if $rule;
  }
  my $oldrev = $Page{revision};
  if ($old eq $string and $oldid eq $id) {
    ReportError(T('No changes to be saved.'), '200 OK'); # an update without consequence
  } elsif ($oldrev == 0 and $string eq "\n") {
    ReportError(T('No changes to be saved.'), '400 BAD REQUEST'); # don't fake page creation because of webdav
  } else {
    # My providing a different title, the entry is automatically renamed
    if ($oldrev > 0 and $oldid ne $id) {
      Save($oldid, $DeletedPage, Ts('Renamed to %s', NormalToFree($id)));
      OpenPage($id);
    }
    # Now save the new page
    Save($id, $string, $summary);
    ReleaseLock();
    # Do we reply 200 or 201 depending on the request, or depending on
    # the action taken?
    my $url = "$ScriptName/atom/wiki/$id";
    if ($type eq 'POST') { # instead of $oldrev == 0
      print $q->header(-status=>'201 CREATED', -location=>$url);
    } else {
      print $q->header(-status=>'200 OK');
    }
    $entry->title(NormalToFree($id));
    $entry->add_link(AtomLink($url));
    print '<?xml version="1.0" encoding="utf-8"?>', "\n";
    print $entry->{elem}->toString;
  }
}

sub DoAtomGet {
  print $q->header(-status=>'304 NOT MODIFIED') and return if FileFresh(); # return value is ignored
  print GetHttpHeader('application/atomserv+xml');
  print '<?xml version="1.0" encoding="utf-8"?>', "\n";
  my $id = GetId();
  OpenPage($id);
  my $entry = XML::Atom::Entry->new;
  my $person = XML::Atom::Person->new;
  $person->name($Page{username});
  $entry->author($person) if $Page{username};
  $entry->title(NormalToFree($id));
  $entry->summary($Page{summary});
  $entry->content($Page{text});
  $entry->add_link(AtomLink("$ScriptName/atom/wiki/$id"));
  print $entry->{elem}->toString;
}

sub AtomEntry {
  my $type = shift || 'POST';
  my $data = $q->param($type . 'DATA'); # PUTDATA or POSTDATA
  my $entry = XML::Atom::Entry->new(\$data);
  return $entry;
}

sub AtomLink {
  my $url = shift;
  my $link = XML::Atom::Link->new;
  $link->href($url);
  $link->rel('edit');
  return $link;
}
