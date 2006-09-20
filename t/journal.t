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
use Test::More tests => 26;

clear_pages();

update_page('2003-06-13', "Freitag");
update_page('2003-06-14', "Samstag");
update_page('2003-06-15', "Sonntag");

@Test = split('\n',<<'EOT');
This is my journal
2003-06-15
Sonntag
2003-06-14
Samstag
EOT

test_page(update_page('Summary', "This is my journal:\n\n<journal 2>"), @Test);
test_page(update_page('2003-01-01', "This is my journal -- recursive:\n\n<journal>"), @Test);
push @Test, 'journal';
test_page(update_page('2003-01-01', "This is my journal -- truly recursive:\n\n<journal>"), @Test);

test_page(update_page('Summary', "Counting down:\n\n<journal 2>"),
	  '2003-06-15(.|\n)*2003-06-14');

test_page(update_page('Summary', "Counting up:\n\n<journal 3 reverse>"),
	  '2003-01-01(.|\n)*2003-06-13(.|\n)*2003-06-14');

$page = update_page('Summary', "Counting down:\n\n<journal>");
test_page($page, '2003-06-15(.|\n)*2003-06-14(.|\n)*2003-06-13(.|\n)*2003-01-01');
negative_xpath_test($page, '//h1/a[not(text())]');

test_page(update_page('Summary', "Counting up:\n\n<journal reverse>"),
	  '2003-01-01(.|\n)*2003-06-13(.|\n)*2003-06-14(.|\n)*2003-06-15');

AppendStringToFile($ConfigFile, "\$JournalLimit = 2;\n\$ComentsPrefix = 'Talk about ';\n");

$page = update_page('Summary', "Testing the limit of two:\n\n<journal>");
test_page($page, '2003-06-15', '2003-06-14');
test_page_negative($page, '2003-06-13', '2003-01-01');

test_page(get_page('action=browse id=Summary pwd=foo'),
	  '2003-06-15(.|\n)*2003-06-14(.|\n)*2003-06-13(.|\n)*2003-01-01');
