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
use Test::More tests => 30;

clear_pages();

add_module('toc.pl');
add_module('usemod.pl');

InitVariables(); # do this after loading usemod.pl!

# Note that we're not calling TocInit between tests, so we rely on
# them being run in order.
run_tests('== make honey ==\n\nMoo.\n',
          qq{<h2 id="${TocAnchorPrefix}1">make honey</h2><p>Moo.</p>},
          '== make honey ==\nMoo.\n== make honey ==\nMoo.\n',
          qq{<h2 id="${TocAnchorPrefix}2">make honey</h2><p>Moo. </p><h2 id="${TocAnchorPrefix}3">make honey</h2><p>Moo.</p>},
         );

test_page(update_page('toc', "bla\n"
          . "<toc/fnord/mu>\n"
          . "murks\n"
          . "==two=\n"
          . "bla\n"
          . "===three==\n"
          . "bla\n"
          . "=one=\n"),
    quotemeta('<div class="toc fnord mu">'));

# check whether the toc remains in the HTML cache

test_page(get_page('toc'),
    quotemeta('<div class="toc fnord mu">'));

# no cache

test_page(get_page('action=browse id=toc cache=0'),
    quotemeta('<div class="toc fnord mu">'));

# check again!

test_page(get_page('toc'),
    quotemeta('<div class="toc fnord mu">'));

# details of the toc

test_page(update_page('toc', "bla\n"
          . "=one=\n"
          . "blarg\n"
          . "==two==\n"
          . "bla\n"
          . "==two==\n"
          . "mu."),
    quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">one</a></li><li><a href="#${TocAnchorPrefix}2">two</a></li><li><a href="#${TocAnchorPrefix}3">two</a></li></ol>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}1">one</h2>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}2">two</h2>}),
    quotemeta(qq{bla </p><div class="toc"><h2>$TocHeaderText</h2><ol><li><a }),
    quotemeta(qq{two</a></li></ol></div><h2 id="${TocAnchorPrefix}1">one</h2>}));

test_page(update_page('toc', "bla\n"
          . "==two=\n"
          . "bla\n"
          . "===three==\n"
          . "bla\n"
          . "==two==\n"),
    quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">two</a><ol><li><a href="#${TocAnchorPrefix}2">three</a></li></ol></li><li><a href="#${TocAnchorPrefix}3">two</a></li></ol>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}1">two</h2>}),
    quotemeta(qq{<h3 id="${TocAnchorPrefix}2">three</h3>}));

test_page(update_page('toc', "bla\n"
          . "<toc>\n"
          . "murks\n"
          . "==two=\n"
          . "bla\n"
          . "===three==\n"
          . "bla\n"
          . "=one=\n"),
    quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">two</a><ol><li><a href="#${TocAnchorPrefix}2">three</a></li></ol></li><li><a href="#${TocAnchorPrefix}3">one</a></li></ol>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}1">two</h2>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}3">one</h2>}),
    quotemeta(qq{bla </p><div class="toc"><h2>$TocHeaderText</h2><ol><li><a }),
    quotemeta('one</a></li></ol></div><p>murks'));

test_page(update_page('toc', "bla\n"
          . "=one=\n"
          . "blarg\n"
          . "==two==\n"
          . "<nowiki>bla\n"
          . "==two==\n"
          . "mu.</nowiki>\n"
          . "<nowiki>bla\n"
          . "==two==\n"
          . "mu.</nowiki>\n"
          . "yadda <code>bla\n"
          . "==two==\n"
          . "mu.</code>\n"
          . "yadda <pre> has no effect! \n"
          . "##bla\n"
          . "==three==\n"
          . "mu.##\n"
          . "=one=\n"
          . "blarg </pre>\n"),
    quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">one</a></li><li><a href="#${TocAnchorPrefix}2">two</a></li><li><a href="#${TocAnchorPrefix}3">three</a></li><li><a href="#${TocAnchorPrefix}4">one</a></li></ol>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}1">one</h2>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}2">two</h2>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}3">three</h2>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}4">one</h2>}));

add_module('markup.pl');

test_page(update_page('toc', "bla\n"
          . "=one=\n"
          . "blarg\n"
          . "<code>##bla\n"
          . "=two=\n"
          . "mu.</code>\n"
          . "##bla\n"
          . "=three=\n"
          . "mu.##\n"
          . "=four=\n"
          . "blarg\n"),
    quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">one</a></li><li><a href="#${TocAnchorPrefix}2">four</a></li></ol>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}1">one</h2>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}2">four</h2>}));

test_page(update_page('toc', "bla\n"
          . "=one=\n"
          . "blarg ##<code>## and <code>##</code>\n"
          . "=two=\n"
          . "blarg ##</code>##\n"),
    quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">one</a></li><li><a href="#${TocAnchorPrefix}2">two</a></li></ol>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}1">one</h2>}),
    quotemeta(qq{<h2 id="${TocAnchorPrefix}2">two</h2>}));
