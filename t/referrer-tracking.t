# Copyright (C) 2009, 2010  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: referrer-tracking.t,v 1.5 2011/01/22 16:50:06 as Exp $</p>';

require 't/test.pl';
package OddMuse;

use Test::More tests => 10; # update two numbers below!

SKIP: {

  eval {
    require LWP::UserAgent;
  };

  skip "LWP::UserAgent not installed", 10 if $@;

  my $wiki = 'http://localhost/cgi-bin/wiki.pl';
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get("$wiki?action=version");
  skip("No wiki running at $wiki", 10)
    unless $response->is_success;
  skip("Wiki running at $wiki doesn't have the referrer-tracking extension installed", 10)
    unless $response->content =~ /\$Id: referrer-tracking\.pl/;
  my $id = 'Random' . time;
  # make sure we're not being fooled by 404 errors
  $ua->get("$wiki?title=$id;text=test");
  ok($response->is_success, "Created $wiki/$id");
  # this will fail because example.com doesn't really link back (spam protection)
  $response = $ua->get("$wiki/$id", 'Referer' => 'http://example.com/');
  ok($response->is_success, "Request $wiki/$id with faked referrer");
  $response = $ua->get("$wiki?action=refer");
  ok($response->is_success, 'Get list of all referrers');
  negative_xpath_test($response->content,
		      qq{//div[\@class="content refer"]/div/p/a[text()="$id"]});
  # this page must actually exist and link back!
  # http://oddmuse.org/test.html
  $response = $ua->get("$wiki/$id", 'Referer' => 'http://oddmuse.org/test.html');
  ok($response->is_success, "Request $wiki/$id with existing referrer");
  $response = $ua->get("$wiki?action=refer");
  ok($response->is_success, 'Get list of all referrers');
  xpath_test($response->content,
	     '//h1[text()="All Referrers"]',
	     qq{//div[\@class="content refer"]/div[\@class="page"]},
	     qq{//div[\@class="page"]/p/a[\@href="$wiki/$id"][text()="$id"]},
	     qq{//div[\@class="refer"]/p/a[\@href="http://oddmuse.org/test.html"][text()="Tëst"]});
}
