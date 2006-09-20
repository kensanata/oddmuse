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
use Test::More tests => 17;

clear_pages();

add_module('sidebar.pl');

test_page(update_page('SideBar', 'mu'), '<div class="sidebar"><p>mu</p></div>');
test_page(get_page('HomePage'), '<div class="sidebar"><p>mu</p></div>');

# with toc

add_module('toc.pl');
add_module('usemod.pl');

AppendStringToFile($ConfigFile, "\$TocAutomatic = 0;\n");

update_page('SideBar', "bla\n\n"
	    . "== mu ==\n\n"
	    . "bla");

test_page(update_page('test', "bla\n"
		      . "<toc>\n"
		      . "murks\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "=one=\n"),
	  quotemeta('<ol><li><a href="#test1">two</a><ol><li><a href="#test2">three</a></li></ol></li><li><a href="#test3">one</a></li></ol>'),
	  quotemeta('<h2 id="SideBar1">mu</h2>'),
	  quotemeta('<h2 id="test1">two</h2>'),
	  quotemeta('<h2 id="test3">one</h2>'),
	  quotemeta('bla </p><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('one</a></li></ol></div><p> murks'));

update_page('SideBar', "<toc>");
test_page(update_page('test', "bla\n"
		      . "murks\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "=one=\n"),
	  quotemeta('<ol><li><a href="#test1">two</a><ol><li><a href="#test2">three</a></li></ol></li><li><a href="#test3">one</a></li></ol>'),
	  quotemeta('<h2 id="test1">two</h2>'),
	  quotemeta('<h2 id="test3">one</h2>'),
	  quotemeta('<div class="sidebar"><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('one</a></li></ol></div></div><div class="content browse"><p>'));

remove_rule(\&TocRule);
remove_rule(\&UsemodRule);

# with forms

add_module('forms.pl');

test_page(update_page('SideBar', '<form><h1>mu</h1></form>'),
	  '<div class="sidebar"><p>&lt;form&gt;&lt;h1&gt;mu&lt;/h1&gt;&lt;/form&gt;</p></div>');
xpath_test(get_page('action=pagelock id=SideBar set=1 pwd=foo'),
	   '//p/text()[string()="Lock for "]/following-sibling::a[@href="http://localhost/wiki.pl/SideBar"][@class="local"][text()="SideBar"]/following-sibling::text()[string()=" created."]');
test_page(get_page('SideBar'), '<div class="sidebar"><form><h1>mu</h1></form></div>');
# While rendering the SideBar as part of the HomePage, it should still
# be considered "locked", and therefore the form should render
# correctly.
test_page(get_page('HomePage'),
	  '<div class="sidebar"><form><h1>mu</h1></form></div>');
# test_page(get_page('HomePage'), '<div class="sidebar"><p>&lt;form&gt;&lt;h1&gt;mu&lt;/h1&gt;&lt;/form&gt;</p></div>');
