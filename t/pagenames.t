require 't/test.pl';
package OddMuse;
use Test::More tests => 4;

clear_pages();

update_page('.dotfile', 'old content', 'older summary');
update_page('.dotfile', 'some content', 'some summary');
test_page(get_page('.dotfile'), 'some content');
test_page(get_page('action=browse id=.dotfile revision=1'), 'old content');
test_page(get_page('action=history id=.dotfile'), 'older summary', 'some summary');
