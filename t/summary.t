require 't/test.pl';
package OddMuse;
use Test::More tests => 1;

clear_pages();

update_page('sum', 'some [http://example.com content]');
test_page(get_page('action=rc raw=1'), 'description: some content');
