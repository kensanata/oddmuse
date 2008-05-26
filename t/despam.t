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
use Test::More tests => 13;

clear_pages();

add_module('despam.pl');

update_page('HilariousPage', "Ordinary text.");
update_page('HilariousPage', "Hilarious text.");
update_page('HilariousPage', "Spam from http://example.com.");

update_page('NoPage', "Spam from http://example.com.");

update_page('OrdinaryPage', "Spam from http://example.com.");
update_page('OrdinaryPage', "Ordinary text.");

update_page('ExpiredPage', "Spam from http://example.com.");
update_page('ExpiredPage', "More spam from http://example.com.");
update_page('ExpiredPage', "Still more spam from http://example.com.");

update_page('BannedContent', " example\\.com\n", 'required', 0, 1);

unlink("$DataDir/keep/E/ExpiredPage/1.kp")
  or die "Cannot delete kept revision: $!";

my $page = get_page('action=spam');
test_page($page, 'HilariousPage', 'NoPage', 'ExpiredPage');
test_page_negative($page, 'OrdinaryPage');

test_page(get_page('action=despam'), 'HilariousPage.*Revert to revision 2',
	  'NoPage.*Marked as DeletedPage', 'OrdinaryPage',
	  'ExpiredPage.*Cannot find unspammed revision');

test_page(get_page('ExpiredPage'), 'Still more spam');
test_page(get_page('OrdinaryPage'), 'Ordinary text');
test_page(get_page('NoPage'), 'DeletedPage');
test_page(get_page('HilariousPage'), 'Hilarious text');
test_page(get_page('BannedContent'), 'example\\\.com');
