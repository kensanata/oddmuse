# Copyright (C) 2006, 2007  Alex Schroeder <alex@gnu.org>
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
test_page(update_page('headers', "== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n"),
    '<li><a href="#Heading1">one</a></li>',
    '<li><a href="#Heading2">two</a></li>',
    '<h2 id="Heading1">one</h2>',
    '<h2 id="Heading2">two</h2>', );
remove_module('usemod.pl');
remove_rule(\&UsemodRule);

# toc + headers
add_module('headers.pl');
test_page(update_page('headers', "one\n===\ntext\ntwo\n---\ntext\nthree\n====\ntext\n"),
    '<li><a href="#Heading1">one</a>',
    '<ol><li><a href="#Heading2">two</a></li></ol>',
    '<li><a href="#Heading3">three</a></li>',
    '<h2 id="Heading1">one</h2>',
    '<h3 id="Heading2">two</h3>',
    '<h2 id="Heading3">three</h2>', );
remove_module('toc.pl');
remove_rule(\&TocRule);

# headers only
test_page(update_page('headers', "is header\n=========\n\ntext\n"),
    '<h2>is header</h2>');
# update_page('headers', "is header\n=========\n\ntext\n");
# test_page(get_page('headers'), '<h2>is header</h2>');
