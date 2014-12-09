# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use utf8;

AddModuleDescription('upgrade.pl', '2014-06-17 New Directory Structure');

# We are now running in InitModules. InitVariables will be called later.
# We want to prevent any calls to GetPageContent and the like.

*UpgradeOldInitVariables = *InitVariables;
*InitVariables = *UpgradeNewInitVariables;

sub UpgradeNewInitVariables {
  $InterMap = undef;
  $LocalNamesPage = undef;
  $SidebarName = undef;
  $NearMap = undef;
  $GotobarName = undef;
  UpgradeOldInitVariables(@_);
}

*DoBrowseRequest = *DoUpgrade;

sub DoUpgrade {

  # The only thing allowed besides upgrading is login and unlock
  my $action = lc(GetParam('action', ''));
  if (($action eq 'password' or $action eq 'unlock')
      and $Action{$action}) {
    return &{$Action{$action}}($id);
  }

  # Only admins may upgrade
  ReportError(T('Upgrading Database'),
	      '403 FORBIDDEN', 0,
	      $q->p(T('This operation is restricted to administrators only...'))
	      . $q->p(ScriptLink('action=password', T('Login'), 'password')))
    unless UserIsAdmin();

  ReportError(T('Upgrading Database'),
	      '403 FORBIDDEN', 0,
	      $q->p(T('Did the previous upgrade end with an error? A lock was left behind.'))
	      . $q->p(ScriptLink('action=unlock', T('Unlock wiki'), 'unlock')))
    unless RequestLockDir('main');

  print GetHeader('', T('Upgrading Database')),
    $q->start_div({-class=>'content upgrade'});

  if (-e $IndexFile) {
    unlink $IndexFile;
  }

  print "<p>Renaming files...";

  for my $ns ('', keys %InterSite) {
    next unless -d "$DataDir/$ns";
    print "<br />\n<strong>$ns</strong>" if $ns;
    for my $dirname ($PageDir, $KeepDir, $RefererDir, $JoinerDir, $JoinerEmailDir) {
      next unless $dirname;
      my $dir = $dirname; # copy in order not to modify the original
      $dir =~ s/^$DataDir/$DataDir\/$ns/ if $ns;
      for my $old (bsd_glob("$dir/*/*"), bsd_glob("$dir/*/.*")) {
	next if $old =~ /\/\.\.?$/;
	my $oldname = $old;
	utf8::decode($oldname);
	print "<br />\n$oldname";
	my $new = $old;
	$new =~ s!/([A-Z]|other)/!/!;
	if ($old eq $new) {
	  print " does not fit the pattern!";
	} elsif (not rename $old, $new) {
	  my $newname = $new;
	  utf8::decode($newname);
	  print " → $newname failed!";
	}
      }
      for my $subdir (grep(/\/([A-Z]|other)$/, bsd_glob("$dir/*"), bsd_glob("$dir/.*"))) {
	next if substr($subdir, -2) eq '/.' or substr($subdir, -3) eq '/..';
	rmdir $subdir; # ignore errors
      }
    }
  }

  print $q->end_p();

  if (rename "$ModuleDir/upgrade.pl", "$ModuleDir/upgrade.done") {
    print $q->p(T("Upgrade complete."))
  } else {
    print $q->p(T("Upgrade complete. Please remove $ModuleDir/upgade.pl, now."))
  }

  ReleaseLock();

  print $q->end_p(), $q->end_div();
  PrintFooter();
}
