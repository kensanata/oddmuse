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

$ModulesDescription .= '<p>$Id: namespaces.pl,v 1.1 2004/04/05 00:37:55 as Exp $</p>';

*OldNamespacesInterInit = *InterInit;
*InterInit = *NewNamespacesInterInit;

my $MainScriptName;

sub NewNamespacesInterInit {
  if (not $InterSiteInit and !$Monolithic and $UsePathInfo) {
    $InterSite{Main} = $MainScriptName . '/';
    foreach my $name (glob("$DataDir/*")) {
      if (-d $name and $name =~ /($InterSitePattern)/) {
	$InterSite{$1} = $MainScriptName . '/' . $1 . '/';
      }
    }
  }
  OldNamespacesInterInit();
}

*OldNamespacesInitVariables = *InitVariables;
*InitVariables = *NewNamespacesInitVariables;

my $NamespacesInit = 0;

sub NewNamespacesInitVariables {
  OldNamespacesInitVariables();
  $MainScriptName = $ScriptName; # override in other namespaces!
  $Message .= '<p>Start</p>'; # FIXME
  if ($UsePathInfo and not $NamespacesInit
      # make sure ordinary page names are not matched!
      and $q->path_info() =~ m|^/($InterSitePattern)(/.*)?|) {
    my ($ns, $rest) = ($1, $2);
    $Message .= "<p>ns: $ns + $rest</p>"; # FIXME
    return if (not $rest and not $q->keywords and not $q->param);
    $NamespacesInit = 1;
    # Change some stuff from the original InitVariables call:
    $DataDir .= '/' . $ns;
    $PageDir     = "$DataDir/page";
    $KeepDir     = "$DataDir/keep";
    $RefererDir  = "$DataDir/referer";
    $TempDir     = "$DataDir/temp";
    $LockDir     = "$TempDir/lock";
    $NoEditFile  = "$DataDir/noedit";
    $RcFile	 = "$DataDir/rc.log";
    $RcOldFile   = "$DataDir/oldrc.log";
    $IndexFile   = "$DataDir/pageidx";
    $VisitorFile = "$DataDir/visitors.log";
    $PermanentAnchorsFile = "$DataDir/permanentanchors";
    # $ConfigFile -- shared
    # $ModuleDir -- shared
    # $NearDir -- shared
    $MainScriptName = $ScriptName;
    $ScriptName .= '/' . $ns;
    $FullUrl .= '/' . $ns;
    $Message .= "<p>ScriptName: $ScriptName</p>"; # FIXME
    $WikiDescription .= "<p>Current namespace: $ns</p>";
    $Message .= "<p>Current namespace: $ns</p>"; # FIXME
    # override LastUpdate
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)
      = stat($IndexFile);
    $LastUpdate = $mtime;
    CreateDir($DataDir); # Create directory if it doesn't exist
    ReportError(Ts('Could not create %s', $DataDir) . ": $!", '500 INTERNAL SERVER ERROR')
      unless -d $DataDir;
  }
}
