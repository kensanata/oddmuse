require 't/test.pl';
package OddMuse;
use Test::More tests => 1;
clear_pages();

AppendStringToFile($ConfigFile, "\$PageCluster = 'Cluster';\n");

add_module('crumbs.pl');

update_page("HomePage", "Has to do with [[Software]].");
update_page("Software", "[[HomePage]]\n\nCheck out [[Games]].");
update_page("Games", "[[Software]]\n\nThis is it.");
xpath_test(get_page('Games'),
		'//p/span[@class="crumbs"]/a[@class="local"][@href="http://localhost/wiki.pl/HomePage"][text()="HomePage"]/following-sibling::text()[string()=" "]/following-sibling::a[@class="local"][@href="http://localhost/wiki.pl/Software"][text()="Software"]');
