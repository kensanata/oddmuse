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
use Test::More tests => 2;

add_module('askpage.pl');

# comment on the ask page get redirected to a question page
get_page('title=Ask aftertext=How%20can%20I%20make%20money%20fast%3f');
test_page(get_page('Question_1'),
	  'How can I make money fast\?');

# the comment on the Ask page says you should ask your questions here
AppendStringToFile($ConfigFile, q{
$CommentsPattern = "^(?|Comments_on_(.*)|$AskPage|$QuestionPage\\d+)\$";
});

test_page(get_page('Ask'), 'Write your question here:');
