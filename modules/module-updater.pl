# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use File::Basename;
use File::Copy;

package OddMuse;

AddModuleDescription('module-updater.pl', 'Module Updater Extension');

our $OddmuseModulesUrl = 'http://git.savannah.gnu.org/cgit/oddmuse.git/plain/modules/';

push(@MyAdminCode, \&ModuleUpdaterMenu);
$Action{updatemodules} = \&ModuleUpdaterAction;

sub ModuleUpdaterMenu {
  return unless UserIsAdmin();
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=updatemodules', T('Update modules'), 'moduleupdater'));
}

sub ModuleUpdaterAction {
  return unless UserIsAdminOrError();
  RequestLockOrError();
  print GetHeader('', T('Module Updater'), '');
  for (bsd_glob("$ModuleDir/*.p[ml]")) {
    my $curModule = fileparse($_);
    ProcessModule($curModule);
  }
  print '<strong>Done!</strong>';
  PrintFooter();
  ReleaseLock();
}

sub ProcessModule() {
  my $module = shift;
  CreateDir($TempDir);
  print "<hr/>";
  print "<strong>Updating $module ...</strong><br/>";
  if (system('wget', '-O', "$TempDir/newmodule", '--', "$OddmuseModulesUrl/$module") != 0) {
    if ($? >> 8 == 8) { # wget usually returns 8 if server response is NOT FOUND
      # TODO maybe there is any better way to do this?
      print '<strong>There is no such module in git repository. If this is your own module, please contribute it to Oddmuse! If it is not, then it was probably removed.</strong><br/>';
      return;
    }
    print 'There was an error downloading this module.<br/>';
    return;
  }
  my $diff = DoModuleDiff("$ModuleDir/$module", "$TempDir/newmodule");
  if (not $diff) {
    print '<strong>This module is up to date, there is no need to update it.</strong><br/>';
    return;
  }
  print '<strong>There is a newer version of this module. Here is a diff:</strong><br/>';

  $diff = QuoteHtml($diff);
  $diff =~ tr/\r//d; # TODO is this required? # probably not
  for (split /\n/, $diff) {
    my ($type) = /(.)/;
    if ($type eq '+') {
      print '<span class="updaternew">';
    } elsif ($type eq '-') {
      print '<span class="updaterold">';
    }
    print '<code>' . $_ . '</code>';
    print '</span>' if $type =~ /[+-]/;
    print '<br/>';
  }
  move("$TempDir/newmodule", "$ModuleDir/$module") or print "<strong>Unable to replace module: $! </strong><br/>";
  print '<strong>Module updated successfully!</strong><br/>';
}

sub DoModuleDiff {
  my $diff = `diff -U 3 -- \Q$_[0]\E \Q$_[1]\E`;
  utf8::decode($diff_out); # needs decoding
  return $diff;
}
