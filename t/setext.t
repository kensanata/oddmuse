require 't/test.pl';
package OddMuse;
use Test::More tests => 12;

clear_pages();

do 'modules/setext.pl';
do 'modules/link-all.pl';

run_tests(split('\n',<<'EOT'));
foo
foo
~foo~
<i>foo</i>
da *foo*
da *foo*
da **foo** bar
da <b>foo</b> bar
da `_**foo**_` bar
da **foo** bar
_foo_
<em style="text-decoration: underline; font-style: normal;">foo</em>
foo_bar_baz
foo_bar_baz
_foo_bar_ baz
<em style="text-decoration: underline; font-style: normal;">foo bar</em> baz
and\nfoo\n===\n\nmore\n
and <h2>foo</h2><p>more</p>
and\n\nfoo\n===\n\nmore\n
and<h2>foo</h2><p>more</p>
and\nfoo  \n--- \n\nmore\n
and <h3>foo</h3><p>more</p>
and\nfoo\n---\n\nmore\n
and <h3>foo</h3><p>more</p>
EOT
