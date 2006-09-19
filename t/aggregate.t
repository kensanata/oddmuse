require 't/test.pl';
package OddMuse;
use Test::More tests => 20;

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
