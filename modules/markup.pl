# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: markup.pl,v 1.3 2004/06/19 19:02:58 as Exp $</p>';

push(@MyRules, \&MarkupRule);

sub MarkupRule {
  if (m/\G\*([A-Za-z\x80-\xff][A-Za-z\x80-\xff ]*?)\*/gc) {
    return "<b>$1</b>";
  } elsif (m/\G\/([A-Za-z\x80-\xff][A-Za-z\x80-\xff ]*?)\//gc) {
    return "<i>$1</i>";
  } elsif (m/\G_([A-Za-z\x80-\xff][A-Za-z\x80-\xff ]*?)_/gc) {
    return "<u>$1</u>";
  } elsif (m/\G~([A-Za-z\x80-\xff][A-Za-z\x80-\xff ]*?)~/gc) {
    return "<em>$1</em>";
  } elsif (m/\G-\&gt; /gc) {
    return '&#x2192; '; # RIGHTWARDS ARROW
  } elsif (m/\G -- /gc) {
    return '&#x2014;'; # EM DASH
  } elsif (m/\G\.\.\./gc) {
    return '&#x2026;'; # HORIZONTAL ELLIPSIS
  }
  return undef;
}
