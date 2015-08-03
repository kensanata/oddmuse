# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 4;

test_page(update_page('Test', 'Content is saved', '<xss>'),
          'Content is saved');
test_page(get_page('action=browse id=Test diff=1'),
          '&lt;xss&gt;');
test_page(get_page('action=rss'),
          '&amp;lt;xss&amp;gt;');

# enable uploads
AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");
update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA");
test_page(update_page('Test', '[[image:Logo|"/><xss><span]]'),
          '&lt;xss&gt;');
