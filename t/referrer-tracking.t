# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: referrer-tracking.t,v 1.1 2009/02/18 23:11:50 as Exp $</p>';

require 't/test.pl';
package OddMuse;

use Test::More tests => 9;

SKIP: {

  eval {
    require LWP::UserAgent;
  };

  skip "LWP::UserAgent not installed", 9 if $@;

  my $wiki = 'http://localhost/cgi-bin/wiki.pl';
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get("$wiki?action=version");
  skip("No wiki running at $wiki", 9)
    unless $response->is_success;
  skip("Wiki running at $wiki doesn't have the referrer-tracking extension installed", 9)
    unless $response->content =~ /\$Id: referrer-tracking\.pl/;
  $ua->get("$wiki?title=My_Page;text=test");
  # make sure we're not being fooled by 404 errors
  ok($response->is_success, "Created $wiki/My_Page");
  # this will fail because example.com doesn't really link back (spam protection)
  $response = $ua->get("$wiki/My_Page", 'Referer' => 'http://example.com/');
  ok($response->is_success, "Request $wiki/My_Page with faked referrer");
  $response = $ua->get("$wiki?action=refer");
  ok($response->is_success, 'Get list of all referrers');
  negative_xpath_test($response->content,
		      qq{//div[\@class="content refer"]/div[\@class="page"]});
  # this page must actually exist and link back!
  # http://oddmuse.org/test.html
  $response = $ua->get("$wiki/My_Page", 'Referer' => 'http://oddmuse.org/test.html');
  ok($response->is_success, "Request $wiki/My_Page with existing referrer");
  $response = $ua->get("$wiki?action=refer");
  ok($response->is_success, 'Get list of all referrers');
  xpath_test($response->content,
	     '//h1[text()="All Referrers"]',
	     qq{//div[\@class="content refer"]/div[\@class="page"]},
	     qq{//div[\@class="page"]/p/a[\@href="$wiki/My_Page"][text()="My Page"]});
}
