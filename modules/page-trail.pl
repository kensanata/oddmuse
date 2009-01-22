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

use vars qw($PageTrailLength);

$PageTrailLength = 10;

$ModulesDescription .= '<p>$Id: page-trail.pl,v 1.6 2009/01/22 00:33:40 as Exp $</p>';

$CookieParameters{trail} = '';
$InvisibleCookieParameters{trail} = 1;
my @PageTrail;

*OldPageTrailBrowsePage = *BrowsePage;
*BrowsePage = *NewPageTrailBrowsePage;

sub NewPageTrailBrowsePage {
  my ($id, @rest) = @_;
  UpdatePageTrail($id);
  OldPageTrailBrowsePage($id, @rest);
}

sub UpdatePageTrail {
  my $id = shift;
  my @trail = ($id);
  foreach my $page (split(/ /, GetParam('trail', ''))) {
    push(@trail, $page) unless $page eq $id;
  }
  @trail = @trail[0..$PageTrailLength-1] if $trail[$PageTrailLength];
  $q->param('trail', join(' ', @trail));
  @PageTrail = @trail;
}

*OldPageTrailGetGotoBar = *GetGotoBar;
*GetGotoBar = *NewPageTrailGetGotoBar;

sub NewPageTrailGetGotoBar {
  my $bar = OldPageTrailGetGotoBar(@_);
  $bar .= $q->span({-class=>'trail'}, $q->br(), T('Trail: '),
		   map { GetPageLink($_) } reverse(@PageTrail))
    if @PageTrail;
  return $bar;
}
