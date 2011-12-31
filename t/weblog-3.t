# Copyright (C) 2011  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 35;

clear_pages();

add_module('weblog-3.pl');

update_page('This_paragraph', 'bla');
update_page('link', 'bla');
update_page('First_Item', 'bla');
update_page('Second_Item', 'bla');

my $text = <<EOT;
This is not a list.
* [[This paragraph]] did not start with a list.

* This does not start with a [[link]].
* [[First Item]] in the goto-bar.
** [[Second Item]] in the goto-bar.
EOT

$page = update_page('HomePage', $text);

xpath_test($page,
	   '//ul/li/a[text()="This paragraph"]',
	   '//ul/li/a[text()="link"]',
	   '//ul/li/a[text()="First Item"]',
	   '//ul/li/a[text()="Second Item"]',
	   '//span[@class="gotobar bar"]/a[text()="HomePage"]',
	   '//span[@class="gotobar bar"]/a[text()="RecentChanges"]',
	   '//span[@class="gotobar bar"]/a[text()="New"]',
	   '//span[@class="gotobar bar"]/a[text()="First Item"]',
	   '//span[@class="gotobar bar"]/a[text()="Second Item"]');

xpath_test_negative($page,
		    '//span[@class="gotobar bar"]/a[text()="This paragraph"]',
		    '//span[@class="gotobar bar"]/a[text()="link"]');

xpath_test($page,
	   '//a[text()="HomePage"]/following-sibling::*[1][text()="RecentChanges"]',
	   '//a[text()="RecentChanges"]/following-sibling::*[1][text()="First Item"]',
	   '//a[text()="First Item"]/following-sibling::*[1][text()="Second Item"]',
	   '//a[text()="Second Item"]/following-sibling::*[1][text()="New"]');

update_page('Foo', 'bla');
update_page('Bar', 'bla');

$text = <<EOT;
This is not a list.
* [[This paragraph]] did not start with a list.

* This does not start with a [[link]].
* [[Foo]] in the goto-bar.
** [[Bar]] in the goto-bar.
EOT

$page = update_page('Categories', $text);

xpath_test($page,
	   '//ul/li/a[text()="This paragraph"]',
	   '//ul/li/a[text()="link"]',
	   '//ul/li/a[text()="Foo"]',
	   '//ul/li/a[text()="Bar"]');

xpath_test_negative($page,
		    '//span[@class="gotobar bar"]/a[text()="This paragraph"]',
		    '//span[@class="gotobar bar"]/a[text()="link"]');

$page = get_page('action=new');

xpath_test($page,
	   '//a[text()="Categories"]',
	   '//a[text()="First Item"]',
	   '//a[text()="Second Item"]');

xpath_test_negative($page,
	   '//a[text()="This paragraph"]',
	   '//a[text()="link"]');

# current category is added to the list

$page = update_page('2012-12-31_Foo_Baz', 'bla');

xpath_test($page,
	   '//a[text()="HomePage"]/following-sibling::*[1][text()="RecentChanges"]',
	   '//a[text()="RecentChanges"]/following-sibling::*[1][text()="First Item"]',
	   '//a[text()="First Item"]/following-sibling::*[1][text()="Second Item"]',
	   '//a[text()="Second Item"]/following-sibling::*[1][text()="Foo"]',
	   '//a[text()="Foo"]/following-sibling::*[1][text()="Baz"]',
	   '//a[text()="Baz"]/following-sibling::*[1][text()="New"]');

# links added from the HomePage are ordinary links
# category links are ordinary links (because the code knows they are categories)
# dynamic category links from the page name have stuff added (to make sure the code knows)

xpath_test($page,
	   '//a[text()="First Item"][@href="http://localhost/wiki.pl/First_Item"]',
	   '//a[text()="Foo"][@href="http://localhost/wiki.pl/Foo"]',
	   '//a[text()="Baz"][@href="http://localhost/wiki.pl?tag=1;action=browse;id=Baz"]');
