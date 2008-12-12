
#!/usr/bin/env perl
# ====================[ crossbar.t                          ]====================

# ....................{ INITIALIZATION                     }....................
require 't/test.pl';
package OddMuse;
use Test::More tests => 22;

clear_pages();
add_module('crossbar.pl');

# The crossbar page is editable only by administrators. Consequently, we enable
# the administrator option when calling the update_page() function on the
# crossbar page.
my @update_crossbar_page_options = ('', '', 1);

# ....................{ TESTS =vanilla                     }....................
test_page(update_page($CrossbarPageName, 'mu', @update_crossbar_page_options),
          '<div class="crossbar"><p>mu</p></div>');
test_page(get_page('HomePage'), '<div class="crossbar"><p>mu</p></div>');

# Verify that raw pages are not mangled
$page = get_page('action=browse raw=1 id=HomePage');
test_page($page, 'This page is empty');
test_page_negative($page, 'mu');

# Verify that images pages are not mangled
AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");
test_page(update_page('Alex', "#FILE image/png\niVBORw0KGgoAAAA"),
	  'This page contains an uploaded file:');
$page = get_page('action=download id=Alex');
$page =~ s/^.*\r\n\r\n//s; # strip headers
require MIME::Base64;
test_page(MIME::Base64::encode($page), '^iVBORw0KGgoAAAA');

# ....................{ TESTS =sidebar                     }....................
add_module('sidebar.pl');

update_page('SideBar', 'mysidebar');
update_page('Crossbar', 'mycrossbar');

$page = get_page('HomePage');
xpath_test($page,
	   '//div[@class="sidebar"]/p[text()="mysidebar"]',
	   '//div[@class="crossbar"]/p[text()="mycrossbar"]');
# verify that these two are not nested
negative_xpath_test($page,
		    '//div[@class="sidebar"]/div[@class="crossbar"]',
		    '//div[@class="crossbar"]/div[@class="sidebar"]');

# uninstall sidebar.pl
remove_module('sidebar.pl');
*GetHeader = *OldSideBarGetHeader;

# ....................{ TESTS =toc                         }....................
add_module('toc.pl');
add_module('usemod.pl');

AppendStringToFile($ConfigFile, "\$TocAutomatic = 0;\n");

# Test a crossbar page without Table of Contents markup and a page with Table of
# Contents markup.
update_page($CrossbarPageName, "bla

== mu ==

bla", @update_crossbar_page_options);
test_page(update_page('test', "bla
<toc>
murks
==two==
bla
===three===
bla
=one="),
          quotemeta(qq{<div class="crossbar"><p>bla</p><h2>mu</h2>}),
          quotemeta(qq{bla </p><div class="toc"><h2>$TocHeaderText</h2>}),
          quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">two</a><ol><li><a href="#${TocAnchorPrefix}2">three</a></li></ol></li><li><a href="#${TocAnchorPrefix}3">one</a></li></ol>}),
          quotemeta(qq{one</a></li></ol></div><p>murks}));
          quotemeta(qq{<h2 id="${TocAnchorPrefix}1">two</h2>}),
          quotemeta(qq{<h2 id="${TocAnchorPrefix}3">one</h2>}),

# Test a crossbar page with Table of Contents markup and a page without Table of
# Contents markup.
update_page($CrossbarPageName, "bla

== mu ==

bla
<toc>", @update_crossbar_page_options);
test_page(update_page('test', "bla
murks
==two==
bla
===three===
bla
=one="),
          quotemeta(qq{<div class="crossbar"><p>bla</p><h2>mu</h2>}),
          quotemeta(qq{<p>bla </p><div class="toc"><h2>$TocHeaderText</h2>}),
          quotemeta(qq{<ol><li><a href="#${TocAnchorPrefix}1">two</a><ol><li><a href="#${TocAnchorPrefix}2">three</a></li></ol></li><li><a href="#${TocAnchorPrefix}3">one</a></li></ol>}),
          quotemeta(qq{one</a></li></ol></div></div><div class="content browse"><p>bla}));
          quotemeta(qq{<h2 id="${TocAnchorPrefix}1">two</h2>}),
          quotemeta(qq{<h2 id="${TocAnchorPrefix}3">one</h2>}),

remove_rule(\&TocRule);
remove_rule(\&UsemodRule);

# ....................{ TESTS =forms                       }....................
add_module('forms.pl');

# Markup the crossbar page prior to locking the crossbar page. This should ensure
# that forms on that page are not interpreted.
test_page(update_page($CrossbarPageName,
  '<form><h1>mu</h1></form>', @update_crossbar_page_options),
  '<div class="crossbar"><p>&lt;form&gt;&lt;h1&gt;mu&lt;/h1&gt;&lt;/form&gt;</p></div>');

# Lock the crossbar page, mark it up again, and ensure that forms on that page
# are now interpreted.
xpath_test(get_page("action=pagelock id=$CrossbarPageName set=1 pwd=foo"),
  '//p/text()[string()="Lock for "]/following-sibling::a[@href="http://localhost/wiki.pl/Crossbar"][@class="local"][text()="Crossbar"]/following-sibling::text()[string()=" created."]');
test_page(get_page("action=browse id=$CrossbarPageName cache=0"),
  '<div class="crossbar"><form><h1>mu</h1></form></div>');
# While rendering the Crossbar as part of the HomePage, it should still
# be considered "locked", and therefore the form should render
# correctly.
test_page(get_page('HomePage'),
  '<div class="crossbar"><form><h1>mu</h1></form></div>');

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft 2008 by B.w.Curry <http://www.raiazome.com>.
Copyright (C) 2008  Alex Schroeder <alex@gnu.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see L<http://www.gnu.org/licenses/>.

=cut
