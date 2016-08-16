# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 2;

add_module('link-all.pl');

update_page('foo', 'link-all for bar');

xpath_test(get_page('action=browse define=1 id=foo'),
	  '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=bar"][text()="bar"]');


xpath_run_tests(split('\n',<<'EOT'));
testing foo.
//a[@class="local"][@href="http://localhost/test.pl/foo"][text()="foo"]
EOT
