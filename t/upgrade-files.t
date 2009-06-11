# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Create a UseModWiki first.
$_ = 'nocgi';
require 't/usemod-1.0.4.pl';

package UseModWiki;

InitRequest();
InitLinkPatterns();
$q->param('oldtime', '1');
$q->param('title', 'TestPage');
$q->param('text', 'Converting to Oddmuse');
$q->param('summary', 'Last UseModWiki edit');
{
  local *STDOUT;
  my $result;
  open(STDOUT, '>', \$result) or die "Can't open memory file: $!";
  DoOtherRequest();
}

require 't/test.pl';
package OddMuse;
$DataDir = $UseModWiki::DataDir;
$ENV{WikiDataDir} = $DataDir;
Init(); # again

use Test::More tests => 11;

# check whether old wiki was created successfully
ok(-d $UseModWiki::DataDir, "$UseModWiki::DataDir created");
ok(-f UseModWiki::GetPageFile('TestPage'), "TestPage was created");
ok(-f $UseModWiki::RcFile, "log file was created");

my $output = `perl upgrade-files.pl separator='UseMod 1.00' dir='$UseModWiki::DataDir' sure=yes`;
test_page_negative($output, 'does not seem to be a data directory');
test_page($output, "Reading page " . UseModWiki::GetPageFile('TestPage'),
	  "Writing " . GetPageFile('TestPage'),
	  "Reading $UseModWiki::RcFile",
	  "Writing $RcFile");

test_page(get_page('action=browse id=TestPage raw=1'), 'Converting to Oddmuse');
test_page(get_page('action=rc raw=1'), 'title: TestPage', 'description: Last UseModWiki edit');
