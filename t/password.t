# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 6;
clear_pages();
AppendStringToFile($ConfigFile, "\$EditPass = 'bar';\n");
test_page(update_page('test', 'normal edit'),
	  'normal edit');
test_page(get_page('action=password'),
	  'You are a normal user on this site');

# test problem reported by Gauthier
WriteStringToFile($ConfigFile, <<'EOT');
$EditAllowed = 2;
$AdminPass   = 'foo' unless defined $AdminPass;
$EditPass    = 'bar' unless defined $EditPass;
$ScriptName = 'http://localhost/wiki.pl';
$SurgeProtection = 0;
$CommentsPrefix = 'Comments on ';
$LocalNamesCollect = 1;
EOT

# using the above settings results in no permission to edit normal
# pages
test_page(update_page('normal_page', 'normal edit'),
	  'This page is empty');
test_page(update_page('normal_page', 'admin edit', 0, 0, 1),
	  'This page is empty');

# test suggested fix
WriteStringToFile($ConfigFile, <<'EOT');
$EditAllowed = 2;
$AdminPass   = 'foo';
$EditPass    = 'bar';
$ScriptName = 'http://localhost/wiki.pl';
$SurgeProtection = 0;
$CommentsPrefix = 'Comments on ';
$LocalNamesCollect = 1;
EOT

# using the password works, now
test_page(update_page('normal_page', 'normal edit'),
	  'This page is empty');
test_page(update_page('normal_page', 'admin edit', 0, 0, 1),
	  'admin edit');
