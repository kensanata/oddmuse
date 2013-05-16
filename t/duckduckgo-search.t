# Copyright (C) 2007–2013  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 9;
clear_pages();

add_module('duckduckgo-search.pl');

DuckDuckGoSearchInit();
is($DuckDuckGoSearchDomain, undef, 'No $ScriptName');

$DuckDuckGoSearchDomain = undef;
$ScriptName = 'http://www.communitywiki.org/en';
DuckDuckGoSearchInit();
is($DuckDuckGoSearchDomain, 'communitywiki.org', $ScriptName);

$DuckDuckGoSearchDomain = undef;
$ScriptName = 'http://www.community.org:80/';
DuckDuckGoSearchInit();
is($DuckDuckGoSearchDomain, 'community.org', $ScriptName);

$DuckDuckGoSearchDomain = undef;
$ScriptName = 'http://www.communitywiki.org';
DuckDuckGoSearchInit();
is($DuckDuckGoSearchDomain, 'communitywiki.org', $ScriptName);

$DuckDuckGoSearchDomain = undef;
$ScriptName = 'http://emacswiki.org/cgi-bin/emacs';
DuckDuckGoSearchInit();
is($DuckDuckGoSearchDomain, 'emacswiki.org', $ScriptName);

$DuckDuckGoSearchDomain = undef;
$ScriptName = 'http://localhost/wiki.pl';
DuckDuckGoSearchInit();
isnt($DuckDuckGoSearchDomain, 'localhost', $ScriptName);

test_page(get_page('search=alex'),
	  '<title>Wiki: Search for: alex</title>');
AppendStringToFile($ConfigFile, "\$ScriptName = 'http://emacswiki.org/';\n");
test_page(get_page('search=alex'),
	  'Status: 302',
	  'Location: https://www.duckduckgo.com/\?q=alex\+site%3Aemacswiki\.org');
