# Copyright (C) 2009–2018  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require './t/test.pl';
package OddMuse;
use Test::More tests => 20;

my $hundred_days_ago = $Now - 100 * 24 * 60 * 60;
my $ten_days_ago = $Now - 10 * 24 * 60 * 60;
my $two_days_ago = $Now - 2 * 24 * 60 * 60;
my $ip = '127.0.0.1';
# $ts, $id, $minor, $summary, $host, @rest

# First, make sure that moving all the entries from rc.log leaves no newline in
# the file.

my $log = join("\n",
	       join($FS, $hundred_days_ago, 'Two_Hundred_Days_Ago', '',
		    'Boring', $ip,
		    'Alex', '1', '', ''),
	       '');
WriteStringToFile($RcFile, $log);

test_page(get_page('action=maintain pwd=foo'),
	  'Moving 1 log entries',
	  'Removing IP numbers from 0 log entries');
$log = ReadFileOrDie($RcOldFile);
test_page($log, "Hundred_Days_Ago.*Anonymous");
test_page_negative($log, $ip);
$log = ReadFileOrDie($RcFile);
is($log, '', 'rc.log is empty');

# Now let's make sure that an old entry get anonymized and moved (like the
# previous test), and that those that are not moved care anonymized if they are
# old enough.

$log = join("\n",
	    join($FS, $hundred_days_ago, 'One_Hundred_Days_Ago', '',
		 'Boring', $ip,
		 'Alex', '1', '', ''),
	    join($FS, $ten_days_ago, 'Ten_Days_Ago', '',
		 'Boring', $ip,
		 'Alex', '1', '', ''),
	    join($FS, $two_days_ago, 'Two_Days_Ago', '',
		 'Boring', $ip,
		 'Alex', '1', '', ''),
	    '');
WriteStringToFile($RcFile, $log);

test_page(get_page('action=maintain pwd=foo'),
	  'Moving 1 log entries',
	  'Removing IP numbers from 1 log entries');
$log = ReadFileOrDie($RcOldFile);
test_page($log,
	  "Two_Hundred_Days_Ago.*Anonymous",
	  "One_Hundred_Days_Ago.*Anonymous");
test_page_negative($log, $ip);
$log = ReadFileOrDie($RcFile);
test_page($log,
	  "Ten_Days_Ago.*Anonymous",
	  "Two_Days_Ago.*$ip");
test_page_negative($log, "Hundred_Days_Ago");

# Let's make sure that updating pages write the right rc lines.

update_page('test', 'this is a test');
my $log = ReadFileOrDie($RcFile);
test_page($log,
	  "${FS}test${FS}",
	  "${FS}this is a test${FS}");
test_page_negative($log, "^\n");

# Make sure that pages to be deleted are in fact deleted.

OpenPage('test');
$Page{ts} = 1;
$Page{revision} = 1;
$Page{text} = $DeletedPage;
SavePage();
AppendStringToFile($ConfigFile, "\$KeepDays = 14;\n");
ok(-f GetPageFile($OpenPageName), GetPageFile($OpenPageName)
   . " exists");
xpath_test(get_page('action=maintain pwd=foo'),
	   '//a[text()="test"]/following-sibling::text()[.=" deleted"]');
ok(! -e GetPageFile($OpenPageName), GetPageFile($OpenPageName)
   . " was deleted");
my $data = ReadFileOrDie($DeleteFile);
ok($data eq "test\n", "Delete was logged");
