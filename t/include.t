require 't/test.pl';
package OddMuse;
use Test::More tests => 6;

clear_pages();

update_page('foo_moo', 'foo_bar');
test_page(update_page('yadda', '<include "foo moo">'),
	  qq{<div class="include foo_moo"><p>foo_bar</p></div>});
test_page(update_page('yadda', '<include text "foo moo">'),
	  qq{<pre class="include foo_moo">foo_bar\n</pre>});
test_page(update_page('yadda', '<include "yadda">'),
	  qq{<strong>Recursive include of yadda!</strong>});
update_page('yadda', '<include "foo moo">');
test_page(update_page('dada', '<include "yadda">'),
	  qq{<div class="include yadda"><div class="include foo_moo"><p>foo_bar</p></div></div>});
test_page(update_page('foo_moo', '<include "dada">'),
	  qq{<strong>Recursive include of foo_moo!</strong>});
test_page(update_page('bar', '<include "foo_moo">'),
	  qq{<strong>Recursive include of foo_moo!</strong>});
