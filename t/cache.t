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
use Test::More tests => 4;

clear_pages();

$str = 'This is a WikiLink.';

# this setting produces no link.
AppendStringToFile($ConfigFile, "\$WikiLinks = 0;\n");
test_page(update_page('CacheTest', $str, '', 1), $str);

# now change the setting, you still get no link because the cache has
# not been updated.
AppendStringToFile($ConfigFile, "\$WikiLinks = 1;\n");
test_page(get_page('CacheTest'), $str);

# refresh the cache
test_page(get_page('action=clear pwd=foo'), 'Clear Cache');

# now there is a link
# This is a WikiLink<a class="edit" title="Click to edit this page" href="http://localhost/wiki.pl\?action=edit;id=WikiLink">\?</a>.
xpath_test(get_page('CacheTest'), '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=WikiLink"][text()="?"]');
