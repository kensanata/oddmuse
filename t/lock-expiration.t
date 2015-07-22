# Copyright (C) 2007–2015  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 17;

# TODO move that to test.pl?
# we will be using the same fake time in these tests as well
BEGIN {
  sub updateFakeTime { utime($_[0], $_[0], "$DataDir/ts") }
  *CORE::GLOBAL::sleep = sub { updateFakeTime((stat("$DataDir/ts"))[9] + $_[0]) };
  *CORE::GLOBAL::time  = sub { (stat("$DataDir/ts"))[9] };
}

# AppendStringToFile($ConfigFile, "\$SurgeProtection = 1;\n"); # why are we enabling it?
$localhost = 'confusibombus';
$ENV{'REMOTE_ADDR'} = $localhost;
my $lock = $LockDir . 'visitors';
ok(! -d $lock, 'visitors lock does not exist yet');
ok(! -f $VisitorFile, 'visitors log does not exist yet');

# Don't loop forever trying to remove a lock older than $LockExpiration that
# cannot be removed (eg. if the script user was changed, so that the old
# lockfile cannot be removed by the new user). Locks are directories; we
# simulate a lock that cannot be removed by creating a file with the same name
# instead. At the same time, test fake-time!
mkdir($TempDir);
ok(open(F, '>', $lock), "create bogus ${LockDir}visitors");
my $ts = time - 120;
utime($ts, $ts, $lock); # change mtime of the lockfile

# Getting a time will now time out because no visitor lock can be acquired.
$ts = time;
get_page('fail-to-get-lock');

# Since we're using fake-time, let's make sure that no real time passed.
my $waiting = time - $ts;
ok($waiting <= 1, "waited $waiting real seconds (max. 1)");

# Fake time is available in the timestamp file.
my $fakets = (stat("$DataDir/ts"))[9];
$waiting = $fakets - $ts;
ok($waiting >= 16, "waited $waiting fake seconds (min. 16)");

# Remove the fake visitors lock and redo this. Reset the fake timestamp on the
# file. Get a file. This should take no real time and no fake time (as there was
# no sleeping involved).
unlink($LockDir . 'visitors');
$ts = time;
utime($ts, $ts, "$DataDir/ts");
test_page(get_page('get-lock'), 'get-lock');
$waiting = time - $ts;
ok($waiting <= 2, "waited $waiting seconds (max. 2)");

# Make sure no fake time elapsed!
$fakets = (stat("$DataDir/ts"))[9];
$waiting = $fakets - time;
ok($waiting <= 2, "waited $waiting fake seconds (max. 2)");

# The main lock works as intended.
RequestLockOrError();
update_page('cannot', 'create');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  'Could not get main lock');
ReleaseLock();

my $ts = (stat($VisitorFile))[10];
ok($Now - $ts <= 3, 'visitors log recently modified');

# Create a non-essential lock and make sure the lock directory is
# created, and that it remains even if no error occurs.
RequestLockDir('visitors');
ok(-d $LockDir . 'visitors', 'visitors lock created');

update_page('Test', 'page created');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  "create the directory $TempDir");
ok(-d $LockDir . 'visitors', 'visitors lock remained');
ok($ts == (stat($VisitorFile))[10], 'visitors log was not modified');

AppendStringToFile($ConfigFile, "\$LockExpiration = -1;\n");
test_page(update_page('Test', 'page updated'), 'page updated');
ok(! -d $LockDir . 'visitors', 'visitors lock expired');
ok($ts != (stat($VisitorFile))[10], 'visitors log was modified');
