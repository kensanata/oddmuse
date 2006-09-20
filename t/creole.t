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
use Test::More tests => 53;
clear_pages();

add_module('creole.pl');

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
- one
<ul><li>one</li></ul>
  - one
<ul><li>one</li></ul>
  *  one
<ul><li>one</li></ul>
# one\n- two
<ol><li>one</li></ol><ul><li>two</li></ul>
  #  one\n  - two
<ol><li>one</li></ol><ul><li>two</li></ul>
- Item 1\n- Item 2\n-- Item 2.1\n-- Item 2.2
<ul><li>Item 1</li><li>Item 2<ul><li>Item 2.1</li><li>Item 2.2</li></ul></li></ul>
* one\n** two\n*** three\n* four
<ul><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li><li>four</li></ul>
this is **bold**
this is <strong>bold</strong>
**bold**
<ul><li>*bold<strong></strong></li></ul>
//italic//
<em>italic</em>
this is **//bold italic**//italic
this is <strong><em>bold italic</em></strong><em>italic</em>
//**bold italic//**bold
<em><strong>bold italic</strong></em><strong>bold</strong>
= foo
= foo
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
<h6>foo</h6>
== foo ==
<h2>foo</h2>
== foo = =
<h2>foo =</h2>
== foo\nbar
<h2>foo</h2><p>bar</p>
== [[foo]]
<h2>[[foo]]</h2>
foo\n\nbar
foo<p>bar</p>
foo\nbar
foo<br />bar
{{{\nfoo\n}}}
<pre class="real">foo\n</pre>
{{{\nfoo}}}
<code>\nfoo</code>
foo {{{bar}}}
foo <code>bar</code>
----
<hr />
-----  
<hr />
  -----
<ul><li>----</li></ul>
foo -----
foo -----
----\nfoo
<hr /><p>foo</p>
foo\n----
foo<hr />
EOT

# Mixed lists are not supported
# - Item 1\n- Item 2\n## Item 2.1\n## Item 2.2
# <ul><li>Item 1</li><li>Item 2<ol><li>Item 2.1</li><li>Item 2.2</li></ol></li></ul>

update_page('link', 'test');
update_page('pic', 'test');

xpath_run_tests(split('\n',<<'EOT'));
[[http://www.wikicreole.org/]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="http://www.wikicreole.org/"]
http://www.wikicreole.org/
//a[@class="url http"][@href="http://www.wikicreole.org/"][text()="http://www.wikicreole.org/"]
http://www.wikicreole.org/.
//a[@class="url http"][@href="http://www.wikicreole.org/"][text()="http://www.wikicreole.org/"]
[[http://www.wikicreole.org/|Visit the WikiCreole website]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the WikiCreole website"]
[[http://www.wikicreole.org/|Visit the\nWikiCreole website]]
//a[@class="url http outside"][@href="http://www.wikicreole.org/"][text()="Visit the\nWikiCreole website"]
[[link]]
//a[text()="link"]
[[link|Go to my page]]
//a[@class="local"][@href="http://localhost/test.pl/link"][text()="Go to my page"]
[[link|Go to\nmy page]]
//a[@class="local"][@href="http://localhost/test.pl/link"][text()="Go to\nmy page"]
{{pic}}
//a[@class="image"][@href="http://localhost/test.pl/pic"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="pic"]]
[[link|{{pic}}]]
//a[@class="image"][@href="http://localhost/test.pl/link"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="link"]]
[[link|{{http://example.com/}}]]
//a[@class="image"][@href="http://localhost/test.pl/link"][img[@class="url outside"][@src="http://example.com/"][@alt="link"]]
[[http://example.com/|{{pic}}]]
//a[@class="image outside"][@href="http://example.com/"][img[@class="upload"][@src="http://localhost/test.pl/download/pic"][@alt="pic"]]
{{http://example.com/}}
//a[@class="image outside"][@href="http://example.com/"][img[@class="url outside"][@src="http://example.com/"]]
[[http://example.com/|{{http://mu.org/}}]]
//a[@class="image outside"][@href="http://example.com/"][img[@class="url outside"][@src="http://mu.org/"]]
EOT
