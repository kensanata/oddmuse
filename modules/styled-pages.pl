# Copyright (C) 2014-2017
#     Aleks-Daniel Jakimenko-Aleksejev <alex.jakimenko@gmail.com>
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

AddModuleDescription('styled-pages.pl', 'Styled Pages Extension');

our (@MyRules);
our ($StyledPagesPrefix);

$StyledPagesPrefix = 'style_';

push(@MyRules, \&StyledPagesRule);

my $StyledPage = '';

sub StyledPagesRule {
  if (!$StyledPage and m/\G (^|\n)? \#STYLE [ \t]+ ([a-z_-][a-z0-9 _-]+[a-z0-9_-]) \s*(\n+|$) /cgx) {
    $StyledPage = 1;
    return CloseHtmlEnvironments()
        . '<div class="' . join(' ', map {"$StyledPagesPrefix$_"} split /\s+/, $2) . '">'
        . AddHtmlEnvironment('p');
  }
  if ($StyledPage and m/\G $/cgx) {
      return CloseHtmlEnvironments() . '</div>';
  }
  return;
}
