# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 1;

AppendStringToFile($ConfigFile, "\$ConfigPage = 'Config';\n");

xpath_test(update_page('Config', '@UserGotoBarPages = ("Foo", "Bar");',
		       'config', 0, 1),
	   '//div[@class="header"]/div[@class="menu"]/span[@class="gotobar bar"]/a[@class="local"][text()="Foo"]/following-sibling::a[@class="local"][text()="Bar"]');
