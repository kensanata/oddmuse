# Copyright (C) 2006, 2008, 2010  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 16;

add_module('near-links.pl');
AppendStringToFile($ConfigFile, "\$WikiLinks = 1;\n");

CreateDir($NearDir);
WriteStringToFile("$NearDir/EmacsWiki", "AlexSchroeder\nFooBar\n"
		  . "Comments_on_FooBar\nEmacsWiki\n");

update_page('InterMap', " EmacsWiki http://www.emacswiki.org/cgi-bin/wiki/%s\n",
	    'required', 0, 1);
update_page('NearMap', " EmacsWiki"
	    . " http://www.emacswiki.org/cgi-bin/emacs?action=index;raw=1"
	    . " http://www.emacswiki.org/cgi-bin/emacs?search=%s;raw=1;near=0\n",
	    'required', 0, 1);

xpath_test(update_page('FooBaz', "Try FooBar instead!\n"),
	   '//a[@class="near"][@title="EmacsWiki"][@href="http://www.emacswiki.org/cgi-bin/wiki/FooBar"][text()="FooBar"]',
	   '//div[@class="near"]/p/a[@class="local"][@href="http://localhost/wiki.pl/EditNearLinks"][text()="EditNearLinks"]/following-sibling::text()[string()=": "]/following-sibling::a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=FooBar"][text()="FooBar"]');

xpath_test(update_page('FooBar', "Test by AlexSchroeder!\n"),
	  '//div[@class="sister"]/p/a[@title="EmacsWiki:FooBar"][@href="http://www.emacswiki.org/cgi-bin/wiki/FooBar"]/img[@src="file:///tmp/oddmuse/EmacsWiki.png"][@alt="EmacsWiki:FooBar"]');

xpath_test(get_page('search=alexschroeder'),
	   '//p[text()="Near pages:"]',
	   '//a[@class="near"][@title="EmacsWiki"][@href="http://www.emacswiki.org/cgi-bin/wiki/AlexSchroeder"][text()="AlexSchroeder"]');

my $page = get_page('search=FooBar');
xpath_test($page,
	   '//a[@class="local"][@href="http://localhost/wiki.pl/FooBar"][text()="FooBar"]',
	   '//a[@class="near"][@title="EmacsWiki"][@href="http://www.emacswiki.org/cgi-bin/wiki/Comments_on_FooBar"][text()="Comments on FooBar"]',
	   # The pages found: FooBar (locally), FooBaz (locally, because FooBar is in the body), and Comments_on_FooBar
	   # (remote). The remove FooBar must not be counted.
	   '//p[@class="result"][text()="3 pages found."]');

AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

xpath_test(get_page('FooBar'),
	   '//a[@class="comment local"][@href="http://localhost/wiki.pl/Comments_on_FooBar"][text()="Comments on FooBar"]');

xpath_test(get_page('Comments_on_FooBar'),
	   qq{//div[\@class="content browse"]/p[contains(text(),"There are no comments")]});

$page=get_page('action=rc rcfilteronly=alex');
xpath_test($page, '//a[text()="FooBar"]',
	   '//strong[text()="Test by AlexSchroeder! "]');
xpath_test_negative($page, '//p[text()="Near pages:"]',
		    '//a[@class="near"][@title="EmacsWiki"][text()="AlexSchroeder"]');

my @matches = get_page('action=index raw=1 near=1') =~ m/^FooBar$/gm;
is(scalar(@matches), 1, "FooBar listed once when including near pages");

my @matches = get_page('action=index raw=1 pages=0 near=1') =~ m/^FooBar$/gm;
is(scalar(@matches), 1, "FooBar listed once when excluding local pages");
