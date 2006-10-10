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
use Test::More tests => 33;

clear_pages();

# old revisions
update_page('InnocentPage', 'Innocent.', 'good guy zero');
update_page('NicePage', 'Friendly content.', 'good guy one');
update_page('OtherPage', 'Other cute content 1.', 'another good guy');
update_page('OtherPage', 'Other cute content 2.', 'another good guy');
update_page('OtherPage', 'Other cute content 3.', 'another good guy');
update_page('OtherPage', 'Other cute content 4.', 'another good guy');
update_page('OtherPage', 'Other cute content 5.', 'another good guy');
update_page('OtherPage', 'Other cute content 6.', 'another good guy');
update_page('OtherPage', 'Other cute content 7.', 'another good guy');
update_page('OtherPage', 'Other cute content 8.', 'another good guy');
update_page('OtherPage', 'Other cute content 9.', 'another good guy');
update_page('OtherPage', 'Other cute content 10.', 'another good guy');
update_page('OtherPage', 'Other cute content 11.', 'another good guy');

# good revisions -- need a different timestamp than the old revisions!
sleep(1);
update_page('InnocentPage', 'Lamb.', 'good guy zero');
update_page('OtherPage', 'Other cute content 12.', 'another good guy');
update_page('MinorPage', 'Dumdidu', 'tester');

# last good revision -- needs a different timestamp than the good revisions!
sleep(1);
update_page('NicePage', 'Nice content.', 'good guy two');

# bad revisions -- need a different timestamp than the last good revision!
sleep(1);

update_page('NicePage', 'Evil content.', 'vandal one');
update_page('OtherPage', 'Other evil content.', 'another vandal');
update_page('NicePage', 'Bad content.', 'vandal two');
update_page('EvilPage', 'Spam!', 'vandal three');
update_page('AnotherEvilPage', 'More Spam!', 'vandal four');
update_page('AnotherEvilPage', 'Still More Spam!', 'vandal five');
update_page('MinorPage', 'Ramtatam', 'testerror', 1);

test_page(get_page('NicePage'), 'Bad content');
test_page(get_page('InnocentPage'), 'Lamb');

$to = xpath_test(get_page('action=rc all=1 pwd=foo'),
		 '//strong[text()="good guy two"]/preceding-sibling::a[@class="rollback"]/attribute::href');
$to =~ /action=rollback;to=([0-9]+)/;
$to = $1;

test_page(get_page("action=rollback to=$to"), 'username is required');
test_page(get_page("action=rollback to=$to username=me"), 'restricted to administrators');
test_page(get_page("action=rollback to=$to pwd=foo"),
	  'Rolling back changes',
	  'EvilPage</a> rolled back',
	  'AnotherEvilPage</a> rolled back',
	  'MinorPage</a> rolled back',
	  'NicePage</a> rolled back',
	  'OtherPage</a> rolled back');

test_page(get_page('NicePage'), 'Nice content');
test_page(get_page('OtherPage'), 'Other cute content 12');
test_page(get_page('EvilPage'), 'DeletedPage');
test_page(get_page('AnotherEvilPage'), 'DeletedPage');
test_page(get_page('InnocentPage'), 'Lamb');

my $rc = get_page('action=rc all=1 showedit=1 pwd=foo'); # this includes rollback info and rollback links

# check all revisions of NicePage in recent changes
xpath_test($rc,
	'//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=1"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="good guy one"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=2"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=2"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="good guy two"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=3"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=3"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="vandal one"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=4"][text()="diff"]/following-sibling::a[@class="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=4"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="vandal two"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[contains(text(),"Rollback to")]',
	# check that the minor spam is reverted with a minor rollback
	'//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage;revision=1"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="tester"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=MinorPage;diffrevision=2"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage;revision=2"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="testerror"]/following-sibling::em[text()="(minor)"]',
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=MinorPage"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[contains(text(),"Rollback to")]/following-sibling::em[text()="(minor)"]',
	  );

# test that ordinary RC doesn't show the rollback stuff
update_page('Yoga', 'Ommmm', 'peace');

$page = get_page('action=rc raw=1');
test_page($page,
	  "title: NicePage\ndescription: good guy two\n",
	  "title: MinorPage\ndescription: tester\n",
	  "title: OtherPage\ndescription: another good guy\n",
	  "title: InnocentPage\ndescription: good guy zero\n",
	  "title: Yoga\ndescription: peace\n",
	  );
test_page_negative($page,
		   "rollback",
		   "Rollback",
		   "EvilPage",
		   "AnotherEvilPage",
		  );
