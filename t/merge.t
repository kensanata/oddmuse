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
use Test::More tests => 3;

# These tests are similar to conflict.t except we are interested in
# UTF8 corruption.

clear_pages();

update_page('Test', 'Alex Schröder was born in Iceland.');
my $page = get_page('action=edit id=Test');
my $oldtime = xpath_test(get_page('action=edit id=Test'),
			 '//input[@name="oldtime"]/attribute::value');
ok($oldtime, 'Found timestamp for edit.');

sleep(2);

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('Test', 'Alex Schröder lived in Portugal');

sleep(2);

# merge success has lines from both lao_file_1 and lao_file_2
$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('Test', 'Alex Schröder lived in Thailand',
		      '', '', '', "oldtime=$oldtime"),
	  'Alex Schröder');
