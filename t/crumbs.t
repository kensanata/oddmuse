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
use Test::More tests => 1;
clear_pages();

AppendStringToFile($ConfigFile, "\$PageCluster = 'Cluster';\n");

add_module('crumbs.pl');

update_page("HomePage", "Has to do with [[Software]].");
update_page("Software", "[[HomePage]]\n\nCheck out [[Games]].");
update_page("Games", "[[Software]]\n\nThis is it.");
xpath_test(get_page('Games'),
		'//p/span[@class="crumbs"]/a[@class="local"][@href="http://localhost/wiki.pl/HomePage"][text()="HomePage"]/following-sibling::text()[string()=" "]/following-sibling::a[@class="local"][@href="http://localhost/wiki.pl/Software"][text()="Software"]');
