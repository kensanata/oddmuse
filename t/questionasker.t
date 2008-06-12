# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 14;

clear_pages();
add_module('questionasker.pl');

test_page_negative(update_page('test', 'edit allowed'),
		   'edit allowed');
test_page_negative(update_page('test', 'cheating using preview', '', 0, 0, 'Preview=1'),
		   'cheating using preview');
test_page_negative($redirect, 'question%251e1'); # check that cookie is not set after previews
test_page(update_page('test', 'answer question 1', undef, undef, undef,
		      'question_num=1', 'answer=4'),
	  'answer question 1');
test_page($redirect, 'question%251e1'); # check that the cookie is set after correct answer
test_page(update_page('test', 'admin can edit', undef, undef, 1),
	  'admin can edit');
test_page_negative($redirect, 'question%251e1'); # check that cookie is not set after admins
test_page(update_page('test', 'override', undef, undef, undef, "question=1"),
	  'override');
# We cannot check that the cookie is not set after cheating because
# cheating sets the very parameter that ends up in the cookie.

# change key and question
AppendStringToFile($ConfigFile, "\$QuestionaskerSecretKey = 'fnord';\n"
		   . "\$CommentsPrefix = 'Comments on ';\n"
		   . "\@QuestionaskerQuestions = "
		   . "(['say hi' => sub { shift =~ /^hi\$/i }]);\n");
test_page_negative(update_page('test', 'using old key', undef, undef, undef,
			       "question=1"),
		   'using old key');
test_page(update_page('test', 'correct key', undef, undef, undef,
		      "fnord=1"),
	  'correct key');
test_page($redirect, 'fnord%251e1'); # check cookie with new secret
test_page(update_page('test', 'answer new question', undef, undef, undef,
		      'question_num=0', 'answer=hi'),
	  'answer new question');
test_page(get_page('Comments_on_test'),
	  'label for="username"',
	  'say hi');
