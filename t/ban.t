# Copyright (C) 2006, 2007, 2010  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 27;

clear_pages();

$localhost = 'confusibombus';
$ENV{'REMOTE_ADDR'} = $localhost;

## Edit banned hosts as a normal user should fail

test_page(update_page('BannedHosts', "# Foo\n#Bar\n$localhost\n", 'banning me'),
	  'This page is empty');

## Edit banned hosts as admin should succeed

test_page(update_page('BannedHosts', "#Foo\n#Bar\n$localhost\n", 'banning me', 0, 1),
	  "Foo",
	  $localhost);

## Edit banned hosts as a normal user should fail

test_page(update_page('BannedHosts', "Something else.", 'banning me'),
	  "Foo",
	  $localhost);

## Try to edit another page as a banned user

test_page(update_page('BannedUser', 'This is a test which should fail.', 'banning test'),
	  'This page is empty');

## Try to edit the same page as a banned user with admin password

test_page(update_page('BannedUser', 'This is a test.', 'banning test', 0, 1),
	  "This is a test");

## Unbann myself again, testing the regexp

test_page(update_page('BannedHosts', "#Foo\n#Bar\n", 'banning me', 0, 1), "Foo", "Bar");

## Banning content, including a malformed regexp

# mafia is banned
update_page('BannedContent', "# cosa\nma ?fia # 2007-01-14 crime\n#nostra\n(huh?\n", 'one banned word', 0, 1);
test_page(update_page('CriminalPage', 'This is about http://mafia.example.com'),
	  'This page is empty');

# error message is shown
test_page($redirect,
	  'banned text',
	  'wiki administrator',
	  'matched',
	  'See .*BannedContent.* for more information',
	  'Reason: crime');

# admin can override the ban
test_page(update_page('CriminalPage', 'This is about http://mafia.example.com',
		      undef, undef, 1),
	  "http://mafia.example.com");

sleep(1);

OpenPage('CriminalPage');
my $ts = $Page{ts};

# other edits are ok
test_page(update_page('CriminalPage', 'This is about http://nafia.example.com'),
	  "http://nafia.example.com");

# comments have no effect
test_page(update_page('CriminalPage', 'This is the http://cosa.example.com'),
	  "http://cosa.example.com");

# only match in urls
test_page(update_page('CriminalPage', 'This is about the mafia'),
	  'This is about the mafia');

# rollback to banned content requires admin
test_page(get_page("action=rollback to=$ts id=CriminalPage username=Alex"),
	  'Rolling back changes',
	  'Rollback of CriminalPage would restore banned content');

# it works with the correct password
test_page(get_page("action=rollback to=$ts id=CriminalPage pwd=foo"),
	  'Rolling back changes',
	  'CriminalPage</a> rolled back');



## test strange-spam.pl

add_module('strange-spam.pl');

update_page('StrangeBannedContent', "<?pom ?poko>? # 2007-01-14 tanuki power",
	    '', 0, 1);
test_page(update_page('TanukiPage', 'I was here!! <pompoko>'),
	  'This page is empty');
test_page($redirect, 'Reason: tanuki power',
	  'See .*StrangeBannedContent.* for more information',
	  'Rule "&lt;\?pom \?poko&gt;\?" matched "&lt;pompoko&gt;" on this page');
