# Copyright (C) 2015  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 20;

test_page(get_page('action=editlock'), 'operation is restricted');
test_page(get_page('action=editlock pwd=foo'), 'Edit lock created');
xpath_test(update_page('TestLock', 'mu!'),
	   '//a[@href="http://localhost/wiki.pl?action=password"][@class="password"][text()="This page is read-only"]');
test_page($redirect, '403 FORBIDDEN', 'Editing not allowed: TestLock is read-only');
test_page(get_page('action=editlock set=0'), 'operation is restricted');
test_page(get_page('action=editlock set=0 pwd=foo'), 'Edit lock removed');
RequestLockDir('main');
test_page(update_page('TestLock', 'mu!'), 'This page does not exist');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  'Could not get main lock', 'File exists',
	  'The lock was created (just now|1 second ago|2 seconds ago)');
test_page(update_page('TestLock', 'mu!'), 'This page does not exist');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  'Could not get main lock', 'File exists',
	  'The lock was created \d+ seconds ago');

# Lock cleaners

AppendToConfig(<<'END');
$Action{'jobinterrupted'} = sub {
  print GetHeader();
  RequestLockDir('importantjob');
  WriteStringToFile("$DataDir/deletemewhenfinished", 'bla-bla');
  print 'Ok, doing some lengthy job... ';
  sleep 15;
  print 'Done!';
  unlink "$DataDir/deletemewhenfinished"; # WHOOPS!
  ReleaseLockDir('importantjob');
  PrintFooter();
};
END
RunAndTerminate('perl', 'wiki.pl', 'action=jobinterrupted');
# first let's test that the action works (otherwise next test will give false "ok")
ok(-f "$DataDir/deletemewhenfinished", 'deletemewhenfinished file was created but not deleted');

ok(! -d "$TempDir/lockimportantjob", 'lock was deleted automatically');

AppendToConfig(<<'END');
$LockCleaners{'importantjob'} = sub {
  unlink "$DataDir/deletemewhenfinished" if -f "$DataDir/deletemewhenfinished";
};
END
RunAndTerminate('perl', 'wiki.pl', 'action=jobinterrupted');
ok(! -f "${LockDir}deletemewhenfinished", 'Custom lock cleaning code works');
