# Copyright (C) 2021  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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

AddModuleDescription('cook-lang.pl', 'Cooklang Extension');

our ($q, $bol, @MyRules);

push(@MyRules, \&CookLangRule);

sub CookLangRule {
  if (/\G#([^\n#\@\{\}]+)\{(?:([^\n%\}]+)(?:%([^\n\}]+))?)?\}/cg) {
    # #canning funnel{}
    my $html = "";
    $html .= $q->strong({-title=>"number"}, $2) if $2;
    $html .= " " if $2 and $3;
    $html .= $q->strong({-title=>"unit"}, $3) if $3;
    $html .= " " if $1 and ($2 or $3);
    $html .= $q->strong({-title=>"cookware"}, $1);
    return $html;
  } elsif (/\G#(\w+)/cg) {
    # #pot
    return $q->strong({-title=>"cookware"}, $1);
  } elsif (/\G\@([^\n#\@\{\}]+)\{(?:([^\n%\}]+)(?:%([^\n\}]+))?)?\}/cg) {
    # @ground black pepper{}
    my $html = "";
    $html .= $q->strong({-title=>"number"}, $2) if $2;
    $html .= " " if $2 and $3;
    $html .= $q->strong({-title=>"unit"}, $3) if $3;
    $html .= " " if $1 and ($2 or $3);
    $html .= $q->strong({-title=>"ingredient"}, $1);
    return $html;
  } elsif (/\G\@(\w+)/cg) {
    # @salt
    return $q->strong({-title=>"ingredient"}, $1);
  } elsif (/\G\~\{([^\n%\}]+)(?:%([^\n\}]+))?\}/cg) {
    # ~{25%minutes}
    my $html = $q->strong({-title=>"number"}, $1);
    $html .= " " if $1 and $2;
    $html .= $q->strong({-title=>"unit"}, $2) if $2;
    return $html;
  } elsif (/\G\/\/\s*(.*)/cg) {
    # // Don't burn the roux!
    return $q->em({-title=>"comment"}, $1);
  } elsif ($bol and /\G&gt;&gt;\s*(.*)/cg) {
    # // Don't burn the roux!
    return CloseHtmlEnvironments()
	. $q->blockquote({-title=>"meta"}, $1)
	. AddHtmlEnvironment('p');
  }
  # no match
  return;
}
