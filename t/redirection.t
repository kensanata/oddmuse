# Copyright (C) 2006, 2007  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 9;

clear_pages();

# test message when using an undefined link pattern in a redirect
test_page(update_page('John_Coltrane', '#REDIRECT Coltrane'),
	  '#REDIRECT Coltrane',
	  'Invalid link pattern for #REDIRECT');
# plain link to an existing page
test_page(update_page('Miles_Davis', 'Featuring [[John Coltrane]]'),
	  'Featuring',
	  'John Coltrane');
# simple redirect
test_page(update_page('Sonny_Stitt', '#REDIRECT [[Stittö]]'),
	  'Status: 302',
	  'Location: .*wiki.pl\?action=browse;oldid=Sonny_Stitt;id=Stitt%c3%b6');
# add another level to the redirect chain above
test_page(update_page('Herby_Hancock', '#REDIRECT [[Sonny_Stitt]]'),
	  'Location: http://localhost/wiki.pl\?action=browse;oldid=Herby_Hancock;id=Sonny_Stitt');
test_page(get_page('action=browse oldid=Herby_Hancock id=Sonny_Stitt'),
	  'Too many redirections',
	  '#REDIRECT');
