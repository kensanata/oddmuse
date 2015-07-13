# Copyright (C) 2006–2015  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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
use Test::More tests => 60;
use utf8;

add_module('links.pl');
AppendStringToFile($ConfigFile, q{
$WikiLinks = 1;
});
update_page('InterMap',
	    " Oddmuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n",
	    'required', 0, 1);

update_page('a', 'Oddmuse:foo(no) [Oddmuse:bar] [Oddmuse:baz text] '
	    . '[Oddmuse:bar(no)] [Oddmuse:baz(no) text] '
	    . '[[Oddmuse:foo_(bar)]] [[[Oddmuse:foo (baz)]]] [[Oddmuse:foo (quux)|text]]');
$InterInit = 0;
InitVariables();

my @Test = map { quotemeta } split('\n',<<'EOT');
"a" -> "Oddmuse:foo"
"a" -> "Oddmuse:bar"
"a" -> "Oddmuse:baz"
"a" -> "Oddmuse:foo_(bar)"
"a" -> "Oddmuse:foo (baz)"
"a" -> "Oddmuse:foo (quux)"
EOT

test_page_negative(get_page('action=links raw=1'), @Test);
test_page(get_page('action=links raw=1 inter=1'), @Test);

@Test = split('\n',<<'EOT');
//a[@class="local"][@href="http://localhost/wiki.pl/a"][text()="a"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="interpage"][text()="foo"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?bar"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="interpage"][text()="bar"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?baz"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="interpage"][text()="baz"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo_(bar)"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="interpage"][text()="foo_(bar)"]
EOT

negative_xpath_test(get_page('action=links'), @Test);
xpath_test(get_page('action=links inter=1'), @Test);

AppendStringToFile($ConfigFile, "\$BracketWiki = 0;\n");

update_page('a', '[[b]] [[[c]]] [[d|e]] FooBar 𝖀𝖓𝖎𝖈𝖔𝖉𝖊𝓦𝓲𝓴𝓲𝓦𝓸𝓻𝓭𝓼 東京 [FooBaz] [FooQuux fnord] ');
$page = get_page('action=links raw=1');

test_page($page, split('\n',<<'EOT'));
"a" -> "b"
"a" -> "c"
"a" -> "FooBar"
"a" -> "𝖀𝖓𝖎𝖈𝖔𝖉𝖊𝓦𝓲𝓴𝓲𝓦𝓸𝓻𝓭𝓼"
"a" -> "FooBaz"
"a" -> "FooQuux"
EOT

test_page_negative($page, '"a" -> "d"');
test_page_negative($page, '"a" -> "東京"'); # WikiWords can only work for languages where capitalization exists.

AppendStringToFile($ConfigFile, "\$BracketWiki = 1;\n");

update_page('a', '[[b]] [[[c]]] [[d|e]] FooBar 𝖀𝖓𝖎𝖈𝖔𝖉𝖊𝓦𝓲𝓴𝓲𝓦𝓸𝓻𝓭𝓼 [FooBaz] [FooQuux fnord] '
	    . 'http://www.oddmuse.org/ [http://www.emacswiki.org/] '
	    . '[http://www.communitywiki.org/ cw]');

@Test1 = split('\n',<<'EOT');
"a" -> "b"
"a" -> "c"
"a" -> "d"
"a" -> "FooBar"
"a" -> "𝖀𝖓𝖎𝖈𝖔𝖉𝖊𝓦𝓲𝓴𝓲𝓦𝓸𝓻𝓭𝓼"
"a" -> "FooBaz"
"a" -> "FooQuux"
EOT

@Test2 = split('\n',<<'EOT');
"a" -> "http://www.oddmuse.org/"
"a" -> "http://www.emacswiki.org/"
"a" -> "http://www.communitywiki.org/"
EOT

$page = get_page('action=links raw=1');
test_page($page, @Test1);
test_page_negative($page, @Test2);
$page = get_page('action=links raw=1 url=1');
test_page($page, @Test1, @Test2);
$page = get_page('action=links raw=1 links=0 url=1');
test_page_negative($page, @Test1);
test_page($page, @Test2);
