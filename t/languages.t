# Copyright (C) 2006-2019  Alex Schroeder <alex@gnu.org>
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
use Test::More;
use utf8; # tests contain UTF-8 characters and it matters

%Languages = ('de' => '\b(der|die|das|und|oder)\b',
	      'fr' => '\b(et|le|la|ne|pas)\b', );

is(GetLanguages('This is English text and cannot be identified.'), '', 'unknown language');
is(GetLanguages('Die Katze tritt die Treppe krumm.'), '', 'not enough German words');
is(GetLanguages('Die Katze tritt die Treppe und die Stiege krumm.'), 'de', 'enough German words');
is(GetLanguages('Le chat fait la même chose et ne chante pas.'), 'fr', 'enough French words');
is(GetLanguages('Die Katze tritt die Treppe und die Stiege krumm. ' # 4 matches
		. 'Le chat fait la même chose et ne chante pas.'    # 5 matches
   ), 'fr,de', 'both German and French');

is(GetLanguage('This is English text and cannot be identified.'), 'en', 'now it defaults to English');
is(GetLanguage('Die Katze tritt die Treppe krumm.'), 'en', 'not enough German words but it defaults to English');
is(GetLanguage('Die Katze tritt die Treppe krumm und so.'), 'de', 'three German words');
is(GetLanguage('Die Katze tritt die Treppe und die Stiege krumm. ' # 4 matches
	       . 'Le chat fait la même chose et ne chante pas.'    # 5 matches
   ), 'fr', 'French has the most hits');

my $id = 'Test';
my $text = 'Die Katze tritt die Treppe und die Stiege krumm. ' # 4 matches
    . 'Le chat fait la même chose et ne chante pas.';          # 5 matches

AppendStringToFile($ConfigFile,<<'EOT');
%Languages = ('de' => '\b(der|die|das|und|oder)\b',
	      'fr' => '\b(et|le|la|ne|pas)\b', );
EOT

test_page(update_page($id, $text), /Die Katze/);
test_page(ReadFileOrDie($RcFile), /\bfr,de\b/);
test_page(get_page($id), /lang="fr"/);

done_testing;
