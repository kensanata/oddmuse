require 't/test.pl';
package OddMuse;
use Test::More tests => 17;

clear_pages();
test_page(get_page('action=editlock'), 'operation is restricted');
test_page(get_page('action=editlock pwd=foo'), 'Edit lock created');
xpath_test(update_page('TestLock', 'mu!'),
	   '//a[@href="http://localhost/wiki.pl?action=password"][@class="password"][text()="This page is read-only"]');
test_page($redirect, '403 FORBIDDEN', 'Editing not allowed for TestLock');
test_page(get_page('action=editlock set=0'), 'operation is restricted');
test_page(get_page('action=editlock set=0 pwd=foo'), 'Edit lock removed');
RequestLockDir('main');
test_page(update_page('TestLock', 'mu!'), 'Describe the new page here');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  'Could not get main lock', 'File exists',
	  'The lock was created (just now|1 second ago|2 seconds ago)');
test_page(update_page('TestLock', 'mu!'), 'Describe the new page here');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  'Could not get main lock', 'File exists',
	  'The lock was created 3[0-5] seconds ago');
