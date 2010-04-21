# Copyright (C) 2006, 2007, 2008  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 63;

clear_pages();
WriteStringToFile($RcFile, "1FirstPage1\n");
AppendStringToFile($RcFile, "2SecondPage1\n");

# reproduce a particular bug from emacswiki.org
clear_pages();
update_page('SiteMap', 'initial entry');
sleep(1);
update_page('SiteMap', 'last good entry was a minor edit', '', 1);
ok(get_page('action=browse id=SiteMap raw=2')
   =~ /(\d+) # Do not delete this line/,
   'raw=2 returns timestamp');
$to = $1;
ok($to, 'timestamp stored');
sleep(1);
update_page('SiteMap', 'vandal overwrites with major edit');
update_page('SiteMap', 'gnome attemps wrong fix with minor edit', '', 1);
test_page(get_page("action=rollback to=$to pwd=foo"),
	  'Rolling back changes', 'SiteMap</a> rolled back');
OpenPage('SiteMap');
isnt($Page{minor}, 1, 'Rollback is a major edit');
is($Page{text}, "last good entry was a minor edit\n", 'Rollback successful');

# new set of tests
clear_pages();
WriteStringToFile($RcFile, "1FirstPage1\n");
AppendStringToFile($RcFile, "2SecondPage1\n");

# old revisions
update_page('InnocentPage', 'Innocent.', 'good guy zero');
update_page('NicePage', 'Friendly content.', 'good guy one');
update_page('OtherPage', 'Other cute content 1.', 'another good guy');
update_page('OtherPage', 'Other cute content 2.', 'another good guy');
update_page('OtherPage', 'Other cute content 3.', 'another good guy');

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

# find the rollback link for the last good revision
$to = xpath_test(get_page('action=rc all=1 pwd=foo'),
		 '//strong[text()="good guy two"]/preceding-sibling::input[@type="submit"]/attribute::name');
$to =~ /rollback-([0-9]+)/;
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

# this includes rollback info and rollback links
my $rc = get_page('action=rc all=1 showedit=1 pwd=foo from=1');

# check all revisions of NicePage in recent changes
xpath_test($rc,
	   '//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=1"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="good guy one"]',
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=2"][text()="diff"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=2"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="good guy two"]',
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=3"][text()="diff"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=3"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="vandal one"]',
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=4"][text()="diff"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=4"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="vandal two"]',
	   # The first link to NicePage has no diffrevision (because
	   # it is the latest version) and no rollback link (because
	   # the timestamp is equal to $LastUpdate)
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage"][text()="diff"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[contains(text(),"Rollback to")]',
	   # The second link to NicePage has a diffrevision (because
	   # it is from an older version) and a rollback link (because
	   # the timestamp is smaller than $LastUpdate)
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=4"][text()="diff"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=4"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="vandal two"]',
	   # check that the minor spam is reverted with a minor rollback
	   '//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage;revision=1"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="tester"]',
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=MinorPage;diffrevision=2"][text()="diff"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage;revision=2"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="testerror"]/following-sibling::em[text()="(minor)"]',
	   # The first link has no diffrevision (because it is the
	   # latest version) and no rollback link (because the
	   # timestamp is equal to $LastUpdate)
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=MinorPage"][text()="diff"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[contains(text(),"Rollback to")]/following-sibling::em[text()="(minor)"]',
	   # The second link has a diffrevision (because it is from an
	   # older version) and a rollback link (because the timestamp
	   # is smaller than $LastUpdate)
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=MinorPage;diffrevision=2"][text()="diff"]/following-sibling::input[@type="submit"][@value="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage;revision=2"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="testerror"]/following-sibling::em[text()="(minor)"]',
	   # The first page has no rollback link
	   '//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=FirstPage"][text()="FirstPage"]',
	   # The second page has a rollback link
	   '//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::input[@type="submit"][@value="rollback"][@name="rollback-2"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=SecondPage"][text()="SecondPage"]',
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

# test url encoding
test_page(update_page('Schröder', 'Alex', 'eins'), 'Alex');
$to = (stat($IndexFile))[9];
sleep(1);
test_page(update_page('HiddenEdit', 'not to be rolled back', 'secret'), 'not to be rolled back');
test_page(update_page('Schröder', 'Berta', 'zwei'), 'Berta');
xpath_test(get_page('action=history id=Schr%c3%b6der username=olaf'),
	   '//input[@type="submit"][@value="rollback"][@name="rollback-' . $to . '"]');

# test single page rollback
test_page(get_page("action=rollback to=$to id=Schr%c3%b6der username=olaf"),
	  'Rolling back changes',
	  'Schröder</a> rolled back');
test_page(get_page('Schr%c3%b6der'), 'Alex');

# make sure it is hidden from recent changes
$page = get_page('action=rc raw=1');
test_page($page, "title: Schröder\ndescription: eins\n",
	  "title: HiddenEdit\ndescription: secret\n");
test_page_negative($page, "title: Schröder\ndescription: zwei\n");

# make sure that rollback=1 shows the rollback link
test_page(get_page('action=rc raw=1 rollback=1'),
	  "title: Schröder\ndescription: Rollback to ",
	  "title: HiddenEdit\ndescription: secret\n");
# all=1 shows all links including rollbacks
test_page(get_page('action=rc raw=1 rollback=1 all=1'),
	  "title: Schröder\ndescription: Rollback to ",
	  "title: Schröder\ndescription: zwei\n",
	  "title: Schröder\ndescription: eins\n",
	  "title: HiddenEdit\ndescription: secret\n",
	  'link: http://localhost/wiki.pl/Schr%c3%b6der',
	  'link: http://localhost/wiki.pl\?action=browse;id=Schr%c3%b6der;revision=2',
	  'link: http://localhost/wiki.pl\?action=browse;id=Schr%c3%b6der;revision=1');

# Making sure no extra [[rollback]] entries show up
clear_pages();
update_page('Test', 'Hallo');
$ts = $Now - $KeepDays * 86400 + 100;
get_page("action=rollback to=$ts username=Alex pwd=foo");
AppendStringToFile($ConfigFile, "\$KeepDays = 7;\n");
test_page_negative(get_page("action=rc raw=1"), '[[rollback]]');
