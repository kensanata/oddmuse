# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
#
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

package OddMuse;

use File::Basename;
use File::Copy;

AddModuleDescription('module-bisect.pl', 'Module Bisect Extension');

push(@MyAdminCode, \&ModuleBisectMenu);
$Action{bisect} = \&BisectAction;

sub ModuleBisectMenu {
  return unless UserIsAdmin();
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=bisect', T('Bisect modules'), 'modulebisect'));
}

sub BisectAction {
  UserIsAdminOrError();
  RequestLockOrError();
  print GetHeader('', T('Module Bisect'), '', 'nocache');
  if (GetParam('stop')) {
    BisectEnableAll(1);
    print $q->br(), $q->strong(T('All modules enabled now!'));
    print GetFormStart(undef, 'get', 'bisect');
    print GetHiddenValue('action', 'bisect');
    print $q->submit(-name=>'noop', -value=>T('Go back'));
    print $q->end_form();
  } elsif (GetParam('good') or GetParam('bad')) {
    BisectProcess(GetParam('good'));
  } else {
    BisectInitialScreen();
  }
  PrintFooter();
  ReleaseLock();
}

sub BisectInitialScreen {
  print GetFormStart(undef, 'get', 'bisect');
  print GetHiddenValue('action', 'bisect');
  my @disabledFiles = bsd_glob("$ModuleDir/*.p[ml].disabled");
  if (@disabledFiles == 0) {
    print T('Test / Always enabled / Always disabled'), $q->br();
    my @files = bsd_glob("$ModuleDir/*.p[ml]");
    for (my $i = 0; $i < @files; $i++) {
      my $moduleName = fileparse($files[$i]);
      my @disabled = ($moduleName eq 'module-bisect.pl' ? (-disabled=>'disabled') : ());
      print $q->input({-type=>'radio', -name=>"m$i", -value=>'t', ($moduleName ne 'module-bisect.pl' ? (-checked=>'checked') : ()), @disabled});
      print $q->input({-type=>'radio', -name=>"m$i", -value=>'on', ($moduleName eq 'module-bisect.pl' ? (-checked=>'checked') : ())});
      print $q->input({-type=>'radio', -name=>"m$i", -value=>'off', @disabled});
      print $moduleName, $q->br();
    }
    print $q->submit(-name=>'bad', -value=>T('Start'));
  } else {
    print T('Biscecting proccess is already active.'), $q->br();
    print $q->submit(-name=>'stop', -value=>T('Stop'));
  }
  print $q->end_form();
}

sub BisectProcess {
  my ($isGood) = @_;
  my $parameterHandover = '';
  BisectEnableAll();
  my @files = bsd_glob("$ModuleDir/*.p[ml]");
  for (my $i = @files - 1; $i >= 0; $i--) { # handle user choices
    if (GetParam("m$i") eq 'on') {
      $parameterHandover .= GetHiddenValue("m$i", GetParam("m$i"));
      splice @files, $i, 1;
    } elsif (GetParam("m$i") eq 'off') {
      $parameterHandover .= GetHiddenValue("m$i", GetParam("m$i"));
      move($files[$i], $files[$i] . '.disabled');
      splice @files, $i, 1;
    }
  }
  my $start = GetParam('start', 1) - 1; # $start and $end are indexes
  my $end = GetParam('end', @files * 2) - 1;
  if ($end - $start <= 1) {
    print Ts('It seems like module %s is causing your problem.',
	     $q->strong((fileparse($isGood ? $files[$end] : $files[$start]))[0])), $q->br(), $q->br();
    print T('Please note that this module does not handle situations when your problem is caused by a combination of specific modules (which is rare anyway).'), $q->br();
    print T('Good luck fixing your problem! ;)');
    print GetFormStart(undef, 'get', 'bisect');
    print GetHiddenValue('action', 'bisect');
    print $q->submit(-name=>'stop', -value=>T('Stop'));
    print $q->end_form();
    return;
  }
  print T('Module count (only testable modules): '), $q->strong(scalar @files), $q->br();
  print $q->br(), T('Current module statuses:'), $q->br();
  my $halfsize = ($end - $start + 1) / 2.0; # + 1 because it is count
  $end -= int($halfsize) unless $isGood;
  $start += int($halfsize + 0.51) if $isGood; # ceil
  $halfsize = ($end - $start + 1) / 2.0;
  for (my $i = 0; $i < @files; $i++) {
    if ($i >= $start and $i <= $end - int($halfsize)) {
      print $q->strong('> + '), (fileparse($files[$i]))[0], $q->br();
    } elsif ($i >= $start and $i <= $end) {
      print $q->strong('> - '), (fileparse($files[$i]))[0], $q->br();
      move($files[$i], $files[$i] . '.disabled');
    } else {
      print $q->strong('- '), (fileparse($files[$i]))[0], $q->br();
      move($files[$i], $files[$i] . '.disabled');
    }
  }
  print GetFormStart(undef, 'get', 'bisect');
  print GetHiddenValue('action', 'bisect');
  print GetHiddenValue('start', $start + 1);
  print GetHiddenValue('end', $end + 1);
  print $parameterHandover;
  print $q->submit(-name=>'good', -value=>T('Good')), ' ';
  print $q->submit(-name=>'bad', -value=>T('Bad')), ' ';
  print $q->submit(-name=>'stop', -value=>T('Stop'));
  print $q->end_form();
}

sub BisectEnableAll {
  for (bsd_glob("$ModuleDir/*.p[ml].disabled")) { # reenable all modules
    my $oldName = $_;
    s/\.disabled$//;
    print Ts('Enabling %s', (fileparse($_))[0]), '...', $q->br() if $_[0];
    move($oldName, $_);
  }
}
