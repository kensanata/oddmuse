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
use Test::More tests => 5;
clear_pages();

add_module('tags.pl');
InitVariables();

$TagRssIcon = 'http://www.example.org/pics/rss.png';

xpath_run_tests(split('\n',<<'EOT'));
[[tag:foo bar]]
//a[@class="outside tag"][@title="Tag"][@rel="tag"][text()="foo bar"][@href="http://localhost/test.pl?action=rc;rcfilteronly=tag:foo%20bar"]
[[tag:foo bar]]
//a[@class="feed tag"][@title="Feed for this tag"][@href="http://localhost/test.pl?action=rss;rcfilteronly=foo%20bar"][@rel="feed"]/img[@src="http://www.example.org/pics/rss.png"]
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
