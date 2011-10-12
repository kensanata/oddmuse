#! /usr/bin/perl
# Copyright (C) 2011  Alex Schroeder <alex@gnu.org>

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

package OddMuse;

# http://nedbatchelder.com/text/stopbots.html

*HoneyPotOldGetFormStart = *GetFormStart;
*GetFormStart = *HoneyPotNewGetFormStart;

my $HoneyPotWasHere = 0;

sub HoneyPotNewGetFormStart {
  my $html = HoneyPotOldGetFormStart(@_);
  if (not $HoneyPotWasHere) {
    $HoneyPotWasHere = 1;
    # TODO: randomize names
    $html .= $q->div({-style=>'display:none'},
		     $q->textfield({-name=>'ok', -id=>'ok',
				    -default=>time,
				    -size=>40, -maxlength=>250}),
		     $q->label({-for=>'idiot'}, 'Leave empty:'), ' ',
		     $q->textfield({-name=>'idiot', -id=>'idiot',
				    -size=>40, -maxlength=>250}),
		     $q->textarea(-name=>'looser', -id=>'idiot',
				  -rows=>5, -columns=>78));
  }
  return $html;
}

# TODO: kill requests that filled in data into the honeypots
