# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 17;
use utf8;

add_module('gotobar.pl');

test_page(update_page('InterMap', q{
 Edit http://emacswiki.org/wiki?action=edit;id=%s
 Browse http://emacswiki.org/wiki/%s
}, 0, 0, 1), 'Edit', 'Browse');

test_page(update_page('GotoBar', q{
[[Hauptseite]]
[[Letzte Änderungen]]
[Browse:SiteMap Emacs Wiki]
[http://example.org/ Example]
}), 'Hauptseite', 'Letzte Änderungen', 'Emacs Wiki', 'Example');

test_page(get_page('Hauptseite'),
	  'Hauptseite', 'Letzte Änderungen', 'Emacs Wiki', 'Example');

test_page(get_page('Letzte_%C3%84nderungen'),
	  'GotoBar');


update_page('GotoBar', q{
[[Comments on $id]]
[[Comments on $id|Comments]]
[[Edit:$id Edit $id]]
[http://example.org/$$id Example]
});

test_page(get_page('Tëst'),
	  'Comments on Tëst', 'Comments_on_T%c3%abst',
	  'http://emacswiki.org/wiki\?action=edit;id=Tëst', 'Edit Tëst',
	  'http://example.org/T%c3%abst', 'Example');
