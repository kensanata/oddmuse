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
use Test::More tests => 19;

use Cwd;
$dir = cwd;
$uri = "file://$dir";
$uri =~ s/ /%20/g; # for cygdrive stuff including spaces

clear_pages();

add_module('localnames.pl');

xpath_test(update_page('LocalNames', "* [http://www.oddmuse.org/ OddMuse]\n"
		       . "* [[ln:$uri/ln.txt]]\n"
		       . "* [[ln:$uri/ln.txt Lion's Namespace]]\n"),
	   '//ul/li/a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="OddMuse"]',
	   '//ul/li/a[@class="url outside ln"][@href="' . $uri . '/ln.txt"][text()="' . $uri . '/ln.txt"]',
	   '//ul/li/a[@class="url outside ln"][@href="' . $uri . '/ln.txt"][text()="Lion\'s Namespace"]');

InitVariables();

xpath_run_tests(split('\n',<<'EOT'));
[http://www.oddmuse.org/ OddMuse]
//a[@class="url http outside"][@href="http://www.oddmuse.org/"][text()="OddMuse"]
OddMuse
//a[@class="near"][@title="LocalNames"][@href="http://www.oddmuse.org/"][text()="OddMuse"]
EOT


# now check whether the integration with InitVariables works
$page = update_page('LocalNamesTest', 'OddMuse [[my blog]]');
xpath_test($page, '//a[@class="near"][@title="LocalNames"][@href="http://www.oddmuse.org/"][text()="OddMuse"]');

SKIP: {

  eval {
    require LWP::UserAgent;
  };

  skip "LWP::UserAgent not installed", 1 if $@;

  xpath_test($page, '//a[@class="near"][@title="LocalNames"][@href="http://lion.taoriver.net/"][text()="my blog"]');

}

# verify that automatic update is off by default
xpath_test(update_page('LocalNamesTest', 'This is an [http://www.example.org/ Example].'),
	   '//a[@class="url http outside"][@href="http://www.example.org/"][text()="Example"]');
negative_xpath_test(get_page('LocalNames'),
		    '//ul/li/a[@class="url http outside"][@href="http://www.example.org/"][text()="Example"]');

# check automatic update
AppendStringToFile($ConfigFile, "\$LocalNamesCollect = 1;\n");

xpath_test(update_page('LocalNamesTest', 'This is an [http://www.example.com/ Example].'),
	   '//a[@class="url http outside"][@href="http://www.example.com/"][text()="Example"]');
xpath_test(get_page('LocalNames'),
	   '//ul/li/a[@class="url http outside"][@href="http://www.example.com/"][text()="Example"]');

$LocalNamesInit = 0;
LocalNamesInit();

xpath_run_tests(split('\n',<<'EOT'));
OddMuse
//a[@class="near"][@title="LocalNames"][@href="http://www.oddmuse.org/"][text()="OddMuse"]
[[Example]]
//a[@class="near"][@title="LocalNames"][@href="http://www.example.com/"][text()="Example"]
EOT

xpath_test(get_page('action=rc days=1 showedit=1'),
	   '//a[@class="local"][text()="LocalNames"]/following-sibling::strong[text()="Local names defined on LocalNamesTest: Example"]');

# more definitions on one page
update_page('LocalNamesTest', 'This is an [http://www.example.org/ Example] for [http://www.emacswiki.org EmacsWiki].');

xpath_test(get_page('action=rc days=1 showedit=1'),
	   '//a[@class="local"][text()="LocalNames"]/following-sibling::strong[text()="Local names defined on LocalNamesTest: EmacsWiki, and Example"]');

update_page('LocalNamesTest', 'This is an [http://www.example.com/ Example] for [http://www.emacswiki.org/ EmacsWiki] and [http://communitywiki.org/ Community Wiki].');

xpath_test(get_page('action=rc days=1 showedit=1'),
	   '//a[@class="local"][text()="LocalNames"]/following-sibling::strong[text()="Local names defined on LocalNamesTest: Community Wiki, EmacsWiki, and Example"]');

update_page('LocalNamesTest', 'This is [http://www.example.com/ one Example].');
xpath_test(get_page('LocalNames'),
	   '//ul/li/a[@class="url http outside"][@href="http://www.example.com/"][text()="one Example"]');

update_page('LocalNamesTest', 'This is [http://www.example.com/ one simple Example].');
negative_xpath_test(get_page('LocalNames'),
		    '//ul/li/a[@class="url http outside"][@href="http://www.example.com/"][text()="one simple Example"]');
AppendStringToFile($ConfigFile, "\$LocalNamesCollectMaxWords = 1;\n");

update_page('LocalNamesTest', 'This is [http://www.example.com/ Example one].');
negative_xpath_test(get_page('LocalNames'),
		    '//ul/li/a[@class="url http outside"][@href="http://www.example.com/"][text()="Example one"]');
