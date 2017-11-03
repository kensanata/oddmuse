# Copyright (C) 2015  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 2;

add_module('private-wiki.pl');

open(F, '>:encoding(utf-8)', "$DataDir/config");
print F "use Digest::SHA qw(sha256_hex);\n";
print F "\$PassHashFunction = 'sha256_hex';\n";
print F "\$PassSalt = '';\n";
print F "\$AdminPass = '4207b6bc5176ab397e49c116954ca5a499f3f61c2d7556162aebf94ba25baf8a';\n";
close(F);


# First of all, let's test basic editing
get_page('Save=1', 'title=Test', 'summary=MySummary', 'recent_edit=on', 'text=HelloPrivateWiki', 'pwd=5de2cbd1cbb2048e4c753c9fa118c130c1c8b91312154bb30bb99961bd620303');

# Page is known
test_page(get_page('action=index', 'raw=1',
		   'pwd=5de2cbd1cbb2048e4c753c9fa118c130c1c8b91312154bb30bb99961bd620303'),
	  'Test');

# Page can be read
test_page(get_page('action=browse', 'id=Test',
		   'pwd=5de2cbd1cbb2048e4c753c9fa118c130c1c8b91312154bb30bb99961bd620303'),
	  'HelloPrivateWiki');
