# Copyright (C) 2009–2015  Alex Schroeder <alex@gnu.org>
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
use Test::More tests => 28;

add_module('big-brother.pl');

my $ts = time;
$VisitorTime = 10;

AppendStringToFile($ConfigFile,
		   "\$SurgeProtection = 1;\n"
		   . "\$VisitorTime = $VisitorTime;\n");

get_page('action=browse id=SomePage username=Alex');
get_page('username=Berta pwd=foo');
my $visitors = get_page('action=visitors');
my $item = xpath_test($visitors,
		      '//li[contains(., "Alex")]');
like($item, qr/Alex was here (just now|\d seconds? ago) and read SomePage/,
     'Alex was here and read SomePage');

my $item = xpath_test($visitors,
		      '//li[contains(., "Berta")]');
like($item, qr/Berta was here (just now|\d seconds? ago) and read some action/,
     'Berta was here and read some action');
unlike($item, qr/pwd/, 'Link does not contain password');

# check surge protection still works (taking into account the previous
# get_page call for username=Alex
for (2 .. $SurgeProtectionViews - 1) {
  test_page(get_page('action=browse id=HomePage username=Alex'),
	    'Status: 404 NOT FOUND');
}
my $load = 0;
test_page(get_page('action=browse id=OneExtraPage username=Alex'),
	  'Status: 503 SERVICE UNAVAILABLE');

my ($status, $data) = ReadFile($VisitorFile);
ok($status, "Read $VisitorFile");
%BigBrotherData = ();
foreach (split(/\n/,$data)) {
  my ($name, %entries) = split /$FS/;
  $BigBrotherData{$name} = \%entries if $name and %entries;
}
my  %entries = %{$BigBrotherData{Alex}};
my @times = sort keys %entries;
# Under heavy load, we might have less...
ok(@times <= $SurgeProtectionViews, "$SurgeProtectionViews entries in the log file, or less");

# Since the latest entry into the log gets a +1 added whenever there is
# a duplicate entry, we might have entries in the list that are a few
# seconds into the future. Take this into account as we are waiting for
# $VisitorTime to expire.
my $seconds = $VisitorTime + $times[-1] - time() + 1;
diag("Waiting for ${seconds}s");
sleep $seconds;

test_page(get_page('action=browse id=AfterWaiting username=Alex'),
	  'Status: 404 NOT FOUND');
# now the previous 10 entries should have expired out of the log file

($status, $data) = ReadFile($VisitorFile);
%BigBrotherData = ();
foreach (split(/\n/,$data)) {
  my ($name, %entries) = split /$FS/;
  $BigBrotherData{$name} = \%entries if $name and %entries;
}
%entries = %{$BigBrotherData{Alex}};
@times = sort keys %entries;
ok(@times == 1, "just one entry remains in the log file after this wait ("
   . @times . ")");
