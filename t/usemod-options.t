# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

add_module('usemod.pl');

InitVariables();

$UseModSpaceRequired = 0;
$UseModMarkupInTitles = 1;

run_tests(split('\n',<<'EOT'));
*one\n**two
<ul><li>one<ul><li>two</li></ul></li></ul>
#one\n##two
<ol><li>one<ol><li>two</li></ol></li></ol>
:one\n:two\n::one and two\n::two and three\n:three
<dl class="quote"><dt /><dd>one</dd><dt /><dd>two<dl class="quote"><dt /><dd>one and two</dd><dt /><dd>two and three</dd></dl></dd><dt /><dd>three</dd></dl>
;one:eins\n;two:zwei
<dl><dt>one</dt><dd>eins</dd><dt>two</dt><dd>zwei</dd></dl>
=='''title'''==
<h2><strong>title</strong></h2>
1 \+ 1 = 2
1 \+ 1 = 2
EOT

xpath_run_tests(split('\n',<<'EOT'));
==[[Free Link]]==
//h2/text()[string()="[[Free_Link"]/following-sibling::a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=Free_Link"][text()="?"]/following-sibling::text()[string()="]]"]
EOT
