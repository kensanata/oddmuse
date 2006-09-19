require 't/test.pl';
package OddMuse;
use Test::More tests => 8;

clear_pages();
AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");

$page = update_page('alex pic', "#FILE image/png\niVBORw0KGgoAAAA");
test_page($page, 'This page contains an uploaded file:');
xpath_test($page, '//img[@class="upload"][@src="http://localhost/wiki.pl/download/alex_pic"][@alt="alex pic"]');
test_page_negative($page, 'AAAA');
test_page_negative(get_page('search=AAA raw=1'), 'alex_pic');
test_page(get_page('search=alex raw=1'), 'alex_pic', 'image/png');
test_page(get_page('search=png raw=1'), 'alex_pic', 'image/png');
