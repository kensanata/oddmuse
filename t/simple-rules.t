# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 20;

clear_pages();
add_module('simple-rules.pl');

update_page('foo', 'test');
update_page('bar', 'test');
update_page('baz', 'test');

run_tests(split('\n',<<'EOT'));
test
<p>test</p>
foo\n\nbar
<p>foo</p><p>bar</p>
test\n====\n
<h2>test</h2>
test\n----\n
<h3>test</h3>
foo\nbar\n\ntest\n----\n\nfoo\nbar\n
<p>foo\nbar</p><h3>test</h3><p>foo\nbar</p>
* foo\n* bar\n* baz\n
<ul><li>foo</li><li>bar</li><li>baz</li></ul>
1. foo\n2. bar\n3. baz\n
<ol><li>foo</li><li>bar</li><li>baz</li></ol>
~test~ foo
<p><em>test</em> foo</p>
**test foo**
<p><strong>test foo</strong></p>
//test foo//
<p><em>test foo</em></p>
__test foo__
<p><u>test foo</u></p>
*test* foo
<p><b>test</b> foo</p>
/test/ foo
<p><i>test</i> foo</p>
_test_ foo
<p><u>test</u> foo</p>
http://www.oddmuse.org/
<p><a href="http://www.oddmuse.org/">http://www.oddmuse.org/</a></p>
/test/ _test_ *test*
<p><i>test</i> <u>test</u> <b>test</b></p>
EOT

xpath_run_tests(split('\n',<<'EOT'));
[[foo]]
//a[@class="local"][@href="http://localhost/test.pl/foo"][text()="foo"]
this is [[foo]].
//p/a[@class="local"][@href="http://localhost/test.pl/foo"][text()="foo"]
[[foo]] and [[bar]]
//a[text()="foo"]/following::a[text()="bar"]
* some [[foo]]\n* [[bar]] and [[baz]]\n
//ul/li[a[text()="foo"]]/following::li[a[text()="bar"]/following::a[text()="baz"]]
EOT
