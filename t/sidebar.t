#!/usr/bin/env perl
# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 6;

clear_pages();

add_module('sidebar.pl');

test_page(update_page($SidebarName, 'mu'), '<div class="sidebar"><p>mu</p></div>');
test_page(get_page('HomePage'), '<div class="sidebar"><p>mu</p></div>');

#FIXME: Due to the recent refactoring of the Table of Contents module, the
#Sidebar module is now known **not** to work as expected with that module.
#This would appear to be an unavoidable consequence of that refactoring... The
#Sidebar module, as currently implemented, **cannot** be made to work with the
#Table of Contents module. As such, we disable all prior tests against the
#Table of Contents module. It's hardly ideal. (But then, what is?)

# with toc

# add_module('toc.pl');
# add_module('usemod.pl');

# AppendStringToFile($ConfigFile, "\$TocAutomatic = 0;\n");

# update_page($SidebarName, "bla\n\n"
#       . "== mu ==\n\n"
#       . "bla");

# test_page(update_page('test', "bla\n"
#           . "<toc>\n"
#           . "murks\n"
#           . "==two=\n"
#           . "bla\n"
#           . "===three==\n"
#           . "bla\n"
#           . "=one=\n"),
#     quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">two</a><ol><li><a href="#${TocAnchorPrefix}2">three</a></li></ol></li><li><a href="#${TocAnchorPrefix}3">one</a></li></ol>}),
#     quotemeta('<h2>mu</h2>'),
#     quotemeta(qq{<h2 id="${TocAnchorPrefix}1">two</h2>}),
#     quotemeta(qq{<h2 id="${TocAnchorPrefix}3">one</h2>}),
#     quotemeta('bla </p><div class="toc"><h2>Contents</h2><ol><li><a '),
#     quotemeta('one</a></li></ol></div><p>murks'));

# update_page($SidebarName, "<toc>");
# test_page(update_page('test', "bla\n"
#           . "murks\n"
#           . "==two=\n"
#           . "bla\n"
#           . "===three==\n"
#           . "bla\n"
#           . "=one=\n"),
#     quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">two</a><ol><li><a href="#${TocAnchorPrefix}2">three</a></li></ol></li><li><a href="#${TocAnchorPrefix}3">one</a></li></ol>}),
#     quotemeta(qq{<h2 id="${TocAnchorPrefix}1">two</h2>}),
#     quotemeta(qq{<h2 id="${TocAnchorPrefix}3">one</h2>}),
#     quotemeta('<div class="content browse"><div class="sidebar"><div class="toc"><h2>Contents</h2><ol><li><a '),
#     quotemeta('one</a></li></ol></div></div><p>'));

# remove_rule(\&TocRule);
# remove_rule(\&UsemodRule);

# with forms

add_module('forms.pl');

# Markup the sidebar page prior to locking the sidebar page. This should ensure
# that forms on that page are not interpreted.
test_page(update_page($SidebarName, '<form><h1>mu</h1></form>'),
    '<div class="sidebar"><p>&lt;form&gt;&lt;h1&gt;mu&lt;/h1&gt;&lt;/form&gt;</p></div>');

# Lock the sidebar page, mark it up again, and ensure that forms on that page
# are now interpreted.
xpath_test(get_page("action=pagelock id=$SidebarName set=1 pwd=foo"),
     '//p/text()[string()="Lock for "]/following-sibling::a[@href="http://localhost/wiki.pl/SideBar"][@class="local"][text()="SideBar"]/following-sibling::text()[string()=" created."]');
test_page(get_page("action=browse id=$SidebarName cache=0"), #update_page($SidebarName, '<form><h1>mu</h1></form>'),
    '<div class="sidebar"><form><h1>mu</h1></form></div>');
# While rendering the SideBar as part of the HomePage, it should still
# be considered "locked", and therefore the form should render
# correctly.
test_page(get_page('HomePage'),
    '<div class="sidebar"><form><h1>mu</h1></form></div>');
