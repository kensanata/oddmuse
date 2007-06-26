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
use Test::More tests => 24;

clear_pages();
add_module('aggregate.pl');

update_page('InnocentPage', 'We are innocent!');
update_page('NicePage', 'You are nice.');
update_page('OtherPage', 'This is off-topic.');
update_page('Front_Page', q{Hello!
<aggregate "NicePage" "OtherPage">
The End.});

$page = get_page('Front_Page');
xpath_test($page, '//div[@class="content browse"]/p[text()="Hello! "]',
	   '//div[@class="aggregate journal"]/div[@class="page"]/h2/a[@class="local"][text()="NicePage"]',
	   '//div[@class="aggregate journal"]/div[@class="page"]/h2/a[@class="local"][text()="OtherPage"]',
	   '//div[@class="page"]/p[text()="You are nice."]',
	   '//div[@class="page"]/p[text()="This is off-topic."]',
	   '//div[@class="content browse"]/p[text()=" The End."]');

$page = get_page('action=aggregate id=Front_Page');
test_page($page, '<title>NicePage</title>',
	  '<title>OtherPage</title>',
	  '<link>http://localhost/wiki.pl/NicePage</link>',
	  '<link>http://localhost/wiki.pl/OtherPage</link>',
	  '<description>&lt;p&gt;You are nice.&lt;/p&gt;</description>',
	  '<description>&lt;p&gt;This is off-topic.&lt;/p&gt;</description>',
	  '<wiki:status>new</wiki:status>',
	  '<wiki:importance>major</wiki:importance>',
	  quotemeta('<wiki:history>http://localhost/wiki.pl?action=history;id=NicePage</wiki:history>'),
	  quotemeta('<wiki:diff>http://localhost/wiki.pl?action=browse;diff=1;id=NicePage</wiki:diff>'),
	  quotemeta('<wiki:history>http://localhost/wiki.pl?action=history;id=OtherPage</wiki:history>'),
	  quotemeta('<wiki:diff>http://localhost/wiki.pl?action=browse;diff=1;id=OtherPage</wiki:diff>'),
	  '<title>Wiki: Front Page</title>',
	  '<link>http://localhost/wiki.pl/Front_Page</link>',
	 );

# check for infinite loops

update_page('Front_Page', q{Hello!
<aggregate search off-topic>
The End.});

$page = get_page('Front_Page');
xpath_test($page, '//div[@class="content browse"]/p[text()="Hello! "]',
	   '//div[@class="aggregate journal"]/div[@class="page"]/h2/a[@class="local"][text()="OtherPage"]',
	   '//div[@class="page"]/p[text()="This is off-topic."]',
	   '//div[@class="content browse"]/p[text()=" The End."]');
