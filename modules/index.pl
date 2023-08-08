# Copyright (C) 2004, 2007  Alex Schroeder <alex@emacswiki.org>
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

AddModuleDescription('index.pl', 'Index Extension');

our ($q, %Action, %PermanentAnchors, %NearSource);
$Action{'printable-index'} = \&DoPrintableIndex;

sub DoPrintableIndex {
  print GetHeader('', T('Index'), '');
  my @pages = PrintableIndexPages();
  my %hash;
  map { push(@{$hash{substr($_,0,1)}}, $_); } @pages;
  print '<div class="content printable index">';
  print $q->p($q->a({-name=>"top"}),
	      map { $q->a({-href=>"#$_"}, $_); } sort keys %hash);
  foreach my $title (sort keys %hash) {
    print '<div class="letter">';
    print $q->h2($q->a({-name=>$title}, $title));
    foreach my $id (@{$hash{$title}}) {
      PrintPage($id);
    }
    print '</div>';
  }
  print '</div>';
  PrintFooter();
}

# Mostly DoIndex() without the printing.
sub PrintableIndexPages {
  my @pages;
  push(@pages, AllPagesList()) if GetParam('pages', 1);
  push(@pages, keys %PermanentAnchors) if GetParam('permanentanchors', 1);
  push(@pages, keys %NearSource) if GetParam('near', 0);
  return sort Matched(GetParam('match'), @pages);
}
