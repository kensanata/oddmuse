# Copyright (C) 2009, 2014  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 9;
clear_pages();

# old log entry to be moved
my $log = join($FS, '1235079422', 'Ganz_und_Gar', '',
	       'Ladenbeschreibung und Preisliste', '62.12.165.34',
	       'Alex', '1', '', '');
WriteStringToFile($RcFile, $log . "\n");
test_page(get_page('action=maintain pwd=foo'),
	  'Moving 1 log entries');
test_page(ReadFileOrDie($RcOldFile),
	  "^1235079422$FS");
is(ReadFileOrDie($RcFile), '', 'empty rc.log');
update_page('test', 'this is a test');
my $log = ReadFileOrDie($RcFile);
test_page($log,
	  "${FS}test${FS}",
	  "${FS}this is a test${FS}");
test_page_negative($log, "^\n");

# old page to be deleted
OpenPage('test');
$Page{ts} = 1;
$Page{revision} = 1;
$Page{text} = $DeletedPage;
SavePage();
ok(-f GetPageFile($OpenPageName), GetPageFile($OpenPageName)
   . " exists");
xpath_test(get_page('action=maintain pwd=foo'),
	   '//a[text()="test"]/following-sibling::text()[.=" deleted"]');
ok(! -e GetPageFile($OpenPageName), GetPageFile($OpenPageName)
   . " was deleted");
