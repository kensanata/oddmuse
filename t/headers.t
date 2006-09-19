require 't/test.pl';
package OddMuse;
use Test::More tests => 13;

clear_pages();

# without portrait-support

# nothing
update_page('headers', "== no header ==\n\ntext\n");
test_page(get_page('headers'), '== no header ==');

# usemod only
add_module('usemod.pl');
update_page('headers', "== is header ==\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');

# toc + usemod only
add_module('toc.pl');
update_page('headers', "== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#headers1">one</a></li>',
	  '<li><a href="#headers2">two</a></li>',
	  '<h2 id="headers1">one</h2>',
	  '<h2 id="headers2">two</h2>', );
remove_module('usemod.pl');
remove_rule(\&UsemodRule);

# toc + headers
add_module('headers.pl');
update_page('headers', "one\n===\ntext\ntwo\n---\ntext\nthree\n====\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#headers1">one</a>',
	  '<ol><li><a href="#headers2">two</a></li></ol>',
	  '<li><a href="#headers3">three</a></li>',
	  '<h2 id="headers1">one</h2>',
	  '<h3 id="headers2">two</h3>',
	  '<h2 id="headers3">three</h2>', );
remove_module('toc.pl');
remove_rule(\&TocRule);

# headers only
update_page('headers', "is header\n=========\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');
