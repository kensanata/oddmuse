# Copyright (C) 2006–2015  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 13;

add_module('all.pl');

update_page('foo', 'link to [[bar]].');
update_page('bar', 'link to [[baz]]. link to [[pic]].');

# enable uploads
AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");

# upload image
update_page('pic', "#FILE image/png\niVBORw0KGgoAAAA");

test_page(get_page('action=all'), 'restricted to administrators');
xpath_test(get_page('action=all pwd=foo'),
	   '//p/a[@href="#HomePage"][text()="HomePage"]',
	   '//h1/a[@name="foo"][text()="foo"]',
	   '//a[@class="local"][@href="#bar"][text()="bar"]',
	   '//h1/a[@name="bar"][text()="bar"]',
	   '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=baz"][text()="?"]',
	   '//h1/a[@name="pic"][text()="pic"]',
	   '//a[@class="local"][@href="#pic"][text()="pic"]',
    );

update_page('bar', 'link to [[baz]].\n\n[[image:pic]]');
xpath_test(get_page('action=all pwd=foo'),
           '//p[text()="This page contains an uploaded file:"]',
           '//img[@src="http://localhost/wiki.pl/download/pic"][@alt="pic"][@class="upload"]',
    );

update_page('bar', 'link to [[baz]].\n\n[[image:pic|nice]]');
xpath_test(get_page('action=all pwd=foo'),
           '//p[text()="This page contains an uploaded file:"]',
           '//img[@src="http://localhost/wiki.pl/download/pic"][@alt="nice"][@class="upload"]',
    );

add_module('image.pl');

# we need to pass cache=0 because this link to the page 'foo' is created "clean"
update_page('bar', "link to [[baz]].\n\n[[image:pic|nice|foo]]");
xpath_test(get_page('action=all pwd=foo cache=0'),
           '//a[@href="#foo"]/img[@src="http://localhost/wiki.pl/download/pic"][@alt="nice"][@class="upload"]',
    );
