# Copyright (C) 2006-2014  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/gotobar.pl">gotobar.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Gotobar_Extension">Gotobar Extension</a></p>';

use vars qw($GotobarName);

# Include this page on every page:

$GotobarName = 'GotoBar';

# do this later so that the user can customize $GotobarName
push(@MyInitVariables, \&GotobarInit);

sub GotobarInit {
  $GotobarName = FreeToNormal($GotobarName); # spaces to underscores
  $AdminPages{$GotobarName} = 1;
  if ($IndexHash{$GotobarName}) {
    OpenPage($GotobarName);
    return if PageMarkedForDeletion();
    # Don't use @UserGotoBarPages because this messes up the order of
    # links for unsuspecting users.
    @UserGotoBarPages = ();
    $UserGotoBar = '';
    my $count = 0;
    while ($Page{text} =~ m/($LinkPattern|\[\[$FreeLinkPattern\]\]|\[\[$FreeLinkPattern\|([^\]]+)\]\]|\[$InterLinkPattern\s+([^\]]+?)\]|\[$FullUrlPattern[|[:space:]]([^\]]+?)\])/og) {
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
	  $HomePage = FreeToNormal($page);
	} elsif ($count == 2) {
	  $RCName = FreeToNormal($page);
	}
      }
    }
  }
}
