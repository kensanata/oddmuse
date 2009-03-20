# Copyright (C) 2006, 2009  Alex Schroeder <alex@gnu.org>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 15;
clear_pages();

add_module('tags.pl');
InitVariables();

$TagFeedIcon = 'http://www.example.org/pics/rss.png';

xpath_run_tests(split('\n',<<'EOT'));
[[tag:foo bar]]
//a[@class="outside tag"][@title="Tag"][@rel="tag"][text()="foo bar"][@href="http://localhost/test.pl?action=rc;rcfilteronly=tag:foo%20bar"]
[[tag:foo bar]]
//a[@class="feed tag"][@title="Feed for this tag"][@href="http://localhost/test.pl?action=rss;rcfilteronly=tag:foo%20bar"][@rel="feed"]/img[@src="http://www.example.org/pics/rss.png"]
EOT

$TagUrl = 'http://technorati.com/tag/%s';
$TagFeed = 'http://feeds.technorati.com/tag/%s';

xpath_run_tests(split('\n',<<'EOT'));
[[tag:foo bar]]
//a[@class="outside tag"][@title="Tag"][@href="http://technorati.com/tag/foo%20bar"][@rel="tag"][text()="foo bar"]
[[tag:foo bar]]
//a[@class="feed tag"][@title="Feed for this tag"][@href="http://feeds.technorati.com/tag/foo%20bar"][@rel="feed"]/img[@src="http://www.example.org/pics/rss.png"]
[[tag:foo bar|mu muh!]]
//a[@class="outside tag"][@title="Tag"][@href="http://technorati.com/tag/foo%20bar"][@rel="tag"][text()="mu muh!"]
EOT

update_page('Brilliant', 'Gameologists [[tag:podcast]] [[tag:mag]]');
update_page('Podgecast', 'Another [[tag:podcast]]');

# open the DB file
require DB_File;
tie %h, "DB_File", $TagFile;

%tag = map {$_=>1} split($FS, $h{"_Brilliant"});
ok($tag{podcast}, 'Brilliant page tagged podcast');
ok($tag{mag}, 'Brilliant page tagged mag');
%tag = map {$_=>1} split($FS, $h{"_Podgecast"});
ok($tag{podcast}, 'Podgecast page tagged podcast');
%file = map {$_=>1} split($FS, $h{"podcast"});
ok($file{Brilliant}, 'Tag podcast applies to page Brilliant');
ok($file{Podgecast}, 'Tag podcast applies to page Podgecast');
%file = map {$_=>1} split($FS, $h{"mag"});
ok($file{Brilliant}, 'Tag mag applies to page Brilliant');

# close the DB file before making changes via the wiki!
untie %h;

update_page('Brilliant', 'Gameologists [[tag:mag]]');

# reopen changed file
tie %h, "DB_File", $TagFile;

%tag = map {$_=>1} split($FS, $h{"_Brilliant"});
ok(!$tag{podcast}, 'Brilliant page no longer tagged podcast');
ok($tag{mag}, 'Brilliant page still tagged mag');
%file = map {$_=>1} split($FS, $h{"podcast"});
ok(!$file{Brilliant}, 'Tag podcast no longer applies to page Brilliant');
ok($file{Podgecast}, 'Tag podcast still applies to page Podgecast');

untie %h;
