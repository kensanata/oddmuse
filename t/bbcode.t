# Copyright (C) 2007, 2008  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 39;

clear_pages();

add_module('bbcode.pl');

run_tests(split('\n',<<'EOT'));
[b]this text is bold[/b]
<b>this text is bold</b>
[i]this text is italic[/i]
<i>this text is italic</i>
[u]this text is underlined[/u]
<em style="text-decoration: underline; font-style: normal;">this text is underlined</em>
[s]this text is deleted[/s]
<del>this text is deleted</del>
[strike]this text is deleted[/strike]
<del>this text is deleted</del>
[color=blue]this text is blue[/color]
<em style="color: blue; font-style: normal;">this text is blue</em>
[size=+2]this text is two sizes larger than normal[/size]
<em style="font-size: 200%; font-style: normal;">this text is two sizes larger than normal</em>
[size=test]this text is two sizes larger than normal[/size]
[size=test]this text is two sizes larger than normal[/size]
[font=courier]this text is in the courier font[/font]
<span style="font-family: courier;">this text is in the courier font</span>
[url]yadda
[url]yadda
[quote]quoted text[/quote]
<blockquote><p>quoted text</p></blockquote>
[quote]first paragraph\n\nsecond paragraph[/quote]
<blockquote><p>first paragraph</p><p>second paragraph</p></blockquote>
[quote]quoted text[/quote]\nmore text
<blockquote><p>quoted text</p></blockquote><p>more text</p>
[quote]quoted text[/quote]\nmore text\nand some more\n
<blockquote><p>quoted text</p></blockquote><p>more text and some more</p>
[quote]quoted text[/quote]\n more text
<blockquote><p>quoted text</p></blockquote><p> more text</p>
[quote]quoted\ntext\n[/quote]\n more text\n
<blockquote><p>quoted text </p></blockquote><p> more text</p>
[code]monospaced text[/code]
<pre>monospaced text</pre>
[code]monospaced\n\n text[/code]
<pre>monospaced\n\n text</pre>
[code]monospaced text[/code]\nmore text
<pre>monospaced text</pre><p>more text</p>
[code]monospaced text[/code]\n more text
<pre>monospaced text</pre><p> more text</p>
[code]monospaced text[/code]\nmore text\nand last line
<pre>monospaced text</pre><p>more text and last line</p>
:) :-) :( :-(
&#x263a; &#x263a; &#x2639; &#x2639;
:smile: :happy: :frown: :sad:
&#x263a; &#x263a; &#x2639; &#x2639;
foo\n[h1]blarg
foo <h1>blarg</h1>
foo[h2]blarg[/h2]fnord
foo<h2>blarg</h2><p>fnord</p>
[h3]blarg [i]moo[/i][/h3]
<h3>blarg <i>moo</i></h3>
[h5][h6]blarg[/h6]foo
<h5></h5><h6>blarg</h6><p>foo</p>
[center][size=5]The Savage Tides[/size][/center]
<div class="center" style="text-align: center"><p><em style="font-size: 500%; font-style: normal;">The Savage Tides</em></p></div>
[left]This is left[/left]
<div class="left" style="float: left"><p>This is left</p></div>
[right]This is right[/right]
<div class="right" style="float: right"><p>This is right</p></div>
[list]\n[*]one\n[*]two\n[/list]
<ul> <li>one </li><li>two </li></ul>
[quote][list][*]one[*]two[/list][/quote]
<blockquote></blockquote><ul><li>one</li><li>two</li></ul><p>[/quote]</p>
[highlight]this text is highlighted[/highlight]
<strong class="highlight">this text is highlighted</strong>
EOT

xpath_run_tests(split('\n',<<'EOT'));
[url]http://wikipedia.org[/url]
//a[@class="url http"][@href="http://wikipedia.org"][text()="http://wikipedia.org"]
[url=http://wikipedia.org]Wikipedia[/url]
//a[@class="url http"][@href="http://wikipedia.org"][text()="Wikipedia"]
[img]http://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Wikipedia-logo.png/150px-Wikipedia-logo.png[/img]
//img[@class="url http"][@src="http://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Wikipedia-logo.png/150px-Wikipedia-logo.png"]
[H4][url=http://example.org]mu[/url][/h4]
//h4/a[@class="url http"][@href="http://example.org"][text()="mu"]
EOT

add_module('creole.pl');

run_tests(split('\n',<<'EOT'));
* [s]this text is deleted[/s]
<ul><li><del>this text is deleted</del></li></ul>
EOT

test_page(update_page('test', '[b]Important:[/b]'),
	  '<b>Important:</b>');
