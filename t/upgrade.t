# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 47;

clear_pages();

# Create a 2.2.6 wiki first.
$page = qx(perl t/oddmuse-2.2.6.pl title=Test text=Hello);
test_page($page, "Status: 302 Found");
$page = qx(perl t/oddmuse-2.2.6.pl title=Test text=Hallo);
test_page($page, "Status: 302 Found");
$page = qx(perl t/oddmuse-2.2.6.pl title=.hidden text=Hello);
test_page($page, "Status: 302 Found");
$page = qx(perl t/oddmuse-2.2.6.pl title=.hidden text=Hallo);
test_page($page, "Status: 302 Found");
$page = qx(perl t/oddmuse-2.2.6.pl action=pagelock id=Test set=1 pwd=foo);
test_page($page, "created");

ok(-d "$PageDir/T", "T page directory exists");
ok(-d "$KeepDir/T", "T keep directory exists");
ok(-d "$PageDir/other", "other page directory exists");
ok(-d "$KeepDir/other", "other keep directory exists");

add_module('upgrade.pl');

ok(-f "$ModuleDir/upgrade.pl", "upgrade.pl was installed");

test_page(get_page('Test'), 'Upgrading Database', 'action=password');

test_page(get_page('action=password'), 'You are a normal user');

$page = get_page('action=upgrade pwd=foo');

test_page($page,
	  'page/T/Test.pg',
	  'page/T/Test.lck',
	  'keep/T/Test',
	  'page/other/.hidden.pg',
	  'keep/other/.hidden',
	  'Upgrade complete');

test_page_negative($page, 'failed',
		   'does not fit the pattern',
		   'Please remove');

ok(! -d "$PageDir/T", "T directory has disappeared");
ok(! -d "$KeepDir/T", "T keep directory has disappeared");
ok(! -d $LockDir . 'main', "Lock was released");
ok(! -f "$ModuleDir/upgrade.pl", "upgrade.pl was renamed");

test_page(get_page('action=browse id=Test revision=1'), 'Hello');

test_page(get_page('Test'), 'Hallo');
test_page(get_page('.hidden'), 'Hallo');

# you cannot run it again after a successful run
test_page(get_page('action=upgrade pwd=foo'),
	  'Invalid action parameter');

# reinstall it and run it again
add_module('upgrade.pl');

test_page(get_page('action=upgrade pwd=foo'),
	  'Upgrade complete');

# set up a wiki with namespaces

clear_pages();

# install the old revision of namespaces.pl; we cannot use add_module
# because the old revision is stored in the t subdirectory.
my $dir = `/bin/pwd`;
chop($dir);
my $mod = 'namespaces-2.2.6.pl';
mkdir($ModuleDir);
symlink("$dir/t/$mod", "$ModuleDir/$mod");
ok(-e "$ModuleDir/$mod", "old namespaces.pl installed");

test_page(qx(perl t/oddmuse-2.2.6.pl title=Test text=Main%20Hello),
	  "Status: 302 Found", "Location: http://localhost/wiki.pl/Test");

test_page(qx(perl t/oddmuse-2.2.6.pl title=Test text=Space%20Hello ns=Space),
	  "Status: 302 Found", "Location: http://localhost/wiki.pl/Space/Test");

add_module('upgrade.pl');

$page = get_page('action=upgrade pwd=foo');

test_page($page,
	  '<strong>Space</strong>',
	  'Upgrade complete');

test_page_negative($page, 'failed');

test_page(get_page('Test'), 'Main Hello');
test_page(get_page("'/Space/Test?'"), 'Space Hello');

# Install modules which use GetPageContent in their init routine.

clear_pages();

test_page(qx(perl t/oddmuse-2.2.6.pl title=$InterMap text=$InterMap),
	  $InterMap);

add_module('localnames.pl');
test_page(qx(perl t/oddmuse-2.2.6.pl title=$LocalNamesPage text=$LocalNamesPage),
	  $LocalNamesPage);

add_module('sidebar.pl');
test_page(qx(perl t/oddmuse-2.2.6.pl title=$SidebarName text=$SidebarName),
	  $SidebarName);

add_module('near-links.pl');
test_page(qx(perl t/oddmuse-2.2.6.pl title=$NearMap text=$NearMap),
	  $NearMap);

add_module('upgrade.pl');
test_page_negative(get_page('HomePage'), 'Cannot open');
test_page(get_page('action=upgrade pwd=foo'),
	  'Upgrade complete');
