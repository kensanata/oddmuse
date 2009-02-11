#!/usr/bin/env perl
# Copyright (C) 2006, 2007, 2008, 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 107;
clear_pages();

add_module('creole.pl');

# Permit testing of dash-style list markup.
$CreoleDashStyleUnorderedLists = 1;

run_tests(split('\n',<<'EOT'));
# one
<ol><li>one</li></ol>
 # one
<ol><li>one</li></ol>
   #   one
<ol><li>one</li></ol>
# one\n# two
<ol><li>one</li><li>two</li></ol>
# one\n\n# two
<ol><li>one</li><li>two</li></ol>
  *  one
<ul><li>one</li></ul>
* one\n** two\n*** three\n* four
<ul><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li><li>four</li></ul>
 * one\n ** two\n *** three\n * four
<ul><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li><li>four</li></ul>
  -  one
<ul><li>one</li></ul>
- one\n-- Alex
<ul><li>one -- Alex</li></ul>
- one\n\n-- Alex
<ul><li>one</li></ul><p>-- Alex</p>
this is **bold**
this is <strong>bold</strong>
**bold**
<strong>bold</strong>
*item\n**item**
<ul><li>item <strong>item</strong></li></ul>
*item\n\n**item**
<ul><li>item</li></ul><p><strong>item</strong></p>
*item\n** **item**
<ul><li>item<ul><li><strong>item</strong></li></ul></li></ul>
*item\n* **item**
<ul><li>item</li><li><strong>item</strong></li></ul>
//italic//
<em>italic</em>
this is **//bold italic**//italic
this is <strong><em>bold italic</em></strong><em>italic</em>
//**bold italic//**bold
<em><strong>bold italic</strong></em><strong>bold</strong>
= foo
<h1>foo</h1>
== foo
<h2>foo</h2>
=== foo
<h3>foo</h3>
==== foo
<h4>foo</h4>
===== foo
<h5>foo</h5>
====== foo
<h6>foo</h6>
======= foo
<h6 class="h7">foo</h6>
== foo ==
<h2>foo </h2>
========= h9 ======
<h6 class="h9">h9</h6>
== foo = =
<h2>foo =</h2>
== foo\nbar
<h2>foo</h2><p>bar</p>
foo\n\nbar
foo<p>bar</p>
foo\nbar
foo bar
{{{\nfoo\n}}}
<pre class="real">foo</pre>
{{{\nfoo\n}}} bar
{{{ foo }}} bar
{{{\nfoo\n}}} bar \n}}}\n
<pre class="real">foo\n}}} bar </pre>
{{{\nfoo\n}}} bar\n{{{\nfoobar\n}}}
<pre class="real">foo\n}}} bar\n{{{\nfoobar</pre>
{{{\nfoo\n}}}\n
<pre class="real">foo</pre>
{{{foo}}} bar {{{\nbaz\n}}}
<code>foo</code> bar {{{ baz }}}
{{{\nfoo\n}}}\n{{{\nbar\n}}}
<pre class="real">foo</pre><pre class="real">bar</pre>
{{{foo}}}}}}
<code>foo}}}</code>
foo {{{bar}}}
foo <code>bar</code>
foo {{{bar}}} and {{{baz}}}
foo <code>bar</code> and <code>baz</code>
foo {{{{bar}}}}
foo <code>{bar}</code>
foo {{{*bar*}}}
foo <code>*bar*</code>
{{{[[http://example.org|example]]}}}
<code>[[http://example.org|example]]</code>
----
<hr />
-----
-----
foo -----
foo -----
----\nfoo
<hr /><p>foo</p>
foo\n----
foo <hr />
|a|
<table class="user"><tr><td>a</td></tr></table>
|a
<table class="user"><tr><td>a</td></tr></table>
|a|b|\n|c|d
<table class="user"><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>
|a|b\nc|d
<table class="user"><tr><td>a</td><td>b c</td><td>d</td></tr></table>
|a\\b|\n|c\n\nd|
<table class="user"><tr><td>a<br />b</td></tr><tr><td>c</td></tr></table><p>d|</p>
|a|b|c\n|d|e|\nf|
<table class="user"><tr><td>a</td><td>b</td><td>c</td></tr><tr><td>d</td><td>e</td></tr></table><p>f|</p>
|a|b|c|\n|d|e|f
<table class="user"><tr><td>a</td><td>b</td><td>c</td></tr><tr><td>d</td><td>e</td><td>f</td></tr></table>
|=a|=b|=c|\n|d|e|f|
<table class="user"><tr><th>a</th><th>b</th><th>c</th></tr><tr><td>d</td><td>e</td><td>f</td></tr></table>
|=a|b|c|\n|=d|e|f|
<table class="user"><tr><th>a</th><td>b</td><td>c</td></tr><tr><th>d</th><td>e</td><td>f</td></tr></table>
| a| b| c\n| d | e | f |
<table class="user"><tr><td align="right">a</td><td align="right">b</td><td align="right">c</td></tr><tr><td align="center">d </td><td align="center">e </td><td align="center">f </td></tr></table>
|a||c\n||e|f|
<table class="user"><tr><td>a</td><td colspan="2">c</td></tr><tr><td colspan="2">e</td><td>f</td></tr></table>
~#1
#1
~http://www.foo.com/
http://www.foo.com/
~CamelCaseLink
CamelCaseLink
~ does not escape whitespace
~ does not escape whitespace
foo ~bar
foo bar
EOT

xpath_run_tests(split('\n',<<'EOT'));
== [[http://foo.org]]
//h2/a[@class="url http outside"][@href="http://foo.org"][text()="http://foo.org"]
EOT

$CreoleTildeAlternative = 1;

# subtle differences
run_tests(split('\n',<<'EOT'));
~#1
#1
~http://www.foo.com/
http://www.foo.com/
~CamelCaseLink
~CamelCaseLink
~ does not escape whitespace
~ does not escape whitespace
foo ~bar
foo ~bar
EOT

$CreoleLineBreaks = 1;

run_tests(split('\n',<<'EOT'));
foo\nbar
foo<br />bar
* foo\n* bar
<ul><li>foo</li><li>bar</li></ul>
foo\\\nbar
foo<br />bar
EOT

# Mixed lists are not supported
# - Item 1\n- Item 2\n## Item 2.1\n## Item 2.2
# <ul><li>Item 1</li><li>Item 2<ol><li>Item 2.1</li><li>Item 2.2</li></ol></li></ul>

update_page('InterMap', " Ohana http://www.wikiohana.org/\n", 0, 0, 1);
update_page('link', 'test');
update_page('pic', 'test');
ReInit();

xpath_run_tests(split('\n',<<'EOT'));
[[http://www.wikicreole.org/]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="http://www.wikicreole.org/"]
http://www.wikicreole.org/
//a[@class="url http"][@href="http://www.wikicreole.org/"][text()="http://www.wikicreole.org/"]
http://www.wikicreole.org/.
//a[@class="url http"][@href="http://www.wikicreole.org/"][text()="http://www.wikicreole.org/"]
[[http://www.wikicreole.org/|Visit the **WikiCreole** website]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the "][strong[text()="WikiCreole"]][text()=" website"]
[[http://www.wikicreole.org/|//Visit the\nWikiCreole website//]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][em[text()="Visit the WikiCreole website"]]
[[http://www.wikicreole.org/ | Visit the WikiCreole website]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the WikiCreole website"]
[[link]]
//a[text()="link"]
[[link|Go to my page]]
//a[@class="local"][@href="http://localhost/test.pl/link"][text()="Go to my page"]
[[link|Go to\nmy page]]
//a[@class="local"][@href="http://localhost/test.pl/link"][text()="Go to my page"]
{{pic}}
//a[@class="image"][@href="http://localhost/test.pl/pic"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="pic"]]
[[link|{{pic}}]]
//a[@class="image"][@href="http://localhost/test.pl/link"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="link"]]
[[link|{{http://example.com/}}]]
//a[@class="image"][@href="http://localhost/test.pl/link"][img[@class="url outside"][@src="http://example.com/"][@alt="link"]]
[[http://example.com/|{{pic}}]]
//a[@class="image outside"][@href="http://example.com/"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="http://example.com/"]]
{{http://example.com/}}
//a[@class="image outside"][@href="http://example.com/"][img[@class="url outside"][@src="http://example.com/"]]
[[http://example.com/|{{http://mu.org/}}]]
//a[@class="image outside"][@href="http://example.com/"][img[@class="url outside"][@src="http://mu.org/"]]
{{pic|a description}}
//a[@class="image"][@href="http://localhost/test.pl/pic"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="a description"]]
[[link|{{pic|a description}}]]
//a[@class="image"][@href="http://localhost/test.pl/link"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="a description"]]
[[link|{{http://example.com/|a description}}]]
//a[@class="image"][@href="http://localhost/test.pl/link"][img[@class="url outside"][@src="http://example.com/"][@alt="a description"]]
[[http://example.com/|{{pic|a description}}]]
//a[@class="image outside"][@href="http://example.com/"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="a description"]]
{{http://example.com/|a description}}
//a[@class="image outside"][@href="http://example.com/"][img[@class="url outside"][@src="http://example.com/"][@alt="a description"]]
[[http://example.com/|{{http://mu.org/|a description}}]]
//a[@class="image outside"][@href="http://example.com/"][img[@class="url outside"][@src="http://mu.org/"][@alt="a description"]]
[[Ohana:WikiFamily]]
//div/child::node()[1]/self::a[@class="inter Ohana"][@href="http://www.wikiohana.org/WikiFamily"]/span[@class="site"][text()="Ohana"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="page"][text()="WikiFamily"]
|[[http://www.wikicreole.org/|Visit the WikiCreole website]]
//table[@class="user"]/tr/td/a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the WikiCreole website"]
|[[http://www.wikicreole.org/| Visit the WikiCreole website]]
//table[@class="user"]/tr/td/a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the WikiCreole website"]
http://www.foo.com/~bar/
//a[@class="url http"][@href="http://www.foo.com/~bar/"][text()="http://www.foo.com/~bar/"]
InterMap
//a[@class="local"][@href="http://localhost/test.pl/InterMap"][text()="InterMap"]
EOT

xpath_test(update_page('test','{{pic}}'),
     '//a[@class="image"][@href="http://localhost/wiki.pl/pic"][img[@class="upload"][@src="http://localhost/wiki.pl/download/pic"][@alt="pic"]]');
# Make sure not problem exists with caching
$page = get_page('test');
xpath_test($page,
     '//a[@class="image"][@href="http://localhost/wiki.pl/pic"][img[@class="upload"][@src="http://localhost/wiki.pl/download/pic"][@alt="pic"]]');
negative_xpath_test($page,
        '//a[@class="image"]/following-sibling::a[@class="image"]');


xpath_test(update_page('source', 'this is a [[link]].'),
     '//a[text()="link"]');
negative_xpath_test(get_page('source'),
        '//a[text()="link"]/following-sibling::a[text()="link"]');
