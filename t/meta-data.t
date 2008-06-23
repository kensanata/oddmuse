# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 5;

clear_pages();

AppendStringToFile($ConfigFile, qq(\$HtmlHeaders = '<meta name="ICBM" content="47.3787648948578, 8.52716503722805">'
      . '<meta name="DC.title" content="Home of Alex">';\n));
xpath_test(get_page('HomePage'),
	   '//link[@rel="alternate"][@type="application/rss+xml"][@title="Wiki"][@href="http://localhost/wiki.pl?action=rss"]',
	   '//meta[@name="DC.title"][@content="Home of Alex"]',
	   '//meta[@name="ICBM"][@content="47.3787648948578, 8.52716503722805"]');

negative_xpath_test(get_page('action=version'),
		    '//meta[@type="application/wiki"]');
xpath_test(get_page('Foo'),
	   '//link[@type="application/wiki"][@title="Edit this page"][@rel="alternate"][@href="http://localhost/wiki.pl?action=edit;id=Foo"]');
