# Copyright (C) 2009–2014  Alex Schroeder <alex@gnu.org>
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

use Test::More tests => 12; # update two numbers below!
use utf8; # tests contain UTF-8 characters and it matters

SKIP: {

  eval {
    require LWP::UserAgent;
  };

  skip "LWP::UserAgent not installed", 12 if $@;

  my $wiki = 'http://localhost/cgi-bin/wiki.pl';
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get("$wiki?action=version");
  skip("No wiki running at $wiki", 12)
    unless $response->is_success;
  # check that the wiki is capable of running these tests
  skip("Wiki running at $wiki doesn't have the Referrer-Tracking Extension installed", 12)
    unless $response->content =~ /referrer-tracking\.pl/;
  # if we're running in some random environment where localhost is not
  # a wiki for us to interact with
  skip("Wiki running at $wiki has the Question Asker Extension installed", 12)
      if $response->content =~ /questionasker\.pl/;

  my $id = 'Random' . time;
  # make sure we're not being fooled by 404 errors
  $response = $ua->get("$wiki?title=$id;text=test");
  ok($response->is_success, "Created $wiki/$id");

  # If the tests are running into a lot of errors here, make sure
  # questionasker.pl and other spam protection is not installed.
  # Also make sure that no german-utf8.pl is installed.

  # This will fail because example.com doesn't really link back (spam protection)
  $response = $ua->get("$wiki/$id", 'Referer' => 'http://example.com/');
  ok($response->is_success, "Request $wiki/$id with faked referrer");

  $response = $ua->get("$wiki?action=refer");
  ok($response->is_success, 'Get list of all referrers');
  negative_xpath_test($response->content,
		      qq{//div[\@class="content refer"]/div/p/a[text()="$id"]});

  # This page must actually exist and link back!
  $response = $ua->get('http://oddmuse.org/test.html');
  ok($response->is_success, "http://oddmuse.org/test.html exists");
  test_page($response->content, $ScriptName);

  # If it is lost, here's what it should contain:

  # <head><title>Tëst</title></head>
  # <body>
  # This file is required for an Oddmuse unit test
  # involving referrer tracking.
  # <a href="http://localhost/cgi-bin/wiki.pl">Test</a>.

  $response = $ua->get("$wiki/$id", 'Referer' => 'http://oddmuse.org/test.html');
  ok($response->is_success, "Request $wiki/$id with existing referrer");
  $response = $ua->get("$wiki?action=refer");
  ok($response->is_success, 'Get list of all referrers');
  xpath_test($response->content,
	     '//h1[text()="All Referrers"]',
	     qq{//div[\@class="content refer"]/div[\@class="page"]},
	     qq{//div[\@class="page"]/p/a[\@href="$wiki/$id"][text()="$id"]},
	     qq{//div[\@class="refer"]/p/a[\@href="http://oddmuse.org/test.html"][text()="Tëst"]});

  # Clean up
  $ua->get("$wiki?title=$id;text=");
}
