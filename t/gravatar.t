# Copyright (C) 2010  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 15;
clear_pages();
add_module('gravatar.pl');

AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

# with homepage

test_page(get_page(join(' ',
			'title=Comments_on_Test1',
			'aftertext="This is my comment"',
			'username=Alex%20Schroeder',
			'homepage=http://oddmuse.org/',
			'mail=alex@gnu.org')),
	  'Status: 302 Found');
my $gravatar = md5_hex('alex@gnu.org');
my $page = get_page('Comments_on_Test1');
xpath_test($page,
	   '//span[@class="portrait gravatar"]',
	   '//p[contains(text(),"This is my comment")]',
	   '//a[@href="http://oddmuse.org/"][text()="Alex Schroeder"]',
	   '//img[@src="http://www.gravatar.com/avatar/' . $gravatar . '"]');

# without homepage

test_page(get_page(join(' ',
			'title=Comments_on_Test2',
			'aftertext="This is my comment"',
			'username=Alex%20Schroeder',
			'mail=alex@gnu.org')),
	  'Status: 302 Found');
my $gravatar = md5_hex('alex@gnu.org');
my $page = get_page('Comments_on_Test2');
xpath_test($page,
	   '//span[@class="portrait gravatar"]',
	   '//p[contains(text(),"This is my comment")]',
	   '//a[@href="http://localhost/wiki.pl/Alex_Schroeder"][text()="Alex Schroeder"]',
	   '//img[@src="http://www.gravatar.com/avatar/' . $gravatar . '"]');

# with homepage an no email

test_page(get_page(join(' ',
			'title=Comments_on_Test3',
			'aftertext="This is my comment"',
			'username=Alex%20Schroeder',
			'homepage=http://oddmuse.org/')),
	  'Status: 302 Found');
my $gravatar = md5_hex('alex@gnu.org');
my $page = get_page('Comments_on_Test3');
xpath_test($page,
	   '//p[text()="This is my comment"]',
	   '//a[@href="http://oddmuse.org/"][text()="Alex Schroeder"]');
negative_xpath_test($page,
		    '//span[@class="portrait gravatar"]',
		    '//img[@src="http://www.gravatar.com/avatar/' . $gravatar . '"]');
