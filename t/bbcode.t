# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 7;

clear_pages();

do 'modules/bbcode.pl';

run_tests(split('\n',<<'EOT'));
[b]this text is bold[/b]
<b>this text is bold</b>
[i]this text is italic[/i]
<i>this text is italic</i>
[u]this text is underlined[/u]
<em style="text-decoration: underline; font-style: normal;">this text is underlined</em>
[color=blue]this text is blue[/color]
<em style="color: blue; font-style: normal;">this text is blue</em>
[size=+2]this text is two sizes larger than normal[/size]
<em style="font-size: 200%; font-style: normal;">this text is two sizes larger than normal</em>
[size=test]this text is two sizes larger than normal[/size]
[size=test]this text is two sizes larger than normal[/size]
[font=courier]this text is in the courier font[/font]
<span style="font-family: courier;">this text is in the courier font</span>
EOT
