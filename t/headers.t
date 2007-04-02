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
use Test::More tests => 13;

clear_pages();

# without portrait-support

# nothing
update_page('headers', "== no header ==\n\ntext\n");
test_page(get_page('headers'), '== no header ==');

# usemod only
add_module('usemod.pl');
update_page('headers', "== is header ==\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');

# toc + usemod only
add_module('toc.pl');
update_page('headers', "== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#toc1">one</a></li>',
	  '<li><a href="#toc2">two</a></li>',
	  '<h2 id="toc1">one</h2>',
	  '<h2 id="toc2">two</h2>', );
remove_module('usemod.pl');
remove_rule(\&UsemodRule);

# toc + headers
add_module('headers.pl');
update_page('headers', "one\n===\ntext\ntwo\n---\ntext\nthree\n====\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#toc1">one</a>',
	  '<ol><li><a href="#toc2">two</a></li></ol>',
	  '<li><a href="#toc3">three</a></li>',
	  '<h2 id="toc1">one</h2>',
	  '<h3 id="toc2">two</h3>',
	  '<h2 id="toc3">three</h2>', );
remove_module('toc.pl');
remove_rule(\&TocRule);

# headers only
update_page('headers', "is header\n=========\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');
