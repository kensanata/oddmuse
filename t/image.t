# Copyright (C) 2006, 2007, 2010  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 33;

clear_pages();

add_module('image.pl');

update_page('bar', 'foo');
update_page('bar_baz', 'foo');
update_page('bar&baz', 'foo');

# make sure encoded filename is ok
test_page(get_page('"bar&baz"'), 'foo');

update_page('InterMap', " Oddmuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n",
	    'required', 0, 1);

update_page('test',
	    '[[image/left/small:bar|alternative text|http://www.foo.com/|more text & stuff|http://www.bar.com/]]');

xpath_run_tests(split('\n',<<'EOT'));
[[image:foo]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=foo;upload=1"][text()="?"]
[[image:bar]]
//a[@class="image"][@href="http://localhost/test.pl/bar"]/img[@class="upload"][@src="http://localhost/test.pl/download/bar"][@alt="bar"]
[[image:bar baz]]
//a[@class="image"][@href="http://localhost/test.pl/bar_baz"]/img[@class="upload"][@src="http://localhost/test.pl/download/bar_baz"][@alt="bar baz"]
[[image:bar&baz]]
//a[@class="image"][@href="http://localhost/test.pl/bar%26baz"]/img[@class="upload"][@src="http://localhost/test.pl/download/bar%26baz"][@alt="bar&baz"]
[[image:foo&bar]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=foo%26bar;upload=1"][text()="?"]
[[image/right:bar baz]]
//a[@class="image right"][@href="http://localhost/test.pl/bar_baz"]/img[@class="upload"][@src="http://localhost/test.pl/download/bar_baz"][@alt="bar baz"]
[[image:bar|alternative text]]
//a[@class="image"][@href="http://localhost/test.pl/bar"]/img[@class="upload"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]
[[image:bar|alternative & encoded text]]
//a[@class="image"][@href="http://localhost/test.pl/bar"]/img[@class="upload"][@src="http://localhost/test.pl/download/bar"][@alt="alternative & encoded text"]
[[image:bar|alternative text|foo]]
//a[@class="image"][@href="http://localhost/test.pl/foo"]/img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]
[[image/left:bar|alternative text|foo]]
//a[@class="image left"][@href="http://localhost/test.pl/foo"]/img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]
[[image:http://example.org/wiki?a=1&b=2]]
//a[@class="image outside"][@href="http://example.org/wiki?a=1&b=2"]/img[@class="upload"][@title=""][@src="http://example.org/wiki?a=1&b=2"][@alt=""]
[[image/left/small:bar|alternative text]]
//a[@class="image left small"][@href="http://localhost/test.pl/bar"]/img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]
[[image:http://example.org/wiki?a=1&b=2|foo|http://example.org/wiki?a=4&b=3]]
//a[@class="image outside"][@href="http://example.org/wiki?a=4&b=3"]/img[@class="upload"][@title="foo"][@src="http://example.org/wiki?a=1&b=2"][@alt="foo"]
[[image/right:bar|alternative text]]
//a[@class="image right"][@href="http://localhost/test.pl/bar"]/img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]
[[image/left:bar|alternative text|http://www.foo.com/]]
//a[@class="image left outside"][@href="http://www.foo.com/"]/img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]
[[image/left:bar|alternative text|http://www.foo.com/ ]]
//a[@class="image left outside"][@href="http://www.foo.com/"]/img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]
[[image/left/small:bar|alternative text|http://www.foo.com/|more text|http://www.bar.com/]]
//a[@class="image left small outside"][@href="http://www.foo.com/"][img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]]/following-sibling::br/following-sibling::span[@class="caption"]/a[@class="image left small outside"][@href="http://www.bar.com/"][text()="more text"]
[[image/left/small:bar|alternative text & stuff|http://www.foo.com/|more text & stuff|http://www.bar.com/]]
//a[@class="image left small outside"][@href="http://www.foo.com/"][img[@class="upload"][@title="alternative text & stuff"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text & stuff"]]/following-sibling::br/following-sibling::span[@class="caption"]/a[@class="image left small outside"][@href="http://www.bar.com/"][text()="more text & stuff"]
[[image/left/small:bar|alternative text|http://www.foo.com/|more text|bar]]
//a[@class="image left small outside"][@href="http://www.foo.com/"][img[@class="upload"][@title="alternative text"][@src="http://localhost/test.pl/download/bar"][@alt="alternative text"]]/following-sibling::br/following-sibling::span[@class="caption"]/a[@class="image left small"][@href="http://localhost/test.pl/bar"][text()="more text"]
[[image:http://www.example.com/]]
//a[@class="image outside"][@href="http://www.example.com/"]/img[@class="upload"][@title=""][@src="http://www.example.com/"][@alt=""]
[[image:http://www.example.com/ ]]
//a[@class="image outside"][@href="http://www.example.com/"]/img[@class="upload"][@title=""][@src="http://www.example.com/"][@alt=""]
[[image: http://www.example.com/]]
//a[@class="image outside"][@href="http://www.example.com/"]/img[@class="upload"][@title=""][@src="http://www.example.com/"][@alt=""]
[[image external:foo]]
//a[@class="image"][@href="/images/foo"]/img[@class="upload"][@title=""][@src="/images/foo"][@alt=""]
[[image external:foo bar]]
//a[@class="image"][@href="/images/foo%20bar"]/img[@class="upload"][@title=""][@src="/images/foo%20bar"][@alt=""]
[[image external:foo|moo]]
//a[@class="image"][@href="/images/foo"]/img[@class="upload"][@title="moo"][@src="/images/foo"][@alt="moo"]
[[image external:foo|moo||the caption]]
//div[@class="image"]/a[@class="image"][@href="/images/foo"][img[@class="upload"][@title="moo"][@src="/images/foo"][@alt="moo"]]/following-sibling::br/following-sibling::span[@class="caption"][text()="the caption"]
[[image:foo/bar|moo||the caption]]
//div[@class="image"]/a[@class="image"][@href="/images/foo/bar"][img[@class="upload"][@title="moo"][@src="/images/foo/bar"][@alt="moo"]]/following-sibling::br/following-sibling::span[@class="caption"][text()="the caption"]
[[image:foo/bar|moo|baz|the caption]]
//div[@class="image"]/a[@class="image"][@href="http://localhost/test.pl/baz"][img[@class="upload"][@title="moo"][@src="/images/foo/bar"][@alt="moo"]]/following-sibling::br/following-sibling::span[@class="caption"][text()="the caption"]
[[image:Oddmuse:foo/bar|moo|Oddmuse:baz/zz|the caption]]
//div[@class="image"]/a[@class="image inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?baz/zz"][img[@class="upload"][@title="moo"][@src="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo/bar"][@alt="moo"]]/following-sibling::br/following-sibling::span[@class="caption"][text()="the caption"]
[[image:Oddmuse:foo/bar|moo|Oddmuse:baz/zz|the caption|Oddmuse:quux]]
//div[@class="image"]/a[@class="image inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?baz/zz"][img[@class="upload"][@title="moo"][@src="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo/bar"][@alt="moo"]]/following-sibling::br/following-sibling::span[@class="caption"][a[@class="image inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?quux"][text()="the caption"]]
[[image:Oddmuse:the foo|moo|Oddmuse:the baz|the caption|Oddmuse:the quux]]
//div[@class="image"]/a[@class="image inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?the%20baz"][img[@class="upload"][@title="moo"][@src="http://www.emacswiki.org/cgi-bin/oddmuse.pl?the%20foo"][@alt="moo"]]/following-sibling::br/following-sibling::span[@class="caption"][a[@class="image inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?the%20quux"][text()="the caption"]]
[[image:Oddmuse:Alex Schröder]]
//div/a[@class="image inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Alex%20Schr%c3%b6der"][img[@class="upload"][@src="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Alex%20Schr%c3%b6der"]]
EOT
