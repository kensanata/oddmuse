# Copyright (C) 2004  Sebastian Blatt <sblatt@havens.de>
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

# Makes the wiki logo depend on the current date.
#
# Example Usage: Put the following into your config file and modify as
# needed:
#
#  $DynLogoDirectory = '/mypic/dynlogo';
#  $DynLogoDefault = 'wiki.jpg';
#  %DynLogoMap = ('\d{4}-12-31' => 'party.jpg');
#  $LogoUrl = GetDynLogoUrl();
#

$ModulesDescription .= '<p>$Id: dynlogo.pl,v 1.2 2004/10/02 08:40:01 sblatt Exp $</p>';

use vars qw($DynLogoDirectory $DynLogoDefault %DynLogoMap);

# Directory to search for images.
$DynLogoDirectory = '/pic/dynlogo';

# Default logo in the $DynLogoDirectory.
$DynLogoDefault = 'logo.png';

# This maps a regular expression matching a date string of the form
# "%Y-%m-%d" to a filename in the $DynLogoDirectory. Example usage:
# %DynLogoMap = ('\d{4}-12-24'=>'logo-1224.jpg');
%DynLogoMap = ();

sub GetDynLogoUrl {
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
  my $today = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
  foreach $k(keys(%DynLogoMap)) {
    if ($today=~m/$k/) {
      return $DynLogoDirectory."/".$DynLogoMap{$k};
    }
  }
  return "$DynLogoDirectory/$DynLogoDefault";
}
