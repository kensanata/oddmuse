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
  print $q->strong('Done!');
  PrintFooter();
  ReleaseLock();
}

sub ProcessModule() {
  my $module = shift;
  CreateDir($TempDir);
  print $q->hr();
  print $q->strong("Updating $module ..."), $q->br();
  my $moduleData = GetRaw("$OddmuseModulesUrl/$module");
  if (not $moduleData) {
    print $q->strong('There was an error downloading this module.'
		     . ' If this is your own module, please contribute it to Oddmuse!'), $q->br();
    return;
  }
  open my $fh, ">", "$TempDir/newmodule" or die("Could not open file. $!");
  print $fh $moduleData;
  close $fh;

  my $diff = DoModuleDiff("$ModuleDir/$module", "$TempDir/newmodule");
  if (not $diff) {
    print $q->strong('This module is up to date, there is no need to update it.'), $q->br();
    return;
  }
  print $q->strong('There is a newer version of this module. Here is a diff:'), $q->br();

  $diff = QuoteHtml($diff);
  $diff =~ tr/\r//d; # TODO is this required? # probably not
  for (split /\n/, $diff) {
    my ($type) = /(.)/;
    if ($type =~ /[+-]/) {
      my $class = $type eq '+' ? 'updaternew' : 'updaterold';
      print $q->span({-class => $class}, $q->code($_));
    } else {
      print $q->span($q->code($_));
    }
    print $q->br();
  }
  if (move("$TempDir/newmodule", "$ModuleDir/$module")) {
    print $q->strong('Module updated successfully!'), $q->br();
  } else {
    print $q->strong("Unable to replace module: $!"), $q->br();
  }
}

sub DoModuleDiff {
  my $diff = `diff -U 3 -- \Q$_[0]\E \Q$_[1]\E`;
  utf8::decode($diff_out); # needs decoding
  return $diff;
}
