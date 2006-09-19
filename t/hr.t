require 't/test.pl';
package OddMuse;
use Test::More tests => 8;

clear_pages();

# without portrait-support

# nothing
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'), 'one ---- two');

# usemod only
add_module('usemod.pl');
update_page('hr', "one\n----\nthree\n");
test_page(get_page('hr'),
	  '<div class="content browse"><p>one </p><hr /><p>three</p></div>');
remove_rule(\&UsemodRule);

# headers only
add_module('headers.pl');
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'),
	  '<div class="content browse"><h3>one</h3><p>two</p></div>');

update_page('hr', "one\n\n----\nthree\n");
test_page(get_page('hr'),
	  '<div class="content browse"><p>one</p><hr /><p>three</p></div>');
remove_rule(\&HeadersRule);

# with portrait support

clear_pages();

# just portrait-support
add_module('portrait-support.pl');
update_page('hr', "[new]one\n----\ntwo\n");
test_page(get_page('hr'),
	  '<div class="content browse"><div class="color one level0"><p>one </p></div><hr /><p>two</p></div>');

# usemod and portrait-support
add_module('usemod.pl');
update_page('hr', "one\n----\nthree\n");
test_page(get_page('hr'),
	  '<div class="content browse"><p>one </p><hr /><p>three</p></div>');
remove_rule(\&UsemodRule);

# headers and portrait-support
add_module('headers.pl');
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'), '<div class="content browse"><h3>one</h3><p>two</p></div>');

update_page('hr', "one\n\n----\nthree\n");
test_page(get_page('hr'), '<div class="content browse"><p>one</p><hr /><p>three</p></div>');
