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
use Test::More tests => 6;
clear_pages();

add_module('all.pl');

update_page('foo', 'link to [[bar]].');
update_page('bar', 'link to [[baz]].');
test_page(get_page('action=all'), 'restricted to administrators');
xpath_test(get_page('action=all pwd=foo'),
	   '//p/a[@href="#HomePage"][text()="HomePage"]',
	   '//h1/a[@name="foo"][text()="foo"]',
	   '//a[@class="local"][@href="#bar"][text()="bar"]',
	   '//h1/a[@name="bar"][text()="bar"]',
	   '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=baz"][text()="?"]',
	  );
