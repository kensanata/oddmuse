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
use Test::More tests => 70;
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
update_page('Alex', 'Me! [[tag:Old School]]');

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
%file = map {$_=>1} split($FS, $h{"old_school"});
ok($file{Alex}, 'Tag Old School applies to page Alex');

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

# close the DB file before making changes via the wiki!
untie %h;

DeletePage('Brilliant');

# reopen changed file
tie %h, "DB_File", $TagFile;

ok(!$h{_Brilliant}, 'Brilliant page no longer exists');
ok(!exists($h{mag}), 'No page tagged mag exists');

# close the DB file before making changes via the wiki!
untie %h;

update_page('Brilliant', 'Gameologists [[tag:podcast]] [[tag:mag]]');
update_page('Sons', 'of Kryos [[tag:Podcast]]');
update_page('Alex', 'not a podcast');
update_page('Jeff', 'a blog [[tag:Old School]]');

# ordinary search finds Alex
$page = get_page('search=podcast raw=1');
test_page($page, qw(Podgecast Brilliant Sons Alex));

# tag search skips Alex
$page = get_page('search=tag:podcast raw=1');
test_page($page, qw(Podgecast Brilliant Sons));
test_page_negative($page, qw(Alex));

# tag search is case insensitive
$page = get_page('search=tag:PODCAST raw=1');
test_page($page, qw(Podgecast Brilliant Sons));
test_page_negative($page, qw(Alex));

# exclude tag search skips Brilliant
$page = get_page('search=-tag:mag raw=1');
test_page($page, qw(Podgecast Sons Alex));
test_page_negative($page, qw(Brilliant));

# combine include and exclude tag search to exclude both Alex and
# Brilliant
$page = get_page('search=tag:podcast%20-tag:mag raw=1');
test_page($page, qw(Podgecast Sons));
test_page_negative($page, qw(Brilliant Alex));

# combine ordinary search with include and exclude tag search to
# exclude both Alex and Brilliant
$page = get_page('search=kryos%20tag:podcast%20-tag:mag raw=1');
test_page($page, qw(Sons));
test_page_negative($page, qw(Podgecast Brilliant Alex));

# search for a tag containing spaces
$page = get_page('search=tag:old_school raw=1');
test_page($page, qw(Jeff));
test_page_negative($page, qw(Sons Podgecast Brilliant Alex));

test_page(get_page('action=reindex pwd=foo'),
	  qw(Podgecast Brilliant Sons Alex));

# tag search skips Alex -- repeat test after reindexing
$page = get_page('search=tag:podcast raw=1');
test_page($page, qw(Podgecast Brilliant Sons));
test_page_negative($page, qw(Alex));

add_module('near-links.pl');

CreateDir($NearDir);
WriteStringToFile("$NearDir/EmacsWiki", "AlexSchroeder\nFoo\n");

update_page('InterMap', " EmacsWiki http://www.emacswiki.org/cgi-bin/wiki/%s\n",
	    'required', 0, 1);
update_page('NearMap', " EmacsWiki"
	    . " http://www.emacswiki.org/cgi-bin/emacs?action=index;raw=1\n",
	    'required', 0, 1);

# make sure the near pages are not listed
$page = get_page('search=tag:podcast raw=1');
test_page_negative($page, qw(AlexSchroeder Foo));

# check journal pages
$page = update_page('Podcasts', '<journal "." search tag:podcast>');
test_page($page, qw(Podgecast Brilliant Sons));
test_page_negative($page, qw(Alex Foo));

# check the tag cloud
xpath_test(get_page('action=tagcloud'),
	   '//h1[text()="Tag Cloud"]',
	   '//a[@style="font-size: 200%;"][@href="http://localhost/wiki.pl?search=tag:podcast"][@title="3"][text()="podcast"]',
	   '//a[@style="font-size: 80%;"][@href="http://localhost/wiki.pl?search=tag:old_school"][@title="1"][text()="old school"]',
	   '//a[@style="font-size: 80%;"][@href="http://localhost/wiki.pl?search=tag:mag"][@title="1"][text()="mag"]');

# check interference; in order for this test to work, we need to make
# sure that localnames is loaded first
add_module('localnames.pl');
AppendStringToFile($ConfigFile, "\$LocalNamesCollect = 1;\n");
update_page('LocalNames', 'test');
update_page('Alex', 'is a [[tag:podcast]] after all');
$page = get_page('search=tag:podcast raw=1');
test_page($page, qw(Podgecast Brilliant Sons Alex));
