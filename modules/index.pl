# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: index.pl,v 1.1 2004/09/19 01:14:59 as Exp $</p>';

$Action{'printable-index'} = \&DoPrintableIndex;

sub DoPrintableIndex {
  print GetHeader('', T('Index'), '');
  my @pages = PrintableIndexPages();
  my %hash;
  map { push(@{$hash{GetPageDirectory($_)}}, $_); } @pages;
  print $q->p($q->a({-name=>"top"}),
	      map { $q->a({-href=>"#$_"}, $_); } sort keys %hash);
  foreach my $title (sort keys %hash) {
    print '<div class="letter">';
    print $q->h2($q->a({-name=>$title}, $title));
    foreach my $page (@{$hash{$title}}) {
      PrintPage($page);
    }
    print '</div>';
  }
  PrintFooter();
}

# Mostly DoIndex() without the printing.
sub PrintableIndexPages {
  my @pages;
  my $pages = GetParam('pages', 1);
  my $anchors = GetParam('permanentanchors', 1);
  my $near = GetParam('near', 0);
  ReadPermanentAnchors() if $anchors and not $PermanentAnchorsInit;
  NearInit() if $near and not $NearSiteInit;
  push(@pages, AllPagesList()) if $pages;
  push(@pages, keys %PermanentAnchors) if $anchors;
  push(@pages, keys %NearSource) if $near;
  return @pages;
}
