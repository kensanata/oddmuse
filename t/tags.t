require 't/test.pl';
package OddMuse;
use Test::More tests => 2;
clear_pages();

add_module('tags.pl');

xpath_run_tests(split('\n',<<'EOT'));
[[tag:foo bar]]
//a[@class="outside tag"][@title="Tag"][@href="http://technorati.com/tag/foo%20bar"][@rel="tag"][text()="foo bar"]
[[tag:foo bar|mu muh!]]
//a[@class="outside tag"][@title="Tag"][@href="http://technorati.com/tag/foo%20bar"][@rel="tag"][text()="mu muh!"]
EOT
