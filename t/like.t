# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
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
use utf8;
use Test::More tests => 17;
clear_pages();
add_module('like.pl');
add_module('creole.pl');

# no Like link on an empty page
$page = get_page('Test');
test_page($page, 'This page is empty');
test_page_negative($page, 'I like this');

# Like link doesn't work for empty pages
get_page('action=like id=Test');
$page = get_page('Test');
test_page($page, 'This page is empty');
test_page_negative($page, 'persons? liked this');

# create page and like twice, checking counter
$page = update_page('Test',
                    'Human history began with an act of disobedience, '
                    . 'and it is not unlikely that it will be terminated '
                    . 'by an act of obedience.');
test_page($page, 'Human history', 'I like this');
get_page('action=like id=Test');
test_page(get_page('Test'), '<h4>1 person liked this</h4>');
get_page('action=like id=Test');
$page = get_page('Test');
test_page($page, '<h4>2 persons liked this</h4>');
get_page('action=like id=Test');
$page = get_page('Test');
test_page($page, '<h4>3 persons liked this</h4>');

# verify that we used @MyFooters correctly
test_page_negative($page, '</a>1');

# verify that we didn't introduce more than one newline
OpenPage('Test');
unlike($Page{text}, qr/\n\n\n/, "didn't introduce more newlines");

# let's see whether reconfiguration works using THUMBS UP SIGN
AppendStringToFile($ConfigFile, <<'EOT');
use utf8;
$LikeRegexp      = qr'(\d+) 👍\n\z';
$LikeReplacement = "%d 👍";
$LikeFirst       = "1 👍";
$Translate{"I like this!"} = "Hell Yeah! 👍";
EOT

# wipe the test page and like it
$page = update_page('Test',
                    'The successful revolutionary is a statesman, '
                    . 'the unsuccessful one a criminal.');
test_page($page, "Hell Yeah! 👍");
get_page('action=like id=Test');
test_page(get_page('Test'), '1 👍');
get_page('action=like id=Test');
$page = get_page('Test');
test_page($page, '2 👍');

# wipe config file for another setup in order to test Creole markup
write_config_file();
AppendStringToFile($ConfigFile, <<'EOT');
$LikeRegexp      = qr'\*\*(\d+) persons? liked this\*\*\n\z';
$LikeReplacement = '**%d persons liked this**';
$LikeFirst       = '**1 person liked this**';
EOT
$page = update_page('Test',
                    'Selfish persons are incapable of loving others, '
                    . 'but they are not capable of loving themselves either.');
test_page($page, "I like this!");
get_page('action=like id=Test');
test_page(get_page('Test'), '<strong>1 person liked this</strong>');
get_page('action=like id=Test');
$page = get_page('Test');
test_page($page, '<strong>2 persons liked this</strong>');
