# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 23;

update_page('Test', 'Mu');
test_page(get_page('action=index'),
	  'Include normal pages', 'Test');

add_module('permanent-anchors.pl');

# create a page with a permanent anchor
update_page('Fix', '[::Moo]');

# the default is to include permanent anchors
$page = get_page('action=index');
test_page($page,
	  'Include normal pages',
	  'Include permanent anchors');
xpath_test($page, "//a[text()='Test']",
	   "//a[text()='Fix']",
	   "//a[text()='Moo']");

# we can exclude permanent anchors
$page = get_page('action=index permanentanchors=0');
xpath_test($page, "//a[text()='Test']",
	   "//a[text()='Fix']");
negative_xpath_test($page, "//a[text()='Moo']");

# or include them specifically
$page = get_page('action=index permanentanchors=1');
xpath_test($page, "//a[text()='Moo']");

# and exclude normal pages
$page = get_page('action=index pages=0 permanentanchors=1');
xpath_test($page, "//a[text()='Moo']");
negative_xpath_test($page,
		    "//a[text()='Test']",
		    "//a[text()='Fix']");

add_module('near-links.pl');

CreateDir($NearDir);
WriteStringToFile("$NearDir/EmacsWiki",
		  "Alex\n");

update_page('InterMap', " EmacsWiki http://www.emacswiki.org/wiki/%s\n",
	    'required', 0, 1);
update_page('NearMap', " EmacsWiki"
	    . " http://www.emacswiki.org/wiki?action=index;raw=1"
	    . " http://www.emacswiki.org/wiki?search=%s;raw=1;near=0\n",
	    'required', 0, 1);

# the default is to not include near links
$page = get_page('action=index');
test_page($page,
	  'Include normal pages',
	  'Include permanent anchors',
	  'Include near pages');
xpath_test($page, "//a[text()='Test']",
	   "//a[text()='Fix']",
	   "//a[text()='Moo']");
negative_xpath_test($page, "//a[text()='Alex']");

# we need to specifically include near links
$page = get_page('action=index near=1');
xpath_test($page, "//a[text()='Alex']");

# or we can specifically exclude near links
$page = get_page('action=index near=0');
negative_xpath_test($page, "//a[text()='Alex']");
