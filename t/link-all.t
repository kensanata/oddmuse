require 't/test.pl';
package OddMuse;
use Test::More tests => 2;

clear_pages();

add_module('link-all.pl');

update_page('foo', 'link-all for bar');

xpath_test(get_page('action=browse define=1 id=foo'),
	  '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=bar"][text()="bar"]');


xpath_run_tests(split('\n',<<'EOT'));
testing foo.
//a[@class="local"][@href="http://localhost/test.pl/foo"][text()="foo"]
EOT
