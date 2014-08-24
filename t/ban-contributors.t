# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 21;

clear_pages();

add_module('ban-contributors.pl');
$localhost = '127.0.0.1';
$ENV{'REMOTE_ADDR'} = $localhost;

update_page('Test', 'insults');
test_page_negative(get_page('action=admin id=Test'), 'Ban contributors');
test_page(get_page('action=admin id=Test pwd=foo'), 'Ban contributors');
test_page(get_page('action=ban id=Test pwd=foo'), $localhost, 'Ban!');
test_page(get_page("action=ban id=Test host=$localhost pwd=foo"),
	  'Location: http://localhost/wiki.pl/BannedHosts');
test_page(get_page('BannedHosts'), $localhost, 'Test');

clear_pages();
add_module('ban-contributors.pl');

update_page('Test', 'no spam');
ok(get_page('action=browse id=Test raw=2')
   =~ /(\d+) # Do not delete this line/,
   'raw=2 returns timestamp');
$to = $1;
ok($to, 'timestamp stored');
sleep(1);

update_page('Test', "http://spam/amoxil/ http://spam/doxycycline/");
test_page(get_page("action=rollback id=Test to=$to pwd=foo"),
	  'Rolling back changes', 'These URLs were rolled back',
	  'amoxil', 'doxycycline', 'Consider banning the IP number');
test_page(get_page("action=ban id=Test content=amoxil pwd=foo"),
	  'Location: http://localhost/wiki.pl/BannedContent');
test_page(get_page('BannedContent'), 'amoxil', 'Test');
update_page('Test', "http://spam/amoxil/ http://spam/doxycycline/");
$page = get_page("action=rollback id=Test to=$to pwd=foo");
test_page($page, 'Rolling back changes', 'These URLs were rolled back',
	  'doxycycline');
test_page_negative($page, 'amoxil');
