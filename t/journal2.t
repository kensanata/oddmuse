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
use Test::More tests => 8;

clear_pages();

# Now let us test a more elaborate setup: Use TimeToRFC822 for pages.
# Change JournalSort and Today accordingly, and test the past and
# future stuff.

sub DateToRFC822 {
  my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime(shift); # Sat, 07 Sep 2002 00:00:01 GMT
  return sprintf("%s, %02d %s %04d", qw(Sun Mon Tue Wed Thu Fri Sat)[$wday], $mday,
		 qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon], $year+1900);
}

$today = DateToRFC822($Now);
$tomorrow = DateToRFC822($Now + 24*60*60);
$yesterday = DateToRFC822($Now - 24*60*60);

update_page($yesterday, "Freitag");
update_page($today, "Samstag");
update_page($tomorrow, "Sonntag");

AppendStringToFile($ConfigFile, q{
sub DateToRFC822 {
  my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime(shift); # Sat, 07 Sep 2002 00:00:01 GMT
  return sprintf("%s, %02d %s %04d", qw(Sun Mon Tue Wed Thu Fri Sat)[$wday], $mday,
		 qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon], $year+1900);
}

sub RFC822toISO {
  $_ = NormalToFree(shift);
  ($wday, $mday, $mon, $year) = /^(Sun|Mon|Tue|Wed|Thu|Fri|Sat), (\d\d) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d\d\d\d)$/;
  %month = qw(Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 Aug 8 Sep 9 Oct 10 Nov 11 Dec 12);
  $mon = $month{$mon};
  return sprintf("%04d-%02d-%02d", $year, $mon, $mday);
}

sub JournalSort { RFC822toISO($b) cmp RFC822toISO($a); }

push(@MyInitVariables, sub { $Today = FreeToNormal(DateToRFC822($Now)); });
});

# now check all pages
test_page(update_page('Summary', q{Counting down:
<journal "^(Sun|Mon|Tue|Wed|Thu|Fri|Sat),_(\d\d)_(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)_(\d\d\d\d)">}),
          "$tomorrow.*$today.*$yesterday");

# check reverse order
test_page(update_page('Summary', q{Counting up:
<journal "^(Sun|Mon|Tue|Wed|Thu|Fri|Sat),_(\d\d)_(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)_(\d\d\d\d)" reverse>}),
	  "$yesterday.*$today.*$tomorrow");

# check past; use xpath because $today will also match "Last edited ... by ..."
$page = update_page('Summary', q{Only past pages:
<journal "^(Sun|Mon|Tue|Wed|Thu|Fri|Sat),_(\d\d)_(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)_(\d\d\d\d)" past>});
xpath_test($page, "//a[text()='$yesterday']");
negative_xpath_test($page, "//a[text()='$today']",
		    "//a[text()='$tomorrow']");

# check future
$page = update_page('Summary', q{Only future pages:
<journal "^(Sun|Mon|Tue|Wed|Thu|Fri|Sat),_(\d\d)_(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)_(\d\d\d\d)" future>});
xpath_test($page, "//a[text()='$tomorrow']");
negative_xpath_test($page, "//a[text()='$today']",
		    "//a[text()='$yesterday']");
