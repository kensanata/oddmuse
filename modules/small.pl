# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

use strict;
use v5.10;

AddModuleDescription('small.pl', 'List Small Pages Extension');
our ($q, %Page, %Action, $DeletedPage, $LinkPattern, $FreeLinks, $FreeLinkPattern, $WikiLinks);

my $SmallLimit = 1000;

$Action{small} = \&DoSmall;

sub DoSmall {
  print GetHeader('', T('Index of all small pages')),
    $q->start_div({-class=>'content index small'}),
    $q->start_p();
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    if (length($Page{text}) < $SmallLimit
	# skip redirects
	and (not $FreeLinks
	     or $Page{text} !~ /^\#REDIRECT\s+\[\[$FreeLinkPattern\]\]/)
	and (not $WikiLinks
	     or $Page{text} !~ /^\#REDIRECT\s+$LinkPattern/)
	# skip deleted pages
	and $Page{text} !~ /^\s*$/
	and (not $DeletedPage
	     or substr($Page{text}, 0, length($DeletedPage)) ne $DeletedPage)) {
      PrintPage($id);
    }
  }
  print $q->end_p(), $q->end_div();
  PrintFooter();
}
