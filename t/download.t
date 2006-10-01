# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 5;

clear_pages();

AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");

test_page_negative(get_page('HomePage'), 'logo');
AppendStringToFile($ConfigFile, "\$LogoUrl = '/pic/logo.png';\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="/pic/logo.png"][@alt="[Home]"]');
AppendStringToFile($ConfigFile, "\$LogoUrl = 'Logo';\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="Logo"][@alt="[Home]"]');
update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="http://localhost/wiki.pl/download/Logo"][@alt="[Home]"]');
AppendStringToFile($ConfigFile, "\$UsePathInfo = 0;\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="http://localhost/wiki.pl?action=download;id=Logo"][@alt="[Home]"]');
