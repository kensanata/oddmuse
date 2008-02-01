# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

require 't/test.pl';
package OddMuse;
use Test::More tests => 21;

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
update_page('code', 'This is the & character.');
update_page('code', 'This is the <code>&</code> character.');
test_page(get_page('action=browse diff=1 id=code'),
	  '<strong class="changes">&lt;code&gt;</strong>&amp;<strong class="changes">&lt;/code&gt;</strong>');

# make sure revision and diffrevision work correctly
update_page('david', 'this is the first revision', 'first revision');
update_page('david', 'this is the second revision', 'second revision');
update_page('david', 'this is the third revision', 'third revision');
update_page('david', 'this is the fourth revision', 'fourth revision');
# first make sure the history page shows the appropriate labels and
# summaries
test_page(get_page('action=history id=david'),
	  'Revision 1', 'first revision',
	  'Revision 2', 'second revision',
	  'Revision 3', 'third revision',
	  'Revision 4', 'fourth revision');
# using diffrevision=1 will make sure that the third revision is not shown
xpath_test(get_page('action=browse diff=1 id=david revision=2 diffrevision=1'),
	   '//div[@class="old"]/p/strong[text()="first"]',
	   '//div[@class="new"]/p/strong[text()="second"]',
	   '//div[@class="content browse"]/p[text()="this is the second revision"]');
# check with cache = 0
xpath_test(get_page('action=browse diff=1 id=david revision=2 diffrevision=1 cache=0'),
	   '//div[@class="old"]/p/strong[text()="first"]',
	   '//div[@class="new"]/p/strong[text()="second"]',
	   '//div[@class="content browse"]/p[text()="this is the second revision"]');
