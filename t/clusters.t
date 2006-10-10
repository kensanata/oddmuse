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
use Test::More tests => 38;

clear_pages();

AppendStringToFile($ConfigFile, "\$PageCluster = 'Cluster';\n");

update_page('ClusterIdea', 'This is just a page.', 'one');
update_page('ClusterIdea', "This is just a page.\nBut somebody has to do it.", 'two');
update_page('ClusterIdea', "This is just a page.\nNobody wants it.", 'three', 1);
update_page('ClusterIdea', "MainPage\nThis is just a page.\nBut somebody has to do it.", 'four');

test_page(get_page('action=rc'), 'Cluster.*MainPage');

test_page(get_page('action=rc all=1'), qw(Cluster.*MainPage ClusterIdea.*two ClusterIdea.*one));

test_page(get_page('action=rc all=1 showedit=1'), qw(Cluster.*MainPage ClusterIdea.*three
						     ClusterIdea.*two ClusterIdea.*one));

update_page('MainPage', 'Finally the main page.', 'main summary');
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage'), split('\n',<<'EOT'));
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*history.*four
for.*MainPage.*only
1 day
action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=0;showedit=0
EOT

@Test = split('\n',<<'EOT');
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*four
for.*MainPage.*only
1 day
EOT

test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage showedit=1'),
	  (@Test, 'action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=0;showedit=1'));
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage all=1'),
	  (@Test, 'action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=1;showedit=0'));

update_page('ClusterIdea', "MainPage\nSomebody has to do it.", 'five', 1);
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage all=1 showedit=1'), split('\n',<<'EOT'));
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*five
diff.*ClusterIdea.*four
for.*MainPage.*only
1 day
action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=1;showedit=1
EOT

test_page(get_page('action=rss'), 'action=browse;id=MainPage;rcclusteronly=MainPage');

update_page('OtherIdea', "MainPage\nThis is another page.\n", 'new page in cluster');
$page = get_page('action=rc raw=1');
test_page($page, 'title: MainPage', 'description: OtherIdea: new page in cluster',
	  'description: main summary');
test_page_negative($page, 'ClusterIdea');
