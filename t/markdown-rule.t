#!/usr/bin/env perl
# Copyright (C) 2014–2019  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 68;

add_module('markdown-rule.pl');
add_module('bbcode.pl');

# ApplyRules strips trailing newlines, so write tests accordingly.
run_tests(split(/\n/,<<'EOT'));
1. one
<ol><li>one</li></ol>
 2. one
 2. one
1. one\n2. two
<ol><li>one</li><li>two</li></ol>
1. one\n\n2. two
<ol><li>one</li><li>two</li></ol>
1. one\n    2. two\n    3. three
<ol><li>one<ol><li>two</li><li>three</li></ol></li></ol>
1. one\n\n    2. two\n\n    3. three
<ol><li>one<ol><li>two</li><li>three</li></ol></li></ol>
-  one
<ul><li>one</li></ul>
- one\n-- Alex
<ul><li>one -- Alex</li></ul>
- one\n\n- Alex
<ul><li>one</li><li>Alex</li></ul>
* one\n    * two
<ul><li>one<ul><li>two</li></ul></li></ul>
* one\n    * two\n* three
<ul><li>one<ul><li>two</li></ul></li><li>three</li></ul>
1. one\n- two
<ol><li>one</li></ol><ul><li>two</li></ul>
this is ***bold italic*** yo!
this is <em><strong>bold italic</strong></em> yo!
this is **bold**
this is <strong>bold</strong>
**bold**
<strong>bold</strong>
*italic*
<em>italic</em>
*italic* less.
<em>italic</em> less.
*italic.* more.
<em>italic.</em> more.
__underline__
<em style="font-style: normal; text-decoration: underline">underline</em>
_underline_
<em style="font-style: normal; text-decoration: underline">underline</em>
_italic._ more.
<em style="font-style: normal; text-decoration: underline">italic.</em> more.
//italic//
<em>italic</em>
/italic/
<em>italic</em>
/italic./ more.
<em>italic.</em> more.
foo\nbar
foo bar
foo\n===\nbar
<h2>foo</h2><p>bar</p>
foo\n---\nbar
<h3>foo</h3><p>bar</p>
foo\n=== bar
foo === bar
foo\n=\nbar
<h2>foo</h2><p>bar</p>
# foo
<h1>foo</h1>
## foo
<h2>foo</h2>
### foo
<h3>foo</h3>
#### foo
<h4>foo</h4>
##### foo
<h5>foo</h5>
###### foo
<h6>foo</h6>
####### foo
<h6># foo</h6>
## foo ##
<h2>foo ##</h2>
bar\n##foo\nbar
bar <h2>foo</h2><p>bar</p>
this is #foo tag
this is #foo tag
```\nfoo\n```\nbar
<pre>foo</pre><p>bar</p>
```\nfoo\n```
<pre>foo</pre>
```\nfoo\n``` bar
``` foo ``` bar
`bar`
<code>bar</code>
"""\n*foo*\n"""\nhallo
<blockquote><p><em>foo</em></p></blockquote><p>hallo</p>
> *foo*\nhallo
<blockquote><p><em>foo</em></p></blockquote><p>hallo</p>
|a|b|\n|c|d|\nbar
<table><tr><th>a</th><th>b</th></tr><tr><td>c</td><td>d</td></tr></table><p>bar</p>
|a|b|\n|c|d|
<table><tr><th>a</th><th>b</th></tr><tr><td>c</td><td>d</td></tr></table>
|a
<table><tr><th>a</th></tr></table>
|*foo*
<table><tr><th><em>foo</em></th></tr></table>
|/foo/
<table><tr><th><em>foo</em></th></tr></table>
|_foo_
<table><tr><th><em style="font-style: normal; text-decoration: underline">foo</em></th></tr></table>
| a| b|\n| c| d|
<table><tr><th style="text-align: right">a</th><th style="text-align: right">b</th></tr><tr><td style="text-align: right">c</td><td style="text-align: right">d</td></tr></table>
| a | b |\n| c | d |
<table><tr><th style="text-align: center">a</th><th style="text-align: center">b</th></tr><tr><td style="text-align: center">c</td><td style="text-align: center">d</td></tr></table>
foo ~~bar~~
foo <del>bar</del>
pay 1.-/month
pay 1.-/month
EOT

xpath_run_tests(split(/\n/,<<'EOT'));
[example](http://example.com/)
//a[@class="url"][@href="http://example.com/"][text()="example"]
[an example](http://example.com/)
//a[@class="url"][@href="http://example.com/"][text()="an example"]
[an example](http://example.com/ "Title")
//a[@class="url"][@href="http://example.com/"][@title="Title"][text()="an example"]
[an\nexample](http://example.com/)
//a[@class="url"][@href="http://example.com/"][text()="an\nexample"]
\n[an\n\nexample](http://example.com/)
//p[text()="[an"]/following-sibling::p//text()[contains(string(),"example](")]
EOT

# test the quote again, writing an actual page
test_page(update_page('cache', qq{"""\n*foo*\n"""\nhallo}),
	  '<blockquote><p><em>foo</em></p></blockquote><p>hallo</p>');
# test the page again to find errors in dirty block marking
test_page(get_page('cache'),
	  '<blockquote><p><em>foo</em></p></blockquote><p>hallo</p>');

# test the other quote again, writing an actual page
test_page(update_page('cache', qq{> *foo*\n> bar\nhallo}),
	  '<blockquote><p><em>foo</em> bar</p></blockquote><p>hallo</p>');
# test the page again to find errors in dirty block marking
test_page(get_page('cache'),
	  '<blockquote><p><em>foo</em> bar</p></blockquote><p>hallo</p>');

@MyRules = grep { $_ ne \&MarkdownExtraRule } @MyRules;

run_tests(split(/\n/,<<'EOT'));
__underline__
__underline__
_underline_
_underline_
//italic//
//italic//
/italic/
/italic/
EOT
