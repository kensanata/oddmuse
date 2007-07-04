# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 12;

clear_pages();

# Default
xpath_test(get_page('HomePage'),
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://www.oddmuse.org/oddmuse.css"]');

# StyleSheetPage
update_page('css', "em { font-weight: bold; }", 'some css', 0, 1);
$page = get_page('HomePage');
negative_xpath_test($page,
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://www.oddmuse.org/oddmuse.css"]');
xpath_test($page,
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://localhost/wiki.pl?action=browse;id=css;raw=1;mime-type=text/css"]');

# StyleSheet option
AppendStringToFile($ConfigFile, "\$StyleSheet = 'http://example.org/test.css';\n");
$page = get_page('HomePage');
negative_xpath_test($page,
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://www.oddmuse.org/oddmuse.css"]',
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://localhost/wiki.pl?action=browse;id=css;raw=1;mime-type=text/css"]');
xpath_test($page,
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://example.org/test.css"]');

# Parameter
$page = get_page('action=browse id=HomePage css=http://example.org/my.css');
negative_xpath_test($page,
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://www.oddmuse.org/oddmuse.css"]',
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://localhost/wiki.pl?action=browse;id=css;raw=1;mime-type=text/css"]',
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://example.org/test.css"]');
xpath_test($page,
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://example.org/my.css"]');

$page = get_page('action=browse id=HomePage css=http://example.org/my.css%20http://example.org/your.css');
xpath_test($page,
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://example.org/my.css"]',
	   '//link[@type="text/css"][@rel="stylesheet"][@href="http://example.org/your.css"]');
