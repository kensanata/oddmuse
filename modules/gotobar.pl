# Copyright (C) 2006-2014  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2016  Ingo Belka
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

our (%Page, %IndexHash, %AdminPages, $HomePage, $RCName, @MyInitVariables, $LinkPattern, $FreeLinkPattern, $FullUrlPattern, $InterLinkPattern, $UserGotoBar, @UserGotoBarPages);

AddModuleDescription('gotobar.pl', 'Gotobar Extension');

our ($GotobarName);

# Include this page on every page:

$GotobarName = 'GotoBar';

our ($GotobarSetHome, $GotobarSetRC);
# 0 does set home-link and/or rc-link automatically, 1 doesn't

# do this later so that the user can customize $GotobarName
push(@MyInitVariables, \&GotobarInit);

sub GotobarInit {
  $GotobarName = FreeToNormal($GotobarName); # spaces to underscores
  $AdminPages{$GotobarName} = 1;
  my $id = GetId();
  my $encoded = UrlEncode($id);
  if ($IndexHash{$GotobarName}) {
    OpenPage($GotobarName);
    return if PageMarkedForDeletion();
    # Don't use @UserGotoBarPages because this messes up the order of
    # links for unsuspecting users.
    @UserGotoBarPages = ();
    $UserGotoBar = '';
    my $text = $Page{text};
    $text =~ s/\$\$id\b/$encoded/g;
    $text =~ s/\$id\b/$id/g;
    my $count = 0;
    while ($text =~ m/($LinkPattern|\[\[$FreeLinkPattern\]\]|\[\[$FreeLinkPattern\|([^\]]+)\]\]|\[$InterLinkPattern\s+([^\]]+?)\]|\[$FullUrlPattern[|[:space:]]([^\]]+?)\])/g) {
      my $page = $2||$3||$4||$6||$8;
      my $text = $5||$7||$9;
      $UserGotoBar .= ' ' if $UserGotoBar;
      if ($6) {
	$UserGotoBar .= GetInterLink($page, $text);
      } elsif ($8) {
	$UserGotoBar .= GetUrl($page, $text);
      } else {
	$UserGotoBar .= GetPageLink($page, $text);
	# The first local page is the homepage, the second local page
	# is the list of recent changes.
	$count++;
	if ($count == 1) {
	  unless ($GotobarSetHome) {$HomePage = FreeToNormal($page)};
	} elsif ($count == 2) {
	  unless ($GotobarSetRC) {$RCName = FreeToNormal($page);}
	}
      }
    }
  }
}
