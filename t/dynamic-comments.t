# Copyright (C) 2011  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 9;

clear_pages();

AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

test_page(update_page('2011-07-06', 'Hallo'),
	  'Comments_on_2011-07-06');
xpath_test(update_page('Hi', '<journal>'),
	  '//h1/a[text()="2011-07-06"]',
	  '//div[@class="journal"]/div[@class="page"]/p[@class="comment"]/a[text()="Comments on this page"]');

add_module('dynamic-comments.pl');

xpath_test(get_page('Hi'),
	   '//div[@class="journal"]/div[@class="page"]/p[@class="comment"]/a[@href="http://localhost/wiki.pl/Comments_on_2011-07-06"][text()="Add Comment"]');

test_page(update_page('Comments_on_2011-07-06', 'Yo'),
	  'Yo');

xpath_test(get_page('Hi'),
	   '//div[@class="journal"]/div[@class="page"]/p[@class="comment"]/a[@href="javascript:togglecomments(\'Comments_on_2011-07-06\')"][text()="Comments on 2011-07-06"]');

update_page('2011-07-06_(…)_Dü', 'Hallo');
update_page('Comments_on_2011-07-06_(…)_Dü', 'Yo');

xpath_test(update_page('Hi', '<journal>'),
	  '//h1/a[text()="2011-07-06 (…) Dü"]',
	  '//div[@class="journal"]/div[@class="page"]/p[@class="comment"]/a[text()="Comments on 2011-07-06 (…) Dü"]',
	  '//div[@class="journal"]/div[@class="page"]/p[@class="comment"]/a[@href="javascript:togglecomments(\'Comments_on_2011-07-06__Dü\')"]');
