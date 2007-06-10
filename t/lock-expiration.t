# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 13;

clear_pages(); # this also disables Surge Protection
AppendStringToFile($ConfigFile, "\$SurgeProtection = 1;\n");
$localhost = 'confusibombus';
$ENV{'REMOTE_ADDR'} = $localhost;
ok(! -d $LockDir . 'visitors', 'visitors lock does not exist yet');
ok(! -f $VisitorFile, 'visitors log does not exist yet');

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

AppendStringToFile($ConfigFile, "\$LockExpiration = 3;\n");
test_page(update_page('Test', 'page updated'), 'page updated');
ok(! -d $LockDir . 'visitors', 'visitors lock expired');
ok($ts != (stat($VisitorFile))[10], 'visitors log was modified');
