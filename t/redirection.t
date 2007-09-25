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
use Test::More tests => 22;

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
test_page(update_page('Sonny_Stitt', '#REDIRECT [[Stitt]]'),
	  'Status: 302',
	  'Location: .*wiki.pl\?action=browse;oldid=Sonny_Stitt;id=Stitt');
# define permanent anchor
test_page(update_page('Jack_DeJohnette', 'A friend of [::Gary Peacock]'),
	  'A friend of',
	  'Gary Peacock',
	  'name="Gary_Peacock"',
	  'class="definition"',
	  'title="Click to search for references to this permanent anchor"');
# link to a permanent anchor
test_page(update_page('Keith_Jarret', 'Plays with [[Gary Peacock]]'),
	  'Plays with',
	  'wiki.pl/Jack_DeJohnette#Gary_Peacock',
	  'Keith Jarret',
	  'Gary Peacock');
test_page(get_page('Gary_Peacock'),
	  'Status: 302',
	  'Location: .*wiki.pl/Jack_DeJohnette#Gary_Peacock');
# undefine permanent anchor
test_page(update_page('Jack_DeJohnette', 'A friend of Gary Peacock.'),
	  'A friend of Gary Peacock.');
# verify that the link to it turns into an edit link
test_page(get_page('Keith_Jarret'),
	  'wiki.pl\?action=edit;id=Gary_Peacock');
# add another level to the redirect chain above
test_page(update_page('Herby_Hancock', '#REDIRECT [[Sonny_Stitt]]'),
	  'Location: http://localhost/wiki.pl\?action=browse;oldid=Herby_Hancock;id=Sonny_Stitt');
test_page(get_page('action=browse oldid=Herby_Hancock id=Sonny_Stitt'),
	  'Too many redirections',
	  '#REDIRECT');
