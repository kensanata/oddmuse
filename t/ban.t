# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 19;

clear_pages();

$localhost = 'confusibombus';
$ENV{'REMOTE_ADDR'} = $localhost;

## Edit banned hosts as a normal user should fail

test_page(update_page('BannedHosts', "# Foo\n#Bar\n$localhost\n", 'banning me'),
	  'Describe the new page here');

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
	  'Describe the new page here');

## Try to edit the same page as a banned user with admin password

test_page(update_page('BannedUser', 'This is a test.', 'banning test', 0, 1),
	  "This is a test");

## Unbann myself again, testing the regexp

test_page(update_page('BannedHosts', "#Foo\n#Bar\n", 'banning me', 0, 1), "Foo", "Bar");

## Banning content

update_page('BannedContent', "# cosa\nmafia # 2007-01-14 crime\n#nostra\n", 'one banned word', 0, 1);
test_page(update_page('CriminalPage', 'This is about http://mafia.example.com'),
	  'Describe the new page here');

test_page($redirect, split('\n',<<'EOT'));
banned text
wiki administrator
matched
See .*BannedContent.* for more information
Reason: crime
EOT

test_page(update_page('CriminalPage', 'This is about http://nafia.example.com'),
	  "This is about", "http://nafia.example.com");
test_page(update_page('CriminalPage', 'This is about the cosa nostra'),
	  'cosa nostra');
test_page(update_page('CriminalPage', 'This is about the mafia'),
	  'This is about the mafia'); # not in an url
