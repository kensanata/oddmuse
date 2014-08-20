# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/emoji.pl">emoji.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Logo_And_Icons#Smilies">Logo And Icons</a></p>';

push(@MyRules, \&EmojiRule);
# this can be last
$RuleOrder{\&EmojiRule} = 500;

sub EmojiRule {
  if (m/\G:-?D/cg) {
    # 😀 1F600 GRINNING FACE
    return '&#x1F600;';
  }  elsif (/\G:-?\)/cg) {
    # 😊 1F60A SMILING FACE WITH SMILING EYES
    return '&#x1F60A;';
  }  elsif (/\G:-?\(/cg) {
    # 😟 1F61F WORRIED FACE
    return '&#x1F61F;';
  }  elsif (/\G;-?\)/cg) {
    # 😉 1F609 WINKING FACE
    return '&#x1F609;';
  }  elsif (/\G:'\(/cg) {
    # 😢 1F622 CRYING FACE
    return '&#x1F622;';
  }  elsif (/\G:'\[/cg) {
    # 😠 1F620 ANGRY FACE
    return '&#x1F620;';
  }  elsif (/\G:-[Ppb]/cg) {
    # 😝 1F61D FACE WITH STUCK-OUT TONGUE AND TIGHTLY-CLOSED EYES
    return '&#x1F61D;';
  }  elsif (/\G&lt;3/cg) {
    # ❤ 2764 HEAVY BLACK HEART
    return '&#x2764;';
  }  elsif (/\G\^_*\^/cg) {
    # 😄 1F604 SMILING FACE WITH OPEN MOUTH AND SMILING EYES
    return '&#x1F604;';
  }  elsif (/\G\bO_o\b/cg) {
    # 😲 1F632 ASTONISHED FACE
    return '&#x1F632;';
  }
  return undef;
}
