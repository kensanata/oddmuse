# Copyright (C) 2006, 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 44;

clear_pages();

$today = CalcDay($Now);
$tomorrow = CalcDay($Now + 24*60*60);
$yesterday = CalcDay($Now - 24*60*60);
$beforeyesterday = CalcDay($Now - 2*24*60*60);

update_page($yesterday, "Freitag");
update_page($today, "Samstag");
update_page($tomorrow, "Sonntag");

# auch die reihenfolge wird getestet
@test = ('This is my journal', $today, 'Samstag', $tomorrow,
	 'Sonntag', "$tomorrow.*$today");

# check that the limit is taken into account
$page = update_page('Summary', "This is my journal:\n\n<journal 2>");
test_page($page, @test);
test_page_negative($page, $yesterday);
# catch loops
test_page(update_page($beforeyesterday, "This is my journal -- recursive:\n\n<journal>"), @test);

test_page(update_page('Summary', "Counting up:\n\n<journal 3 reverse>"),
	  "$beforeyesterday.*$yesterday.*$today");

# now check all pages
$page = update_page('Summary', "Counting down:\n\n<journal>");
test_page($page, "$tomorrow.*$today.*$yesterday.*$beforeyesterday");

# make sure there are no empty pages being printed (this used to be a bug)
negative_xpath_test($page, '//h1/a[not(text())]');

# check reverse order
test_page(update_page('Summary', "Counting up:\n\n<journal reverse>"),
	   "$beforeyesterday.*$yesterday.*$today.*$tomorrow");

# check past; use xpath because $today will also match "Last edited ... by ..."
$page = update_page('Summary', "Only past pages:\n\n<journal past>");
xpath_test($page, "//a[text()='$yesterday']",
	   "//a[text()='$beforeyesterday']");
negative_xpath_test($page, "//a[text()='$today']",
		    "//a[text()='$tomorrow']");

# check future
$page = update_page('Summary', "Only future pages:\n\n<journal future>");
xpath_test($page, "//a[text()='$tomorrow']");
negative_xpath_test($page, "//a[text()='$today']",
		    "//a[text()='$yesterday']",
		    "//a[text()='$beforeyesterday']");

# check $JournalLimit option and comments
AppendStringToFile($ConfigFile, "\$JournalLimit = 2;\n\$CommentsPrefix = 'Talk about ';\n");
$page = update_page('Summary', "Testing the limit of two:\n\n<journal>");
test_page($page, $tomorrow, "Talk_about_$tomorrow", $today, "Talk_about_$today");
test_page_negative($page, $yesterday, $beforeyesterday);

# $JournalLimit does not apply to admins
test_page(get_page('action=browse id=Summary pwd=foo'),
	  "$tomorrow.*$today.*$yesterday.*$beforeyesterday");

# make sure deleted pages don't count (limit is set to two):
update_page($tomorrow, $DeletedPage);
$page = update_page('Summary', "Tomorrow is gone:\n\n<journal>");
test_page($page, "$today.*$yesterday");
test_page_negative($page, $tomorrow, $beforeyesterday);

# Test for page corruption. Start with an empty set of pages and a
# fresh config file because of the $JournalLimit and dynamic pagenames
# used above.
clear_pages();

# Don't use update_page for the first update
# because we don't want to render the page right after creating it.
get_page('title=2009-06-22 text=hugglifuzbubs');
$page = get_page('action=browse raw=1 id=2009-06-22');
test_page($page, 'hugglifuzbubs');
test_page_negative($page, 'blocks');

test_page(update_page('Journal', "This is the journal.\n\n<journal>\n"),
	  'This is the journal',
	  '2009-06-22',
	  'hugglifuzbubs');
test_page(ReadFileOrDie(GetPageFile('2009-06-22')),
	  'blocks: <p>hugglifuzbubs</p>');

# Same test, but with search and tags
add_module('tags.pl');
update_page('2009-06-23', 'penta figurazza [[tag:foo]]');
test_page(update_page('Journal', "This is the journal.\n\n"
		      . "<journal search tag:foo>\n"),
	  '2009-06-23',
	  'penta figurazza');
test_page(ReadFileOrDie(GetPageFile('2009-06-23')),
	  'blocks: <p>penta figurazza');
