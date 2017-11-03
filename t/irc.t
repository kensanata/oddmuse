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

require './t/test.pl';
package OddMuse;
use Test::More tests => 5;

add_module('irc.pl');

run_tests(split('\n',<<'EOT'));
<kensanata> foo
<dl class="irc"><dt><b>kensanata</b></dt><dd>foo</dd></dl>
16:45 <kensanata> foo
<dl class="irc"><dt><span class="time">16:45  </span><b>kensanata</b></dt><dd>foo</dd></dl>
[16:45] <kensanata> foo
<dl class="irc"><dt><span class="time">16:45  </span><b>kensanata</b></dt><dd>foo</dd></dl>
16:45am <kensanata> foo
<dl class="irc"><dt><span class="time">16:45am  </span><b>kensanata</b></dt><dd>foo</dd></dl>
[16:45am] <kensanata> foo
<dl class="irc"><dt><span class="time">16:45am  </span><b>kensanata</b></dt><dd>foo</dd></dl>
EOT
