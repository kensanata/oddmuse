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

$ModulesDescription .= '<p>$Id: namespaces.pl,v 1.32 2007/06/02 19:19:24 as Exp $</p>';

use vars qw($NamespacesMain $NamespacesSelf $NamespaceCurrent $NamespaceRoot $NamespaceSlashing);

$NamespacesMain = 'Main'; # to get back to the main namespace
$NamespacesSelf = 'Self'; # for your own namespace
$NamespaceCurrent = '';   # will be automatically set to the current namespace, if any
$NamespaceRoot = '';      # will be automatically set to the original $ScriptName

$NamespaceSlashing = 0;   # When set, UrlEncode will immediately decode the / added by NamespaceRcLines

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
    $NamespaceRoot = $ScriptName;
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

sub NamespaceRcLines {
  my ($file, $starttime, $ns) = @_;
  open(F,$file) or return (0, ());
  my $line = <F> or return (0, ());
  chomp($line);
  my ($ts, $pagename, $minor, $summary, $host, $username, $rest) = split(/$FS/, $line);
  my $first = $ts;
  my @result = ();
  while ($ts) {
    # here we add the namespace to the pagename and username, but this
    # will never work, we need to fix this later in ScriptLink!
    push(@result, join($FS, $ts, ($ns ? ($ns . '/' . $pagename) : $pagename), $minor, $summary, $host,
                       ($ns && $username ? ($ns . '/' . $username) : $username), $rest))
      if $ts >= $starttime;
    $line = <F> or last;
    chomp($line);
    ($ts, $pagename, $minor, $summary, $host, $username, $rest) = split(/$FS/, $line);
  }
  if (GetParam('all', 0) or GetParam('rollback', 0)) { # include rollbacks
    # just strip the marker left by DoRollback()
    for (my $i = @result; $i; $i--) {
      my ($ts, $pagename) = split(/$FS/, $result[$i]);
      splice(@result, $i, 1) if $pagename eq '[[rollback]]';
    }
  } else {
    my ($target, $end);
    for (my $i = @result; $i; $i--) {
      my ($ts, $pagename, $rest) = split(/$FS/, $result[$i]);
      splice(@result, $i + 1, $end - $i), $target = 0  if $ts <= $target;
      $target = $rest, $end = $i
        if $pagename eq ($ns ? ($ns . '/') : '') . '[[rollback]]'
          and (not $target or $rest < $target); # marker
    }
  }
  return ($first, @result);
}

*OldNamespaceUrlEncode = *UrlEncode;
*UrlEncode = *NewNamespaceUrlEncode;

sub NewNamespaceUrlEncode {
  my $result = OldNamespaceUrlEncode(@_);
  $result =~ s/\%2f/\// if $NamespaceSlashing; # just one should be enough
  return $result;
}

*OldNamespaceScriptLink = *ScriptLink;
*ScriptLink = *NewNamespaceScriptLink;

sub NewNamespaceScriptLink {
  my ($action, @rest) = @_;
  local $ScriptName = $ScriptName;
  if ($action =~ /^($UrlProtocols)\%3a/) { # URL-encoded URL
    # do nothing
  } elsif ($action =~ /(.*?)\b($InterSitePattern)\/(.*)/) {
    $ScriptName .= '/' . $2;
    $action = $1 . $3;
  }
  return OldNamespaceScriptLink($action, @rest);
}

sub NamespaceValidId {
  # don't do this test when printing recent changes because of the
  # spliced in slash -- return nothing.
}
