require 't/test.pl';
package OddMuse;
use Test::More tests => 9;

clear_pages();

add_module('despam.pl');

update_page('HilariousPage', "Ordinary text.");
update_page('HilariousPage', "Hilarious text.");
update_page('HilariousPage', "Spam from http://example.com.");

update_page('NoPage', "Spam from http://example.com.");

update_page('OrdinaryPage', "Spam from http://example.com.");
update_page('OrdinaryPage', "Ordinary text.");

update_page('ExpiredPage', "Spam from http://example.com.");
update_page('ExpiredPage', "More spam from http://example.com.");
update_page('ExpiredPage', "Still more spam from http://example.com.");

update_page('BannedContent', " example\\.com\n", 'required', 0, 1);

unlink('/tmp/oddmuse/keep/E/ExpiredPage/1.kp')
  or die "Cannot delete kept revision: $!";

test_page(get_page('action=despam'), split('\n',<<'EOT'));
HilariousPage.*Revert to revision 2
NoPage.*Marked as DeletedPage
OrdinaryPage
ExpiredPage.*Cannot find unspammed revision
EOT

test_page(get_page('ExpiredPage'), 'Still more spam');
test_page(get_page('OrdinaryPage'), 'Ordinary text');
test_page(get_page('NoPage'), 'DeletedPage');
test_page(get_page('HilariousPage'), 'Hilarious text');
test_page(get_page('BannedContent'), 'example\\\.com');
