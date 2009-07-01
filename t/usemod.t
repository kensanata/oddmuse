# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 44;

clear_pages();

add_module('usemod.pl');

InitVariables();

run_tests(split('\n',<<'EOT'));
* ''one\n** two
<ul><li><em>one</em><ul><li>two</li></ul></li></ul>
# one\n# two
<ol><li>one</li><li>two</li></ol>
* one\n# two
<ul><li>one</li></ul><ol><li>two</li></ol>
# one\n\n#two
<ol><li>one</li></ol><p>#two</p>
# one\n# two\n## one and two\n## two and three\n# three
<ol><li>one</li><li>two<ol><li>one and two</li><li>two and three</li></ol></li><li>three</li></ol>
# one and #\n# two and # more
<ol><li>one and #</li><li>two and # more</li></ol>
: one\n: two\n:: one and two\n:: two and three\n: three
<dl class="quote"><dt /><dd>one</dd><dt /><dd>two<dl class="quote"><dt /><dd>one and two</dd><dt /><dd>two and three</dd></dl></dd><dt /><dd>three</dd></dl>
: one and :)\n: two and :) more
<dl class="quote"><dt /><dd>one and :)</dd><dt /><dd>two and :) more</dd></dl>
: one\n\n:two
<dl class="quote"><dt /><dd>one</dd></dl><p>:two</p>
; one:eins\n;two:zwei
<dl><dt>one</dt><dd>eins ;two:zwei</dd></dl>
; one:eins\n\n; two:zwei
<dl><dt>one</dt><dd>eins</dd><dt>two</dt><dd>zwei</dd></dl>
; a: b: c\n;; x: y: z
<dl><dt>a</dt><dd>b: c<dl><dt>x</dt><dd>y: z</dd></dl></dd></dl>
* foo <b>bold\n* bar </b>
<ul><li>foo <b>bold</b></li><li>bar </li></ul>
This is ''emphasized''.
This is <em>emphasized</em>.
This is '''strong'''.
This is <strong>strong</strong>.
This is ''longer emphasized'' text.
This is <em>longer emphasized</em> text.
This is '''longer strong''' text.
This is <strong>longer strong</strong> text.
This is '''''emphasized and bold''''' text.
This is <strong><em>emphasized and bold</em></strong> text.
This is ''emphasized '''and bold''''' text.
This is <em>emphasized <strong>and bold</strong></em> text.
This is '''bold ''and emphasized''''' text.
This is <strong>bold <em>and emphasized</em></strong> text.
This is ''emphasized text containing '''longer strong''' text''.
This is <em>emphasized text containing <strong>longer strong</strong> text</em>.
This is '''strong text containing ''emph'' text'''.
This is <strong>strong text containing <em>emph</em> text</strong>.
||one||
<table class="user"><tr class="odd first"><td>one</td></tr></table>
||one|| 
<table class="user"><tr class="odd first"><td>one</td><td align="left"> </td></tr></table>
|| one ''two'' ||
<table class="user"><tr class="odd first"><td align="center">one <em>two</em></td></tr></table>
|| one two ||
<table class="user"><tr class="odd first"><td align="center">one two </td></tr></table>
introduction\n\n||one||two||three||\n||||one two||three||
introduction<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table>
||one||two||three||\n||||one two||three||\n\nfooter
<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
||one||two||three||\n||||one two||three||\n\nfooter
<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
|| one|| two|| three||\n|||| one two|| three||\n\nfooter
<table class="user"><tr class="odd first"><td align="right">one</td><td align="right">two</td><td align="right">three</td></tr><tr class="even"><td colspan="2" align="right">one two</td><td align="right">three</td></tr></table><p>footer</p>
||one ||two ||three ||\n||||one two ||three ||\n\nfooter
<table class="user"><tr class="odd first"><td align="left">one </td><td align="left">two </td><td align="left">three </td></tr><tr class="even"><td colspan="2" align="left">one two </td><td align="left">three </td></tr></table><p>footer</p>
|| one || two || three ||\n|||| one two || three ||\n\nfooter
<table class="user"><tr class="odd first"><td align="center">one </td><td align="center">two </td><td align="center">three </td></tr><tr class="even"><td colspan="2" align="center">one two </td><td align="center">three </td></tr></table><p>footer</p>
introduction\n\n||one||two||three||\n||||one two||three||\n\nfooter
introduction<table class="user"><tr class="odd first"><td>one</td><td>two</td><td>three</td></tr><tr class="even"><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
 source
<pre> source</pre>
 source\n etc\n
<pre> source\n etc</pre>
 source\n \n etc\n
<pre> source\n \n etc</pre>
 source\n \n etc\n\nother
<pre> source\n \n etc</pre><p>other</p>
= title =
<h2>title</h2>
==title=
<h2>title</h2>
========fnord=
<h6>fnord</h6>
== nada\nnada ==
== nada nada ==
 == nada ==
<pre> == nada ==</pre>
==[[Free Link]]==
<h2>[[Free Link]]</h2>
EOT

$UseModMarkupInTitles = 1;

run_tests(split('\n',<<'EOT'));
==n&auml;n==
<h2>n&auml;n</h2>
EOT
