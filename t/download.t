require 't/test.pl';
package OddMuse;
use Test::More tests => 5;

clear_pages();

test_page_negative(get_page('HomePage'), 'logo');
AppendStringToFile($ConfigFile, "\$LogoUrl = '/pic/logo.png';\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="/pic/logo.png"][@alt="[Home]"]');
AppendStringToFile($ConfigFile, "\$LogoUrl = 'Logo';\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="Logo"][@alt="[Home]"]');
update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="http://localhost/wiki.pl/download/Logo"][@alt="[Home]"]');
AppendStringToFile($ConfigFile, "\$UsePathInfo = 0;\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="http://localhost/wiki.pl?action=download;id=Logo"][@alt="[Home]"]');
