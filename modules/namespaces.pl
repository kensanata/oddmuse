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

$ModulesDescription .= '<p>$Id: namespaces.pl,v 1.3 2004/04/05 18:02:00 as Exp $</p>';

my $NamespacesInit = 0;
my $NamespacesMain = 'Main'; # to get back to the main namespace

*OldNamespacesInitVariables = *InitVariables;
*InitVariables = *NewNamespacesInitVariables;

sub NewNamespacesInitVariables {
  OldNamespacesInitVariables();
  if ($UsePathInfo and not $NamespacesInit
      # make sure ordinary page names are not matched!
      and $q->path_info() =~ m|^/($InterSitePattern)(/.*)?|
      and ($2 or $q->param or $q->keywords)
      and ($1 ne $NamespacesMain)) {
    my ($ns, $rest) = ($1, $2);
    $NamespacesInit = 1;
    # Do this before changing the $DataDir and $ScriptName
    if (not $InterSiteInit and !$Monolithic and $UsePathInfo) {
      $InterSite{$NamespacesMain} = $ScriptName . '/';
      foreach my $name (glob("$DataDir/*")) {
	if (-d $name and $name =~ /($InterSitePattern)/ and $name ne $NamespacesMain) {
	  $InterSite{$1} = $ScriptName . '/' . $1 . '/';
	}
      }
    }
    # Change some stuff from the original InitVariables call:
    $DataDir    .= '/' . $ns;
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
    $ScriptName .= '/' . $ns;
    $FullUrl .= '/' . $ns;
    $WikiDescription .= "<p>Current namespace: $ns</p>";
    # override LastUpdate
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)
      = stat($IndexFile);
    $LastUpdate = $mtime;
    CreateDir($DataDir); # Create directory if it doesn't exist
    ReportError(Ts('Could not create %s', $DataDir) . ": $!", '500 INTERNAL SERVER ERROR')
      unless -d $DataDir;
  }
}
