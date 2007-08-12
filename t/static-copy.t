# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
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
use Test::More tests => 10;
clear_pages();

add_module('static-copy.pl');

xpath_test(update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA",
		    undef, 0, 1),
	   '//img[@class="upload"]'
	   . '[@src="http://localhost/wiki.pl/download/Logo"]'
	   . '[@alt="Logo"]');

$page = get_page('action=browse id=Logo raw=1');
$page =~ m/^Etag: ([0-9]+)/;
$ts = $1;
ok($ts > 0, "Got a timestamp for the first revision");

xpath_test(update_page('HomePage', "[[image:Logo]]"),
	   '//a[@class="image"]'
	   . '[@href="http://localhost/wiki.pl/Logo"]'
	   . '/img[@class="upload"]'
	   . '[@src="http://localhost/wiki.pl/download/Logo"]'
	   . '[@alt="Logo"]');

AppendStringToFile($ConfigFile, q{
$StaticAlways = 1;
$StaticDir = $DataDir . '/static';
$StaticUrl = '/static/';
%StaticMimeTypes = ('image/png'  => 'png', );
@UploadTypes = ('image/png', );
});

update_page('Logo', "DeletedPage");
xpath_test(update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA",
		       undef, 0, 1),
	   '//img[@class="upload"]'
	   . '[@src="/static/Logo.png"]'
	   . '[@alt="Logo"]');

ok(-f "$DataDir/static/Logo.png", "$DataDir/static/Logo.png exists");

xpath_test(update_page('HomePage', "Static: [[image:Logo]]"),
	   '//a[@class="image"]'
	   . '[@href="http://localhost/wiki.pl/Logo"]'
	   . '/img[@class="upload"]'
	   . '[@src="/static/Logo.png"]'
	   . '[@alt="Logo"]');

update_page('Logo', "DeletedPage");
xpath_test(get_page("action=rollback id=Logo to=$ts username=root"),
	   '//h1[text()="Rolling back changes"]',
	   '//a[@class="local"]'
	   . '[@href="http://localhost/wiki.pl/Logo"]'
	   . '[text()="Logo"]'
	   . '/following-sibling::text()[string()=" rolled back"]');

xpath_test(update_page('HomePage', "Static: [[image:Logo]]"),
	   '//a[@class="image"]'
	   . '[@href="http://localhost/wiki.pl/Logo"]'
	   . '/img[@class="upload"]'
	   . '[@src="/static/Logo.png"]'
	   . '[@alt="Logo"]');

# File got restored as well
ok(-f "$DataDir/static/Logo.png", "$DataDir/static/Logo.png exists");
