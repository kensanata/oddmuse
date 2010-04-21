# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 9;
clear_pages();

add_module('google-search.pl');

GoogleSearchInit();
is($GoogleSearchDomain, undef, 'No $ScriptName');

$GoogleSearchDomain = undef;
$ScriptName = 'http://www.communitywiki.org/en';
GoogleSearchInit();
is($GoogleSearchDomain, 'communitywiki.org', $ScriptName);

$GoogleSearchDomain = undef;
$ScriptName = 'http://www.community.org:80/';
GoogleSearchInit();
is($GoogleSearchDomain, 'community.org', $ScriptName);

$GoogleSearchDomain = undef;
$ScriptName = 'http://www.communitywiki.org';
GoogleSearchInit();
is($GoogleSearchDomain, 'communitywiki.org', $ScriptName);

$GoogleSearchDomain = undef;
$ScriptName = 'http://emacswiki.org/cgi-bin/emacs';
GoogleSearchInit();
is($GoogleSearchDomain, 'emacswiki.org', $ScriptName);

$GoogleSearchDomain = undef;
$ScriptName = 'http://localhost/wiki.pl';
GoogleSearchInit();
isnt($GoogleSearchDomain, 'localhost', $ScriptName);

test_page(get_page('search=alex'),
	  '<title>Wiki: Search for: alex</title>');
AppendStringToFile($ConfigFile, "\$ScriptName = 'http://emacswiki.org/';\n");
test_page(get_page('search=alex'),
	  'Status: 302',
       'Location: http://www.google.com/search\?q=site%3Aemacswiki.org\+alex');
