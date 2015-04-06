#!/usr/bin/env perl
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
test_page(update_page('headers', "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n"),
    # default to before the header
    '<div class="content browse"><div class="color one level0"><p>foo </p></div>',
    '<div class="toc"><h2>Contents</h2><ol>',
    qq{<li><a href="#${TocAnchorPrefix}1">one</a></li>},
    qq{<li><a href="#${TocAnchorPrefix}2">two</a></li>},
    qq{<li><a href="#${TocAnchorPrefix}3">three</a></li></ol></div>},
    qq{<h2 id="${TocAnchorPrefix}1">one</h2><p>text </p>},
    qq{<h2 id="${TocAnchorPrefix}2">two</h2>}, );

remove_module('toc.pl');
# The next two are necessary so that toc.pl can be reloaded safely later!
*ApplyRules = *OldTocApplyRules;
*RunMyRules = *RunMyRulesTocOld;
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
test_page(update_page('headers', "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n"),
    qq{<li><a href="#${TocAnchorPrefix}1">one</a></li>},
    qq{<li><a href="#${TocAnchorPrefix}2">two</a></li>},
    '<div class="color one level0"><p>foo </p></div>',
    qq{<h2 id="${TocAnchorPrefix}1">one</h2>},
    qq{<h2 id="${TocAnchorPrefix}2">two</h2>}, );

run_tests(split('\n',<<'EOT'));
[new]\nfoo
<div class="color one level0"><p> foo</p></div>
:[new]\nfoo
<div class="color two level1"><p> foo</p></div>
::[new]\nfoo
<div class="color one level2"><p> foo</p></div>
EOT
