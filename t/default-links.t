# Copyright (C) 2006, 2007, 2008  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 61;

clear_pages();

$AllNetworkFiles = 1;

update_page('HomePage', "This page exists.");
update_page('InterMap', " Oddmuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n PlanetMath http://planetmath.org/encyclopedia/%s.html", 'required', 0, 1);
$InterInit = 0;
$BracketWiki = 0; # old default
InitVariables();

xpath_run_tests(split('\n',<<'EOT'));
[[1]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=1"][text()="?"]
[[0]]
//div[text()="[[0]]"]
[[0a]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=0a"][text()="?"]
file://home/foo/tutorial.pdf
//a[@class="url file"][@href="file://home/foo/tutorial.pdf"][text()="file://home/foo/tutorial.pdf"]
file:///home/foo/tutorial.pdf
//a[@class="url file"][@href="file:///home/foo/tutorial.pdf"][text()="file:///home/foo/tutorial.pdf"]
image inline: [[image:HomePage]]
//a[@class="image"][@href="http://localhost/test.pl/HomePage"]/img[@class="upload"][@src="http://localhost/test.pl/download/HomePage"][@alt="HomePage"]
image inline: [[image:OtherPage]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OtherPage;upload=1"][text()="?"]
traditional local link: HomePage
//a[@class="local"][@href="http://localhost/test.pl/HomePage"][text()="HomePage"]
traditional local link: OtherPage
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OtherPage"][text()="?"]
traditional local link with extra brackets: [HomePage]
//a[@class="local number"][@title="HomePage"][@href="http://localhost/test.pl/HomePage"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
traditional local link with extra brackets: [OtherPage]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OtherPage"][text()="?"]
traditional local link with other text: [HomePage homepage]
//a[@class="local"][@href="http://localhost/test.pl/HomePage"][text()="HomePage"]
traditional local link with other text: [OtherPage other page]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OtherPage"][text()="?"]
free link: [[home page]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=home_page"][text()="?"]
free link: [[other page]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=other_page"][text()="?"]
free link with extra brackets: [[[home page]]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=home_page"][text()="?"]
free link with extra brackets: [[[other page]]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=other_page"][text()="?"]
free link with other text: [[home page|da homepage]]
//text()[string()="free link with other text: [[home page|da homepage]]"]
free link with other text: [[other page|da other homepage]]
//text()[string()="free link with other text: [[other page|da other homepage]]"]
URL: http://www.oddmuse.org/
//a[@class="url http"][@href="http://www.oddmuse.org/"][text()="http://www.oddmuse.org/"]
URL with text: [http://www.oddmuse.org/ name]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="name"]
zero is text: [http://www.oddmuse.org/ 0]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="0"]
URL in text http://www.oddmuse.org/ like this
//text()[string()="URL in text "]/following-sibling::a[@class="url http"][@href="http://www.oddmuse.org/"][text()="http://www.oddmuse.org/"]/following-sibling::text()[string()=" like this"]
URL in brackets: [http://www.oddmuse.org/]
//a[@class="url http number"][@href="http://www.oddmuse.org/"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
URL in brackets with other text: [http://www.oddmuse.org/ oddmuse]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="oddmuse"]
URL in brackets with other text: [[http://www.oddmuse.org/ oddmuse]]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="oddmuse"]
URL in brackets with other text: [http://www.oddmuse.org/|oddmuse]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="oddmuse"]
URL in brackets with other text: [[http://www.oddmuse.org/|oddmuse]]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="oddmuse"]
URL abbreviation: Oddmuse:Link_Pattern
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="page"][text()="Link_Pattern"]
URL abbreviation with extra brackets: [Oddmuse:Link_Pattern]
//a[@class="inter Oddmuse number"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
URL abbreviation with other text: [Oddmuse:Link_Pattern link patterns]
//a[@class="inter Oddmuse outside"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"][text()="link patterns"]
URL abbreviation with meta characters: Oddmuse:Link+Pattern
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link+Pattern"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="page"][text()="Link+Pattern"]
URL abbreviation with meta characters and extra brackets: [Oddmuse:Link+Pattern]
//a[@class="inter Oddmuse number"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link+Pattern"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
URL abbreviation with meta characters and other text: [Oddmuse:Link+Pattern link patterns]
//a[@class="inter Oddmuse outside"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link+Pattern"][text()="link patterns"]
free URL abbreviation: [[Oddmuse:Link Pattern]]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="page"][text()="Link Pattern"]
free URL abbreviation with extra brackets: [[[Oddmuse:Link Pattern]]]
//a[@class="inter Oddmuse number"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
free URL abbreviation with other text: [[Oddmuse:Link Pattern|link patterns]]
//a[@class="inter Oddmuse outside"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"][text()="link patterns"]
free URL abbreviation with meta characters: [[Oddmuse:Link+Pattern]]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%2bPattern"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="page"][text()="Link+Pattern"]
free URL abbreviation with meta characters and extra brackets: [[[Oddmuse:Link+Pattern]]]
//a[@class="inter Oddmuse number"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%2bPattern"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
free URL abbreviation with meta characters and other text: [[Oddmuse:Link+Pattern|link patterns]]
//a[@class="inter Oddmuse outside"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%2bPattern"][text()="link patterns"]
EOT

$AllNetworkFiles = 0;
$BracketWiki = 1;

xpath_run_tests(split('\n',<<'EOT'));
traditional local link: HomePage
//a[@class="local"][@href="http://localhost/test.pl/HomePage"][text()="HomePage"]
traditional local link: OtherPage
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OtherPage"][text()="?"]
traditional local link with extra brackets: [HomePage]
//a[@class="local number"][@title="HomePage"][@href="http://localhost/test.pl/HomePage"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
traditional local link with extra brackets: [OtherPage]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OtherPage"][text()="?"]
traditional local link with other text: [HomePage homepage]
//a[@class="local"][@href="http://localhost/test.pl/HomePage"][text()="homepage"]
traditional local link with other text: [OtherPage other page]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OtherPage"][text()="?"]
free link: [[home page]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=home_page"][text()="?"]
free link: [[other page]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=other_page"][text()="?"]
free link with extra brackets: [[[home page]]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=home_page"][text()="?"]
free link with extra brackets: [[[other page]]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=other_page"][text()="?"]
free link with other text: [[home page|da homepage]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=home_page"][text()="?"]
free link with other text: [[other page|da other homepage]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=other_page"][text()="?"]
URL: http://www.oddmuse.org/
//a[@class="url http"][@href="http://www.oddmuse.org/"][text()="http://www.oddmuse.org/"]
URL in brackets: [http://www.oddmuse.org/]
//a[@class="url http number"][@href="http://www.oddmuse.org/"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
URL in brackets with other text: [http://www.oddmuse.org/ oddmuse]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="oddmuse"]
URL abbreviation: Oddmuse:Link_Pattern
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="page"][text()="Link_Pattern"]
URL abbreviation with extra brackets: [Oddmuse:Link_Pattern]
//a[@class="inter Oddmuse number"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
URL abbreviation with other text: [Oddmuse:Link_Pattern link patterns]
//a[@class="inter Oddmuse outside"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"][text()="link patterns"]
free URL abbreviation: [[Oddmuse:Link Pattern]]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"]/span[@class="site"][text()="Oddmuse"]/following-sibling::span[@class="separator"][text()=":"]/following-sibling::span[@class="page"][text()="Link Pattern"]
free URL abbreviation with extra brackets: [[[Oddmuse:Link Pattern]]]
//a[@class="inter Oddmuse number"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
free URL abbreviation with other text: [[Oddmuse:Link Pattern|link pattern]]
//a[@class="inter Oddmuse outside"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"][text()="link pattern"]
EOT
