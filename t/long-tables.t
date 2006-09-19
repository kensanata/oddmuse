require 't/test.pl';
package OddMuse;
use Test::More tests => 8;
clear_pages();

add_module('tables-long.pl');

run_tests(split('\n',<<'EOT'));
<table a,b>\na=a\nb=b\na=one\nb=two
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td>two</td></tr></table>
<table a,b>\na=a\nb=b\na=one\nb=two\n----
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td>two</td></tr></table>
<table a,b>\na=a\nb=b\na=one\nb=two\n----\n\nDone.
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td>two</td></tr></table><p>Done.</p>
Here is a table:\n<table a,b>\na=a\nb=b\na=one\ntwo\nand a half\nb=three\na=foo\nb=bar\n----\n\nDone.\n<table foo,bar>\nfoo=test\nbar=test as well\nfoo=what we test\n----\nthe end.
Here is a table: <table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one two and a half</td><td>three</td></tr><tr><td>foo</td><td>bar</td></tr></table><p>Done. </p><table class="user long"><tr><th>test</th><th>test as well</th></tr><tr><td colspan="2">what we test</td></tr></table><p>the end.</p>
<table a,b>\na=a\nb=b\na=one\nb/2=odd\na=three
<table class="user long"><tr><th>a</th><th>b</th></tr><tr><td>one</td><td rowspan="2">odd</td></tr><tr><td>three</td></tr></table>
<table a,b,c>\na=a\nb=b\nc=c\na=one\nb/2=odd\nc=two\na=three\nc=four
<table class="user long"><tr><th>a</th><th>b</th><th>c</th></tr><tr><td>one</td><td rowspan="2">odd</td><td>two</td></tr><tr><td>three</td><td>four</td></tr></table>
<table a,b,c>\na=a\nb=b\nc=c\na=one\nb=two\nc/2=numbers\na=three\n
<table class="user long"><tr><th>a</th><th>b</th><th>c</th></tr><tr><td>one</td><td>two</td><td rowspan="2">numbers</td></tr><tr><td colspan="2">three</td></tr></table>
<table a, b, c>\na:0\nb:1\nc:00\n----\n
<table class="user long"><tr><th>0</th><th>1</th><th>00</th></tr></table>
EOT
