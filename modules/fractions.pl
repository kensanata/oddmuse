# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

AddModuleDescription('fractions.pl', 'Fractions');

push(@MyRules, \&FractionsRule);

# usage: ^1/32
sub FractionsRule {
  if (/\G\^([0-9]+)\/([0-9]+)/cg) {
    if    ($1 == 1 and $2 == 4)  { return "\&#x00bc;"; }
    elsif ($1 == 1 and $2 == 2)  { return "\&#x00bd;"; }
    elsif ($1 == 3 and $2 == 4)  { return "\&#x00be;"; }
    elsif ($1 == 1 and $2 == 7)  { return "\&#x2150;"; }
    elsif ($1 == 1 and $2 == 9)  { return "\&#x2151;"; }
    elsif ($1 == 1 and $2 == 10) { return "\&#x2152;"; }
    elsif ($1 == 1 and $2 == 3)  { return "\&#x2153;"; }
    elsif ($1 == 2 and $2 == 3)  { return "\&#x2154;"; }
    elsif ($1 == 1 and $2 == 5)  { return "\&#x2155;"; }
    elsif ($1 == 2 and $2 == 5)  { return "\&#x2156;"; }
    elsif ($1 == 3 and $2 == 5)  { return "\&#x2157;"; }
    elsif ($1 == 4 and $2 == 5)  { return "\&#x2158;"; }
    elsif ($1 == 1 and $2 == 6)  { return "\&#x2159;"; }
    elsif ($1 == 5 and $2 == 6)  { return "\&#x215a;"; }
    elsif ($1 == 1 and $2 == 8)  { return "\&#x215b;"; }
    elsif ($1 == 3 and $2 == 8)  { return "\&#x215c;"; }
    elsif ($1 == 5 and $2 == 8)  { return "\&#x215d;"; }
    elsif ($1 == 7 and $2 == 8)  { return "\&#x215e;"; }
    else {
      my $html;
      # superscripts
      for my $char (split(//, $1)) {
	if    ($char eq '1') { $html .= "\&#x00b9;"; }
	elsif ($char eq '2') { $html .= "\&#x00b2;"; }
	elsif ($char eq '3') { $html .= "\&#x00b3;"; }
	else                 { $html .= "\&#x207$char;"; }
      }
      # fraction slash
      $html .= '&#x2044;';
      # subscripts
      for my $char (split(//, $2)) {
	$html .= "\&#x208$char;";
      }
      return $html;
    }
  }
  return undef;
}
