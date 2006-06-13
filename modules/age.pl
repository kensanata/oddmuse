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

$ModulesDescription .= '<p>$Id: age.pl,v 1.5 2006/06/13 18:01:57 as Exp $</p>';

use vars qw(%AgeEffect $AgeParameter);

# map page age to theme
%AgeEffect = (60*60*24 => 'day',
	      60*60*24*7 => 'week',
	      60*60*24*28 => 'moon',
	      60*60*24*365 => 'year',
	     );

# attribute in the page file to use as the timestamp -- use 'created'
# if using creationdate.pl.
$AgeParameter = 'ts';

*OldAgeGetHeader = *GetHeader;
*GetHeader = *NewAgeGetHeader;

sub NewAgeGetHeader {
  my $header = OldAgeGetHeader(@_);
  return $header unless $Page{$AgeParameter}; # open page required
  my $age = $Now - $Page{$AgeParameter};
  my $theme = '';
  for my $seconds (sort {$b <=> $a} keys %AgeEffect) {
    if ($age > $seconds) {
      $theme = $AgeEffect{$seconds};
      last;
    }
  }
  return $header unless $theme;
  $oldtheme = GetParam('theme', $ScriptName);
  $header =~ s/class="$oldtheme"/class="$theme"/; # touch as little as possible
  return $header;
}
