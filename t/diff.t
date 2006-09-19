require 't/test.pl';
package OddMuse;
use Test::More tests => 6;

clear_pages();

# Highlighting differences
update_page('xah', "When we judge people in society, often, we can see people's true nature not by the official defenses and behaviors, but by looking at the statistics (past records) of their behavior and the circumstances it happens.\n"
	    . "For example, when we look at the leader in human history. Great many of them have caused thousands and millions of intentional deaths. Some of these leaders are hated by many, yet great many of them are adored and admired and respected... (ok, i'm digressing...)\n");
update_page('xah', "When we judge people in society, often, we can see people's true nature not by the official defenses and behaviors, but by looking at some subtleties, and also the statistics (past records) of their behavior and the circumstances they were in.\n"
	    . "For example, when we look at leaders in history. Great many of them have caused thousands and millions of intentional deaths. Some of these leaders are hated by many, yet great many of them are adored and admired and respected... (ok, i'm digressing...)\n");
test_page(get_page('action=browse diff=1 id=xah'),
	  '<strong class="changes">it happens</strong>',
	  '<strong class="changes">the leader</strong>',
	  '<strong class="changes">human</strong>',
	  '<strong class="changes">some subtleties, and also</strong>',
	  '<strong class="changes">they were in</strong>',
	  '<strong class="changes">leaders</strong>',
	 );
