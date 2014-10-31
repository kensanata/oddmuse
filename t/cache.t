# Copyright (C) 2006, 2007  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 8;

clear_pages();

sub get_etag {
  my $str = shift;
  return $1 if $str =~ /Etag: (.*)\r\n/;
}

sub get_last_modified {
  my $str = shift;
  return $1 if $str =~ /Last-Modified: (.*)\r\n/i;
}

# Get the ts from the page db and compare it to the Etag
update_page('CacheTest', 'something');
OpenPage('CacheTest');
my $ts1 = $Page{ts};
my $ts2 = get_etag(get_page('CacheTest'));
ok(abs($ts1 - $ts2) <= 1, "Latest edit of this page: $ts1 and $ts2 are close");

# When updating another page, that page's ts is the new Etag for all of them
update_page('OtherPage', 'something');
OpenPage('OtherPage');
$ts1 = $Page{ts};
$ts2 = get_etag(get_page('OtherPage'));
ok(abs($ts1 - $ts2) <= 1, "Latest edit of other page: $ts1 and $ts2 are close");

# Getting it raw should use the original timestamp
OpenPage('CacheTest');
$ts1 = $Page{ts};
$page = get_page('/raw/CacheTest?');
$ts2 = get_etag($page);
ok(abs($ts1 - $ts2) <= 1, "Latest edit of raw page: $ts1 and $ts2 based on etag are close");

SKIP: {
  eval { require Date::Parse };
  skip ("Date::Parse not installed", 1) if $@;

  $ts2 = Date::Parse::str2time(get_last_modified($page));
  ok(abs($ts1 - $ts2) <= 1, "Latest edit of raw page: $ts1 and $ts2 based on last-modified timestamp are close");
}

$str = 'This is a WikiLink.';

# this setting produces no link.
AppendStringToFile($ConfigFile, "\$WikiLinks = 0;\n");
test_page(update_page('CacheTest', $str, '', 1), $str);

# now change the setting, you still get no link because the cache has
# not been updated.
AppendStringToFile($ConfigFile, "\$WikiLinks = 1;\n");
test_page(get_page('CacheTest'), $str);

# refresh the cache
test_page(get_page('action=clear pwd=foo'), 'Clear Cache');

# now there is a link
# This is a WikiLink<a class="edit" title="Click to edit this page" href="http://localhost/wiki.pl\?action=edit;id=WikiLink">\?</a>.
xpath_test(get_page('CacheTest'), '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=WikiLink"][text()="?"]');
