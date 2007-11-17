# Copyright (C) 2004, 2005, 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

=head1 Namespaces Extension

This module allows you to create namespaces in Oddmuse. The effect is
that C<http://localhost/cgi-bin/wiki/Claudia/HomePage> and
C<http://localhost/cgi-bin/wiki/Alex/HomePage> are two different
pages. The first URL points to the C<HomePage> in the C<Claudia>
namespace, the second URL points to the C<HomePage> in the C<Alex>
namespace. Both namespaces have their own list of pages and their own
list of changes, and so on.

C<http://localhost/cgi-bin/wiki/HomePage> points to the C<HomePage> in
the main namespace. It is usually named C<Main>. The name can be
changed using the C<$NamespacesMain> option.

URL abbreviations will automatically be created for you. Thus, you can
link to the various pages using C<Claudia:HomePage>, C<Alex:HomePage>,
and C<Main:HomePage>. An additional abbreviation is also created
automatically: C<Self>. You can use it to link to actions such as
C<Self:action=index>. The name of this self-referring abbreviation can
be changed using the C<$NamespacesSelf> option.

=cut

$ModulesDescription .= '<p>$Id: namespaces.pl,v 1.37 2007/11/17 23:59:58 as Exp $</p>';

use vars qw($NamespacesMain $NamespacesSelf $NamespaceCurrent
	    $NamespaceRoot $NamespaceSlashing);

$NamespacesMain = 'Main'; # to get back to the main namespace
$NamespacesSelf = 'Self'; # for your own namespace
$NamespaceCurrent = '';   # the current namespace, if any
$NamespaceRoot = '';      # the original $ScriptName

$NamespaceSlashing = 0;   # affects : decoding NamespaceRcLines

# try to do it before any other module starts meddling with the
# variables (eg. localnames.pl)
unshift(@MyInitVariables, \&NamespacesInitVariables);

sub NamespacesInitVariables {
  my %site = ();
  # Do this before changing the $DataDir and $ScriptName
  if (!$Monolithic and $UsePathInfo) {
    $site{$NamespacesMain} = $ScriptName . '/';
    foreach my $name (glob("$DataDir/*")) {
      if (-d $name
	    and $name =~ m|/($InterSitePattern)$|
	    and $name ne $NamespacesMain
	  and $name ne $NamespacesSelf) {
	$site{$1} = $ScriptName . '/' . $1 . '/';
      }
    }
  }
  $NamespaceRoot = $ScriptName; # $ScriptName may be changed below
  $NamespaceCurrent = '';
  my $ns = GetParam('ns', '');
  ReportError(Ts('%s is not a legal name for a namespace', $ns))
    if $ns and $ns !~ m/^($InterSitePattern)$/;
  if (($UsePathInfo
       # make sure ordinary page names are not matched!
       and $q->path_info() =~ m|^/($InterSitePattern)(/.*)?|
       and ($2 or $q->param or $q->keywords)
       and ($1 ne $NamespacesMain)
       and ($1 ne $NamespacesSelf))
      or
      ($ns =~ m/^($InterSitePattern)$/
       and ($1 ne $NamespacesMain)
       and ($1 ne $NamespacesSelf))) {
    $NamespaceCurrent = $1;
    # Change some stuff from the original InitVariables call:
    $SiteName   .= ' ' . $NamespaceCurrent;
    $InterWikiMoniker = $NamespaceCurrent;
    $DataDir    .= '/' . $NamespaceCurrent;
    $PageDir     = "$DataDir/page";
    $KeepDir     = "$DataDir/keep";
    $RefererDir  = "$DataDir/referer";
    $TempDir     = "$DataDir/temp";
    $LockDir     = "$TempDir/lock";
    $NoEditFile  = "$DataDir/noedit";
    $RcFile = "$DataDir/rc.log";
    $RcOldFile   = "$DataDir/oldrc.log";
    $IndexFile   = "$DataDir/pageidx";
    $VisitorFile = "$DataDir/visitors.log";
    $PermanentAnchorsFile = "$DataDir/permanentanchors";
    # $ConfigFile -- shared
    # $ModuleDir -- shared
    # $NearDir -- shared
    $ScriptName .= '/' . $NamespaceCurrent;
    $FullUrl .= '/' . $NamespaceCurrent;
    $StaticDir .= '/' . $NamespaceCurrent; # from static-copy.pl
    $StaticUrl .= $NamespaceCurrent . '/'
      if substr($StaticUrl,-1) eq '/'; # from static-copy.pl
    $WikiDescription .= "<p>Current namespace: $NamespaceCurrent</p>";
    # override LastUpdate
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)
      = stat($IndexFile);
    $LastUpdate = $mtime;
    CreateDir($DataDir); # Create directory if it doesn't exist
    ReportError(Ts('Could not create %s', $DataDir) . ": $!", '500 INTERNAL SERVER ERROR')
      unless -d $DataDir;
  }
  $site{$NamespacesSelf} = $ScriptName . '?';
  # reinitialize
  @IndexList = ();
  ReInit();
  # transfer list of sites
  foreach my $key (keys %site) {
    $InterSite{$key} = $site{$key} unless $InterSite{$key};
  }
}

=head2 RecentChanges

RecentChanges in the main namespace will list changes to all the
namespaces. In order to limit it to the changes in the main namespace
itself, you need to use the local=1 parameter. Example:

C<http://localhost/cgi-bin/wiki?action=rc;local=1>

First we need to read all the C<rc.log> files from the various
namespace directories. If the first entry in the log file is not old
enough, we need to prepend the C<oldrc.log> file.

The tricky part is how to introduce the namespace prefixes to the
links to be printed without copying the whole machinery.

=cut

*OldNamespaceDoRc = *DoRc;
*DoRc = *NewNamespaceDoRc;

sub NewNamespaceDoRc { # Copy of DoRc
  my $GetRC = shift;
  my $showHTML = $GetRC eq \&GetRcHtml; # optimized for HTML
  my $starttime = 0;
  if (GetParam('from', 0)) {
    $starttime = GetParam('from', 0);
  } else {
    $starttime = $Now - GetParam('days', $RcDefault) * 86400; # 24*60*60
  }
  # get the list of rc.log and oldrc.log files we need.  rcoldfiles is
  # a mapping from rcfiles to rcoldfiles.
  my @rcfiles = ();
  my %rcoldfiles = ();
  my %namespaces = ();
  if ($NamespaceCurrent or GetParam('local', 0)) {
    push(@rcfiles, $RcFile);
    $rcoldfiles{$RcFile} = $RcOldFile;
  } else {
    push(@rcfiles, $RcFile);
    $rcoldfiles{$RcFile} = $RcOldFile;
    # get the namespaces from the intermap instead of parsing the
    # directory.  this reduces the chances of getting different
    # results.
    foreach my $site (keys %InterSite) {
      if ($InterSite{$site} =~ m|^$ScriptName/([^/]*)|) {
	my $ns = $1 or next;
	my $file = "$DataDir/$ns/rc.log";
	push(@rcfiles, $file);
	$namespaces{$file} = $ns;
	$rcoldfiles{$file} = "$DataDir/$ns/oldrc.log";
      }
    }
  }
  # start printing header
  RcHeader() if $showHTML;
  # now need them line by line, trying to conserve ram instead of
  # optimizing for speed (and slurping them all in).  when opening a
  # rcfile, compare the first timestamp with the starttime.  if any
  # rcfile exists with no timestamp before the starttime, we need to
  # open its rcoldfile.
  @lines = ();
  foreach my $file (@rcfiles) {
    my ($ts, @new) = NamespaceRcLines($file, $starttime, $namespaces{$file});
    push(@lines, @new);
    if (not $ts or $starttime <= $ts) {
      ($ts, @new) = NamespaceRcLines($rcoldfiles{$file}, $starttime, $namespaces{$file});
      push(@lines, @new);
    }
  }
  # We need to resort these lines...  <=> forces numerical comparison
  # which is just what we need here, as the timestamp is the first
  # part of the line.
  @lines = sort { $a <=> $b } @lines;
  # end, printing
  local *ValidId = *NamespaceValidId;
  local $NamespaceSlashing = 1;
  if (not @lines and $showHTML) {
    print $q->p($q->strong(Ts('No updates since %s', TimeToText($starttime))));
  } else {
    print &$GetRC(@lines);
  }
  print GetFilterForm() if $showHTML;
}

=head2 Adding the namespace to pagenames

C<NamespaceRcLines> is a copy of C<GetRcLines> with all the tricky
details. And in addition to all that, it prefixes every pagename with
the namespace and a colon, ie. C<Alex:HomePage>. This provides
C<NewNamespaceScriptLink> with the necessary information to build the
correct URL to link to.

=cut

sub NamespaceRcLines {
  my ($file, $starttime, $ns) = @_;
  open(F,$file) or return (0, ());
  my $line = <F> or return (0, ());
  chomp($line);
  my ($ts, $pagename, $minor, $summary, $host, $username, $rest)
    = split(/$FS/, $line);
  my $first = $ts;
  my @result = ();
  while ($ts) {
    # Add the namespace to the pagename and username -- we need this
    # information in ScriptLink!
    push(@result, join($FS, $ts, ($ns ? ($ns . ':' . $pagename) : $pagename),
		       $minor, $summary, $host,
                       ($ns && $username ? ($ns . ':' . $username) : $username),
		       $rest))
      if $ts >= $starttime;
    $line = <F> or last;
    chomp($line);
    ($ts, $pagename, $minor, $summary, $host, $username, $rest)
      = split(/$FS/, $line);
  }
  my $rollbacks = (GetParam('all', 0) or GetParam('rollback', 0));
  return ($first, StripRollbacks($rollbacks, @result));
}

=head2 Encoding pagenames

C<NewNamespaceUrlEncode> uses C<UrlEncode> to encode pagenames, with
one exception. If the local variable C<$NamespaceSlashing> has been
set, the first encoded slash is converted back into an ordinary slash.
This should preserve the slash added between namespace and pagename.

=cut

*OldNamespaceUrlEncode = *UrlEncode;
*UrlEncode = *NewNamespaceUrlEncode;

sub NewNamespaceUrlEncode {
  my $result = OldNamespaceUrlEncode(@_);
  $result =~ s/\%2f/\// if $NamespaceSlashing; # just one should be enough
  return $result;
}

*OldNamespaceScriptLink = *ScriptLink;
*ScriptLink = *NewNamespaceScriptLink;

=head2 Printing Links

We also need to override C<ScriptLink>. This is done by
C<NewNamespaceScriptLink>. This is where the slash in the pagename is
used to build a new URL pointing to the appropriate page in the
appropriate namespace.

In addition to that, this function makes sure that backlinks to edit
pages with redirections result in an appropriate URL.

=cut

sub NewNamespaceScriptLink {
  my ($action, @rest) = @_;
  local $ScriptName = $ScriptName;
  if ($action =~ /^($UrlProtocols)\%3a/) { # URL-encoded URL
    # do nothing
  } elsif ($action =~ /(.*?)\b($InterSitePattern)%3a(.*)/) {
    if ("$2:$3" eq GetParam('oldid', '')) {
      if ($2 eq $NamespacesMain) {
	$ScriptName = $NamespaceRoot;
      } else {
	$ScriptName = $NamespaceRoot . '/' . $2;
      }
    } else {
      $ScriptName .= '/' . $2;
    }
    $action = $1 . $3;
  }
  return OldNamespaceScriptLink($action, @rest);
}

=head2 Invalid Pagenames

Since the adding of a namespace and colon makes all these new
pagenames invalid, C<NamespaceValidId> is overridden with an empty
function called C<NamespaceValidId> while C<NewNamespaceDoRc> is
running.

=cut

sub NamespaceValidId {}

=head2 Redirection User Interface

When redirection form page A to B, you will never see the link "Edit
this page" at the bottom of page A. Therefore Oddmuse adds a link at
the top of page B (if you arrived there via a redirection), linking to
the edit page for A. C<NewNamespaceBrowsePage> has the necessary code
to make this work for redirections between namespaces. This involves
passing namespace and pagename via the C<oldid> parameter to the next
script invokation, where C<ScriptLink> will be used to create the
appropriate link. This is where C<NewNamespaceScriptLink> comes into
play.

=cut

*OldNamespaceBrowsePage = *BrowsePage;
*BrowsePage = *NewNamespaceBrowsePage;

sub NewNamespaceBrowsePage {
  #REDIRECT into different namespaces
  my ($id, $raw, $comment, $status) = @_;
  OpenPage($id);
  my ($text, $revision) = GetTextRevision(GetParam('revision', ''));
  my $oldId = GetParam('oldid', '');
  if (not $oldId and not $revision and (substr($text, 0, 10) eq '#REDIRECT ')
      and (($WikiLinks and $text =~ /^\#REDIRECT\s+$InterLinkPattern/)
	   or ($FreeLinks and $text =~ /^\#REDIRECT\s+\[\[$FreeInterLinkPattern\]\]/))) {
    my ($ns, $page) = map { UrlEncode($_) } split(/:/, FreeToNormal($1));
    $oldid = ($NamespaceCurrent || $NamespacesMain) . ':' . $id;
    local $ScriptName = $NamespaceRoot || $ScriptName;
    print GetRedirectPage("action=browse;ns=$ns;oldid=$oldid;id=$page", $id);
  } else {
    return OldNamespaceBrowsePage(@_);
  }
}
