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
use Test::More tests => 15;
clear_pages();

add_module('moin.pl');

xpath_run_tests(split('\n',<<'EOT'));
foo[[BR]]bar
//text()[string()="foo"]/following-sibling::br/following-sibling::text()[string()="bar"]
''foo''
//em[text()="foo"]
'''bar'''
//strong[text()="bar"]
[[foo bar]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=foo_bar"][text()="?"]
["foo bar"]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=foo_bar"][text()="?"]
 * one\n * two\n  * two.one
//ul/li[text()="one"]/following-sibling::li/text()[string()="two"]/following-sibling::ul/li[text()="two.one"]
  * one\n    * one.one\n  * two
//ul/li/text()[string()="one"]/following-sibling::ul/li[text()="one.one"]/../../following-sibling::li[text()="two"]
  * one\n    * one.one\n * two
//ul/li/text()[string()="one"]/following-sibling::ul/li[text()="one.one"]/../../following-sibling::li[text()="two"]
 1. one\n 1. two\n  1. two.one
//ol/li[text()="one"]/following-sibling::li/text()[string()="two"]/following-sibling::ol/li[text()="two.one"]
   one\n     one.one\n  two
//dl[@class="quote"]/dd/text()[normalize-space(string())="one"]/following-sibling::dl/dd[normalize-space(text())="one.one"]/../../following-sibling::dd[text()="two"]
 * one\n more\n * two\n more
//ul/li[normalize-space(text())="one more"]/following-sibling::li[normalize-space(text())="two more"]
 * one\n more\n  * two\n  more
//ul/li/text()[normalize-space(string())="one more"]/following-sibling::ul/li[normalize-space(text())="two more"]
  one\n  more\n    two\n    more
//dl[@class="quote"]/dd/text()[normalize-space(string())="one more"]/following-sibling::dl/dd[normalize-space(text())="two more"]
{{{\n[[foo bar]]\n}}}
//pre[@class="real"][text()="[[foo bar]]\n"]
hello mum\nthis is for you...
//div[text()="hello mum this is for you..."]
EOT
