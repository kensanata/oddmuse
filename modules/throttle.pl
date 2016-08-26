# Copyright (C) 2004, 2006  Alex Schroeder <alex@emacswiki.org>
#               2004  Sebastian Blatt <sblatt@havens.de>
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

# Limits the number of parallel Oddmuse instances to
# $InstanceThrottleLimit by keeping track of the process ids in
# $InstanceThrottleDir

use strict;
use v5.10;

AddModuleDescription('throttle.pl', 'Limit Number Of Instances Running');

use File::Glob ':glob';
our ($q, $DataDir);
our ($InstanceThrottleDir, $InstanceThrottleLimit);

$InstanceThrottleDir = $DataDir."/pids"; # directory for pid files
$InstanceThrottleLimit = 2; # maximum number of parallel processes

*OldDoSurgeProtection = \&DoSurgeProtection;
*DoSurgeProtection = \&NewDoSurgeProtection;

*OldDoBrowseRequest = \&DoBrowseRequest;
*DoBrowseRequest = \&NewDoBrowseRequest;

sub NewDoSurgeProtection {
  DoInstanceThrottle();
  CreatePidFile();
  OldDoSurgeProtection();
}

sub NewDoBrowseRequest {
  OldDoBrowseRequest();
  RemovePidFile();
}

# limit the script to a maximum of $InstanceThrottleLimit instances
sub DoInstanceThrottle {
  my @pids = Glob($InstanceThrottleDir."/*");
  # Go over all pids: validate each pid by sending signal 0, unlink
  # pidfile if pid does not exist and return 0. Count the number of
  # zeros (= removed files = zombies) with grep.
  my $zombies = grep /^0$/,
    (map {/(\d+)$/ and kill 0,$1 or Unlink($_) and 0} @pids);
  if (scalar(@pids)-$zombies >= $InstanceThrottleLimit) {
    ReportError(Ts('Too many instances.  Only %s allowed.',
		   $InstanceThrottleLimit),
                '503 Service Unavailable',
	       undef,
	       $q->p(T('Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.')));
  }
}

sub CreatePidFile {
  CreateDir($InstanceThrottleDir);
  my $data = $q->request_method . ' ' . $q->url(-path_info=>1) . "\n";
  foreach my $param ($q->param) {
    next if $param eq 'pwd';
    $data .= "Param " . $param . "=" . $q->param($param) . "\n";
  }
  WriteStringToFile("$InstanceThrottleDir/$$", $data);
}

sub RemovePidFile {
  my $file = "$InstanceThrottleDir/$$";
  # not fatal
  Unlink($file);
}
