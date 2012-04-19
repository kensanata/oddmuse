# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

use vars qw{$SmileyDir $SmileyUrlPath};

$SmileyDir = '/mnt/pics'; # directory with all the smileys
$SmileyUrlPath = '/pics'; # path where all the smileys can be found (URL)

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/smiley-dir.pl">smiley-dir.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Smiley_Directory_Extension">Smiley Directory Extension</a></p>';

push(@MyInitVariables, \&SmileyDirInit);

sub SmileyDirInit {
  if (opendir(DIR, $SmileyDir)) {
    map {
      if (/^((.*)\.$ImageExtensions$)/ and -f "$SmileyDir/$_") {
	my $regexp = quotemeta("{$2}");
	$Smilies{$regexp} = "$SmileyUrlPath/$1";
      }
    } readdir(DIR);
    closedir DIR;
  }
}
