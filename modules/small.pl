# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: small.pl,v 1.1 2007/01/31 12:00:23 as Exp $</p>';

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
