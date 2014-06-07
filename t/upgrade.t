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
use Test::More tests => 15;

clear_pages();

# Create a 2.2.6 wiki first.
$page = qx(perl t/oddmuse-2.2.6.pl title=Test text=Hello);
test_page($page, "Status: 302 Found");
$page = qx(perl t/oddmuse-2.2.6.pl title=Test text=Hallo);
test_page($page, "Status: 302 Found");
$page = qx(perl t/oddmuse-2.2.6.pl action=pagelock id=Test set=1 pwd=foo);
test_page($page, "created");

ok(-d "$PageDir/T", "T page directory exists");
ok(-d "$KeepDir/T", "T keep directory exists");

add_module('upgrade.pl');

$page = get_page('action=upgrade pwd=foo');

test_page($page,
	  'page/T/Test.pg',
	  'page/T/Test.lck',
	  'keep/T/Test');

test_page_negative($page, 'failed', 'does not fit the pattern');

ok(! -d "$PageDir/T", "T directory has disappeared");
ok(! -d "$KeepDir/T", "T keep directory has disappeared");
ok(! -d $LockDir . 'main', "Lock was released");

test_page(get_page('action=browse id=Test revision=1'), 'Hello');

test_page(get_page('Test'), 'Hallo');
