# Copyright (C) 2006, 2011  Alex Schroeder <alex@gnuxs.org>
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
use Test::More tests => 12;

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

my $page = <<EOT;
#FILE image/svg+xml gzip
H4sICKlml04AA3Rlc3Quc3ZnADWOQQ6DIBBF956CzF6hdtMY0F1PYA9gCqUkdMbIRKSnLy76t/+/
vK+n4xPF7rYUCA1cOgXC4ZNsQG/gMd/bG4jEC9olEjoDSDCNjU67F5XEZODNvA5S5py7fO1o87JX
Ssm6gEacSVxiJW1Ia1zKEDAGdDDWUrM7WBzVW7XFQK/gv34RcpvC1w29WhnGeSMfyRZ2qOWJ1ROn
Y2x+OvAf9cMAAAA=
EOT

test_page(update_page('Trogs', $page), 'page is empty');
test_page($redirect, "Status: 415");
AppendStringToFile($ConfigFile, q{push(@UploadTypes, "image/svg+xml");
});
test_page(update_page('Trogs', $page), 'contains an uploaded file');

xpath_test(get_page('Trogs'),
	   '//p/img[@class="upload"][@src="http://localhost/wiki.pl?action=download;id=Trogs"][@alt="Trogs"]');
$page = get_page('action=download id=Trogs');
test_page($page,
	  'Content-Type: image/svg\+xml',
	  'Content-encoding: gzip');
like($page, qr/\r\n\r\n\x1f\x8b/, "gzipped data being served");
