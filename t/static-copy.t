# Copyright (C) 2007, 2008, 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 16;
clear_pages();

add_module('static-copy.pl');

xpath_test(update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA",
		    undef, 0, 1),
	   '//img[@class="upload"]'
	   . '[@src="http://localhost/wiki.pl/download/Logo"]'
	   . '[@alt="Logo"]');

$page = get_page('action=browse id=Logo raw=1');
$page =~ m/^Etag: ([0-9]+)/m;
$ts = $1;
ok($ts > 0, "Got a timestamp for the first revision");

sleep 1;

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

# upload svgz (gzipped)
my $page = <<EOT;
#FILE image/svg+xml gzip
H4sICKlml04AA3Rlc3Quc3ZnADWOQQ6DIBBF956CzF6hdtMY0F1PYA9gCqUkdMbIRKSnLy76t/+/
vK+n4xPF7rYUCA1cOgXC4ZNsQG/gMd/bG4jEC9olEjoDSDCNjU67F5XEZODNvA5S5py7fO1o87JX
Ssm6gEacSVxiJW1Ia1zKEDAGdDDWUrM7WBzVW7XFQK/gv34RcpvC1w29WhnGeSMfyRZ2qOWJ1ROn
Y2x+OvAf9cMAAAA=
EOT
AppendStringToFile($ConfigFile, q{
push(@UploadTypes, "image/svg+xml");
$StaticMimeTypes{"image/svg+xml"} = 'svg';
$StaticMimeTypes{"image/svg+xml gzip"} = 'svgz';
});

# verify upload worked
test_page(update_page('Trogs', $page, undef, 0, 1), # admin
	  'contains an uploaded file');

# verify static file exists
ok(-f "$DataDir/static/Trogs.svgz", "$DataDir/static/Trogs.svgz exists");

# verify source link is correct
xpath_test(update_page('HomePage', "Static: [[image:Trogs]]"),
	   '//a[@class="image"]'
	   . '[@href="http://localhost/wiki.pl/Trogs"]'
	   . '/img[@class="upload"]'
	   . '[@src="/static/Trogs.svgz"]'
	   . '[@alt="Trogs"]');

# Make sure spaces are translated to underscores (fixed in image.pl)
add_module('image.pl');

# Now, create real pages. First, we'll use the ordinary image link to
# a non-existing page. This should give us an edit link.
xpath_test(update_page('test_image', '[[image:bar baz]]'),
	   '//a[@class="edit"][@title="Click to edit this page"][@rel="nofollow"][@href="http://localhost/wiki.pl?action=edit;id=bar_baz;upload=1"]');

# The same should be true for the image extension.
xpath_test(update_page('test_image', '[[image/right:bar baz]]'),
	   '//a[@class="edit"][@title="Click to edit this page"][@rel="nofollow"][@href="http://localhost/wiki.pl?action=edit;id=bar_baz;upload=1"]');

# Next, using a real page. The image type is used appropriately.
xpath_test(update_page('test_image', '[[image/right:Logo]]'),
	   '//a[@class="image right"][@href="http://localhost/wiki.pl/Logo"]/img[@class="upload"][@src="/static/Logo.png"][@alt="Logo"]');
