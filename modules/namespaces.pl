# Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: namespaces.pl,v 1.51 2011/06/23 00:31:59 as Exp $</p>';

use vars qw($NamespacesMain $NamespacesSelf $NamespaceCurrent
	    $NamespaceRoot $NamespaceSlashing @NamespaceParameters
	    %Namespaces);

$NamespacesMain = 'Main'; # to get back to the main namespace
$NamespacesSelf = 'Self'; # for your own namespace
$NamespaceCurrent = '';   # the current namespace, if any
$NamespaceRoot = '';      # the original $ScriptName

=head2 Configuration

The option C<@NamespaceParameters> can be used by programmers to
indicate for which parameters the last element of path_info shall
count as a namespace. Consider these examples:

  http://example.org/wiki/Foo/Bar
  http://example.org/wiki/Foo?action=browse;id=Bar
  http://example.org/wiki/Foo?title=Bar;text=Baz
  http://example.org/wiki/Foo?search=bar

In all the listed cases, Foo is supposed to be the namespace.

In the following cases, however, we're interested in the page Foo and
not the namespace Foo.

  http://example.org/wiki/Foo?username=bar

=cut

@NamespaceParameters = ('action' => 1, 'search' => 1, 'title' => 1);

$NamespaceSlashing = 0;   # affects : decoding NamespaceRcLines

# try to do it before any other module starts meddling with the
# variables (eg. localnames.pl)
unshift(@MyInitVariables, \&NamespacesInitVariables);

sub NamespacesInitVariables {
  %Namespaces = ();
  # Do this before changing the $DataDir and $ScriptName
  if (!$Monolithic and $UsePathInfo) {
    $Namespaces{$NamespacesMain} = $ScriptName . '/';
    foreach my $name (glob("$DataDir/*")) {
      if (-d $name
	  and $name =~ m|/($InterSitePattern)$|
	  and $name ne $NamespacesMain
	  and $name ne $NamespacesSelf) {
	$Namespaces{$1} = $ScriptName . '/' . $1 . '/';
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
       and ($1 ne $NamespacesMain)
       and ($1 ne $NamespacesSelf)
       and ($2 or $q->keywords or NamespaceRequiredByParameter()))
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
    $ScriptName .= '/' . UrlEncode($NamespaceCurrent);
    $FullUrl .= '/' . UrlEncode($NamespaceCurrent);
    $StaticDir .= '/' . $NamespaceCurrent; # from static-copy.pl
    $StaticUrl .= UrlEncode($NamespaceCurrent) . '/'
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
  $Namespaces{$NamespacesSelf} = $ScriptName . '?';
  # reinitialize
  @IndexList = ();
  ReInit();
  # transfer list of sites
  foreach my $key (keys %Namespaces) {
    $InterSite{$key} = $Namespaces{$key} unless $InterSite{$key};
  }
  # remove the artificial ones
  delete $Namespaces{$NamespacesMain};
  delete $Namespaces{$NamespacesSelf};
}

sub NamespaceRequiredByParameter {
  foreach $key (@NamespaceParameters) {
    return 1 if $q->param($key);
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
links to be printed without copying the whole machinery. All the new
lines belong to a namespace. Prefix every pagename with the namespace
and a colon, ie. C<Alex:HomePage>. This provides
C<NewNamespaceScriptUrl> with the necessary information to build the
correct URL to link to.

=cut

*OldNamespaceGetRcLines = *GetRcLines;
*GetRcLines = *NewNamespaceGetRcLines;

sub NewNamespaceGetRcLines { # starttime, hash of seen pages to use as a second return value
  my $starttime = shift || GetParam('from', 0) ||
    $Now - GetParam('days', $RcDefault) * 86400; # 24*60*60
  my $filterOnly = GetParam('rcfilteronly', '');
  # these variables apply accross logfiles
  my %match = $filterOnly ? map { $_ => 1 } SearchTitleAndBody($filterOnly) : ();
  my %following = ();
  my @result = ();
  # Get the list of rc.log and oldrc.log files we need; rcoldfiles is
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
    # Get the namespaces from the intermap instead of parsing the
    # directory. This reduces the chances of getting different
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
  # Now each rcfile and the matching rcoldfile if required. When
  # opening a rcfile, compare the first timestamp with the
  # starttime. If any rcfile exists with no timestamp before the
  # starttime, we need to open its rcoldfile.
  foreach my $file (@rcfiles) {
    open(F, $file);
    my $line = <F>;
    my ($ts) = split(/$FS/o, $line); # the first timestamp in the regular rc file
    my @new;
    if (not $ts or $ts > $starttime) {	# we need to read the old rc file, too
      push(@new, GetRcLinesFor($rcoldfiles{$file}, $starttime,\%match, \%following));
    }
    push(@new, GetRcLinesFor($file, $starttime, \%match, \%following));
    # strip rollbacks in each namespace separately
    @new = StripRollbacks(@new);
    # prepend the namespace to both pagename and author
    my $ns = $namespaces{$file};
    if ($ns) {
      for (my $i = $#new; $i >= 0; $i--) {
	# page id
	$new[$i][1] = $ns . ':' . $new[$i][1];
	# username
	$new[$i][5] = $ns . ':' . $new[$i][5];
      }
    }
    push(@result, @new);
  }
  # We need to resort these lines...  <=> forces numerical comparison
  # which is just what we need here, as the timestamp is the first
  # part of the line.
  @result = sort { $a->[0] <=> $b->[0] } @result;
  # check the first timestamp in the default file, maybe read old log file
  # GetRcLinesFor is trying to save memory space, but some operations
  # can only happen once we have all the data.
  return LatestChanges(@result);
}

=head RSS feed

When retrieving the RSS feed with the parameter full=1, one would
expect the various items to contain the fully rendered HTML.
Unfortunately, this is not so, the reason being that OpenPage tries to
open a file for id C<Test:Foo> which does not exist. Now, just
fiddling with OpenPage will not work, because when rendering a page
within a particular namespace, we need a separate C<%IndexHash> to
figure out which links will actually point to existing pages and which
will not. In fact, we need something alike the code for
C<NamespacesInitVariables> to run. To do this elegantly would require
us to create some sort of context, and cache it, and restore the
default when we're done. All of this would be complicated and brittle.
Until then, the parameter full=1 just is not supported.

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

=head2 Printing Links

We also need to override C<ScriptUrl>. This is done by
C<NewNamespaceScriptUrl>. This is where the slash in the pagename is
used to build a new URL pointing to the appropriate page in the
appropriate namespace.

In addition to that, this function makes sure that backlinks to edit
pages with redirections result in an appropriate URL.

This is used for ordinary page viewing and RecentChanges.

=cut

*OldNamespaceScriptUrl = *ScriptUrl;
*ScriptUrl = *NewNamespaceScriptUrl;

sub NewNamespaceScriptUrl {
  my ($action, @rest) = @_;
  local $ScriptName = $ScriptName;
  if ($action =~ /^($UrlProtocols)\%3a/) { # URL-encoded URL
    # do nothing (why do we need this?)
  } elsif ($action =~ m!(.*?)([^/?&;=]+)%3a(.*)!) {
    # $2 is supposed to match the $InterSitePattern, but it might be
    # UrlEncoded in Main:RecentChanges. If $2 contains Umlauts, for
    # example, the encoded $2 will no longer match $InterSitePattern.
    # We have a likely candidate -- now perform an additional test.
    my ($s1, $s2, $s3) = ($1, $2, $3);
    my $s = UrlDecode($s2);
    if ($s =~ /^$InterSitePattern$/) {
      if ("$s2:$s3" eq GetParam('oldid', '')) {
	if ($s2 eq $NamespacesMain) {
	  $ScriptName = $NamespaceRoot;
	} else {
	  $ScriptName = $NamespaceRoot . '/' . $s2;
	}
      } else {
	$ScriptName .= '/' . $s2;
      }
      $action = $s1 . $s3;
    }
  }
  return OldNamespaceScriptUrl($action, @rest);
}

=head2 Invalid Pagenames

Since the adding of a namespace and colon makes all these new
pagenames invalid, C<NamespaceValidId> is overridden with an empty
function called C<NamespaceValidId> while C<NewNamespaceDoRc> is
running. This is important so that author links are printed.

=cut

*OldNamespaceGetAuthorLink = *GetAuthorLink;
*GetAuthorLink = *NewNamespaceGetAuthorLink;

sub NewNamespaceGetAuthorLink {
  local *OldNamespaceValidId = *ValidId;
  local *ValidId = *NewNamespaceValidId;
  # local $NamespaceSlashing = 1;
  return OldNamespaceGetAuthorLink(@_);
}

sub NewNamespaceValidId {
  local $FreeLinkPattern = "($InterSitePattern:)?$FreeLinkPattern";
  local $LinkPattern = "($InterSitePattern:)?$LinkPattern";
  return OldNamespaceValidId(@_);
}

=head2 Redirection User Interface

When redirection form page A to B, you will never see the link "Edit
this page" at the bottom of page A. Therefore Oddmuse adds a link at
the top of page B (if you arrived there via a redirection), linking to
the edit page for A. C<NewNamespaceBrowsePage> has the necessary code
to make this work for redirections between namespaces. This involves
passing namespace and pagename via the C<oldid> parameter to the next
script invokation, where C<ScriptUrl> will be used to create the
appropriate link. This is where C<NewNamespaceScriptUrl> comes into
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

=head2 List Namespaces

The namespaces action will link all known namespaces.

=cut

$Action{namespaces} = \&DoNamespacesList;

sub DoNamespacesList {
  if (GetParam('raw', 0)) {
    print GetHttpHeader('text/plain');
    print join("\n", keys %Namespaces), "\n";
  } else {
    print GetHeader('', T('Namespaces')),
      $q->start_div({-class=>'content namespaces'}),
	GetFormStart(undef, 'get'), GetHiddenValue('action', 'browse'),
	  GetHiddenValue('id', $HomePage);
    my $new = $q->textfield('ns') . ' ' . $q->submit('donamespace', T('Go!'));
    print $q->ul($q->li([map { $q->a({-href => $Namespaces{$_} . $HomePage},
				     $_); } keys %Namespaces]), $q->li($new));
    print $q->end_form() . $q->end_div();
    PrintFooter();
  }
}

push(@MyAdminCode, \&NamespacesMenu);

sub NamespacesMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=namespaces',
		  T('Namespaces'),
		  'namespaces'));
}
