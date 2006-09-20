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
use Test::More tests => 18;

clear_pages();
add_module('portrait-support.pl');

# nothing
update_page('headers', "[new]foo\n== no header ==\n\ntext\n");
test_page(get_page('headers'),
	  '<div class="color one level0"><p>foo == no header ==</p><p>text</p></div>');

# usemod only
add_module('usemod.pl');
update_page('headers', "[new]foo\n== is header ==\n\ntext\n");
test_page(get_page('headers'), '<div class="color one level0"><p>foo </p></div><h2>is header</h2>');

# usemod + toc only
add_module('toc.pl');
update_page('headers',
	    "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  # default to before the header
	  '<div class="content browse"><div class="color one level0"><p>foo </p></div>',
	  '<div class="toc"><h2>Contents</h2><ol>',
	  '<li><a href="#headers1">one</a></li>',
	  '<li><a href="#headers2">two</a></li>',
	  '<li><a href="#headers3">three</a></li></ol></div>',
	  '<h2 id="headers1">one</h2><p>text </p>',
	  '<h2 id="headers2">two</h2>', );
remove_module('toc.pl');
remove_rule(\&TocRule);
remove_module('usemod.pl');
remove_rule(\&UsemodRule);

# headers only
add_module('headers.pl');
update_page('headers', "[new]foo\nis header\n=========\n\ntext\n");
test_page(get_page('headers'), '<div class="color one level0"><p>foo </p></div><h2>is header</h2>');
remove_module('headers.pl');
remove_rule(\&HeadersRule);

# portrait-support, toc, and usemod

add_module('usemod.pl');
add_module('toc.pl');
update_page('headers', "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#headers1">one</a></li>',
	  '<li><a href="#headers2">two</a></li>',
	  '<div class="color one level0"><p>foo </p></div>',
	  '<h2 id="headers1">one</h2>',
	  '<h2 id="headers2">two</h2>', );

run_tests(split('\n',<<'EOT'));
[new]\nfoo
<div class="color one level0"><p> foo</p></div>
:[new]\nfoo
<div class="color two level1"><p> foo</p></div>
::[new]\nfoo
<div class="color one level2"><p> foo</p></div>
EOT
