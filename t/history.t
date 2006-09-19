require 't/test.pl';
package OddMuse;
use Test::More tests => 31;

clear_pages();

$page = get_page('action=history id=hist');
test_page($page,
	  'No other revisions available',
	  'View current revision',
	  'View all changes');
test_page_negative($page,
		   'View other revisions',
		   'Mark this page for deletion');

test_page(update_page('hist', 'testing', 'test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary'),
	  'testing',
	  'action=history',
	  'View other revisions');

test_page_negative(get_page('action=history id=hist'),
		   'Mark this page for deletion');
$page = get_page('action=history id=hist username=me');
test_page($page,
	  'test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary',
	  'View current revision',
	  'View all changes',
	  'current',
	  'Mark this page for deletion');
test_page_negative($page,
		   'No other revisions available',
		   'View other revisions',
		   'rollback');

test_page(update_page('hist', 'Tesla', 'Power'),
	  'Tesla',
	  'action=history',
	  'View other revisions');
$page = get_page('action=history id=hist username=me');
test_page($page,
	  'test summary',
	  'Power',
	  'View current revision',
	  'View all changes',
	  'current',
	  'rollback',
	  'action=rollback;to=',
	  'Mark this page for deletion');
test_page_negative($page,
		   'Tesla',
		   'No other revisions available',
		   'View other revisions');
