# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 11;
clear_pages();

add_module('enclosure.pl');
add_module('creole.pl');

AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");

test_page(update_page('MyImage', "#FILE image/png\niVBORw0KGgoAAAA"),
	  'This page contains an uploaded file');
test_page(update_page('MyOtherImage', "#FILE image/png\niVBORw0KGgoAAAA"),
	  'This page contains an uploaded file');

xpath_run_tests('[[enclosure:MyImage]]'
		=> '//a[@class="upload"][@href="http://localhost/test.pl/download/MyImage"][text()="MyImage"]',
		'[[enclosure:MyImage|image]]'
		=> '//a[@class="upload"][@href="http://localhost/test.pl/download/MyImage"][text()="image"]');

test_page(update_page('2007-08-05', 'Show notes linking to [[enclosure:MyImage]]
and [[enclosure:MyImage]] (no duplicates!)
and {{{[[enclosure:MyExampleImage]]}}} (no links to quoted enclosures)
and [[enclosure:MyMissingImage|image]] (do not link missing)
and [[enclosure:MyOtherImage|image]] (different name).', 'First Post!'),
	  'Show notes');

test_page(get_page('action=rss match=^2007 title=Podcast'),
	  '<title>Wiki: Podcast</title>',
	  '<title>2007-08-05</title>',
	  '<link>http://localhost/wiki.pl/2007-08-05</link>',
	  '<description>First Post!</description>',
	  '<enclosure url="http://localhost/wiki.pl/download/MyImage" length="11" type="image/png" />',
	  '<enclosure url="http://localhost/wiki.pl/download/MyOtherImage" length="11" type="image/png" />');
