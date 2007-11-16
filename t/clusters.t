# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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
use Test::More tests => 33;

clear_pages();

AppendStringToFile($ConfigFile, "\$PageCluster = 'Cluster';\n");

update_page('ClusterIdea', 'This is just a page.', 'one');
update_page('ClusterIdea', "This is just a page.\nBut somebody has to do it.", 'two');
update_page('ClusterIdea', "This is just a page.\nNobody wants it.", 'three', 1);
sleep(1); # make sure the next revision has a different timestamp
update_page('ClusterIdea', "MainPage\nThis is just a page.\nBut somebody has to do it.", 'four');

# Shows both a change to the MainPage Cluster and a change to ClusterIdea.
xpath_test(get_page('action=rc'),
	   '//a[text()="Cluster"]/following-sibling::a[text()="MainPage"][@href="http://localhost/wiki.pl?action=browse;id=MainPage;rcclusteronly=MainPage"]',
	   '//a[text()="ClusterIdea"]');

# Show all the major changes. The last major change happened to a
# cluster, so show a change to the MainPage cluster instead.
$page = get_page('action=rc all=1');
xpath_test($page,
	   '//a[text()="Cluster"]/following-sibling::a[text()="MainPage"]/following-sibling::strong[text()="ClusterIdea: four"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="two"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="one"]');
negative_xpath_test($page,
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="three"]');

# Show minor edits as well.
xpath_test(get_page('action=rc all=1 showedit=1'),
	   '//a[text()="Cluster"]/following-sibling::a[text()="MainPage"]/following-sibling::strong[text()="ClusterIdea: four"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="three"]/following-sibling::em[text()="(minor)"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="two"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="one"]');

# Change the MainPage.
update_page('MainPage', 'Finally the main page.', 'main summary');

# Ordinary RecentChanges will just show the MainPage changed, now. The
# latest change to ClusterIdea remains invisible.
xpath_test(get_page('action=rc'),
	   '//a[text()="MainPage"]/following-sibling::strong[text()="main summary"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="two"]');

# Visiting the MainPage as the cluster page shows RecentChanges for
# this cluster only.
xpath_test(get_page('action=browse id=MainPage rcclusteronly=MainPage'),
	   '//p[text()="Finally the main page."]',
	   '//b[text()="(for MainPage only)"]',
	   '//li/a[text()="ClusterIdea"]/following-sibling::strong[text()="four"]',
	   '//a[@href="http://localhost/wiki.pl?action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=0;showedit=0"]');

# Now edit the page in the cluster again. Since this is a minor edit,
# RecentChanges will remain unchanged.
update_page('ClusterIdea', "MainPage\nSomebody has to do it.", 'five', 1);
xpath_test(get_page('action=rc'),
	   '//a[text()="MainPage"]/following-sibling::strong[text()="main summary"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="two"]');

# Things change if we include minor changes, however. Now we'll see
# the last unclustered change ("three") as well as the effect the
# cluster has.
xpath_test(get_page('action=rc showedit=1'),
	   '//a[text()="Cluster"]/following-sibling::a[text()="MainPage"][@href="http://localhost/wiki.pl?action=browse;id=MainPage;rcclusteronly=MainPage"]/following-sibling::strong[text()="ClusterIdea: five"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="three"]');

# Take another look at the MainPage, this time including all and minor
# edits. We should see the two clustered revisions.
$page = get_page('action=browse id=MainPage rcclusteronly=MainPage all=1 showedit=1');
xpath_test($page,
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="five"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="four"]');
negative_xpath_test($page,
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="three"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="two"]',
	   '//a[text()="ClusterIdea"]/following-sibling::strong[text()="one"]');

# Check the links in the RSS feed. First major changes only, then
# including minor changes. The clustering will only apparent with
# minor changes.
test_page(get_page('action=rss'),
	  '<link>http://localhost/wiki.pl/MainPage</link>',
	  '<link>http://localhost/wiki.pl/ClusterIdea</link>');
test_page(get_page('action=rss showedit=1'),
	  '<link>http://localhost/wiki.pl\?action=browse;id=MainPage;rcclusteronly=MainPage</link>',
	  '<link>http://localhost/wiki.pl/ClusterIdea</link>');

# Just to make sure everything works, create a new page in the
# cluster. This time check the raw output. Note that the output will
# contain a link to the last unclustered major revision of
# ClusterIdea, two.
update_page('OtherIdea', "MainPage\nThis is another page.\n", 'new page in cluster');
$page = get_page('action=rc raw=1');
test_page($page, 'title: MainPage',
	  'description: OtherIdea: new page in cluster',
	  'description: two');

# The summary of the MainPage edit will remain hidden.
test_page_negative($page, 'main summary');
