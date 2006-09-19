require 't/test.pl';
package OddMuse;
use Test::More tests => 3;
clear_pages();
add_module('tex.pl');

run_macro_tests(split('\n',<<'EOT'));
4\times 7
4×7
right\copyright
right©
a\infty b
a∞b
EOT
