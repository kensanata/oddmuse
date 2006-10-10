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
use Test::More tests => 5;

%Languages = ('de' => '\b(der|die|das|und|oder)\b',
	      'fr' => '\b(et|le|la|pas)\b', );

is(GetLanguages('This is English text and cannot be identified.'), '', 'unknown language');
is(GetLanguages('Die Katze tritt die Treppe krumm.'), '', 'not enough German words');
is(GetLanguages('Die Katze tritt die Treppe und die Stiege krumm.'), 'de', 'enough German words');
is(GetLanguages('Le chat fait la même chose et ne chante pas.'), 'fr', 'enough French words');
is(GetLanguages('Die Katze tritt die Treppe und die Stiege krumm. '
		. 'Le chat fait la même chose et ne chante pas.'), 'de,fr', 'both German and French');
