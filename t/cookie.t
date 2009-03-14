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

require 't/test.pl';
package OddMuse;
use Test::More tests => 16;

clear_pages();

# Basic usage that broke when I last changed the cookie handling code.
test_page(get_page('username=Alex'), 'Status: 404');
test_page(get_page('action=browse id=Alex'), 'Alex');

# Username
test_page(get_page('action=browse id=HomePage username=Alex'), 'username=Alex');
test_page(get_page('action=browse id=HomePage username=01234567890123456789012345678901234567890123456789'),
	  'username=01234567890123456789012345678901234567890123456789');
test_page(get_page('action=browse id=HomePage username=01234567890123456789012345678901234567890123456789X'),
	  'UserName must be 50 characters or less: not saved');
test_page(get_page('action=browse id=HomePage username=AlexSchroeder'),
	  'username=AlexSchroeder');
test_page(get_page('action=browse id=HomePage username=Alex%20Schroeder'),
	  'username=Alex Schroeder');
AppendStringToFile($ConfigFile, "\$FreeLinks = 0;\n");
test_page(get_page('action=browse id=HomePage username=Alex%20Schroeder'),
	  'Invalid UserName Alex Schroeder: not saved');
test_page(get_page('action=browse id=HomePage username=AlexSchroeder'),
	  'username=AlexSchroeder');
test_page(get_page('action=browse id=HomePage username=Alex'),
	  'Invalid UserName Alex: not saved');
# single words are ok if we switch off $WikiLinks as well!
AppendStringToFile($ConfigFile, "\$WikiLinks = 0;\n");
test_page(get_page('action=browse id=HomePage username=Alex'),
	  'username=Alex');


SKIP: {

  eval { require LWP::UserAgent; };
  skip "LWP::UserAgent not installed", 5 if $@;

  eval { require HTTP::Cookies; };
  skip "HTTP::Cookies not installed", 5 if $@;

  my $wiki = 'http://localhost/cgi-bin/wiki.pl';
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get("$wiki?action=version");
  skip("No wiki running at $wiki", 5)
    unless $response->is_success;

  $ua = LWP::UserAgent->new;
  my $cookie = HTTP::Cookies->new;
  $ua ->cookie_jar($cookie);

  # Set the cookie
  $response = $ua->get("$wiki?action=debug;pwd=foo");
  ok($response->is_success, 'request the page');
  test_page($ua->cookie_jar->as_string, 'Set-Cookie.*: Wiki=pwd%251efoo');
  test_page_negative($response->content, 'pwd');

  # Change the cookie
  $response = $ua->get("$wiki?action=debug;pwd=test");
  test_page($ua->cookie_jar->as_string, 'Set-Cookie.*: Wiki=pwd%251etest');

  # Delete the cookie
  $response = $ua->get("$wiki?action=debug;pwd=");
  test_page($ua->cookie_jar->as_string, 'Set-Cookie.*: Wiki=""');

};
