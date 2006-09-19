require 't/test.pl';
package OddMuse;
use Test::More tests => 1;

AppendStringToFile($ConfigFile, "\$ConfigPage = 'Config';\n");

xpath_test(update_page('Config', '@UserGotoBarPages = ("Foo", "Bar");',
		       'config', 0, 1),
	   '//div[@class="header"]/span[@class="gotobar bar"]/a[@class="local"][text()="Foo"]/following-sibling::a[@class="local"][text()="Bar"]');
