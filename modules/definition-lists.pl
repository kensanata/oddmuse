#! /usr/bin/perl
# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>

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

AddModuleDescription('definition-lists.pl', 'Definition Lists Extension');

our ($q, $bol, @MyRules, @HtmlStack, $Fragment);

push(@MyRules, \&DefinitionListsRule);

# term
# : definition

sub DefinitionListsRule {
  if ($bol and /\G(?:\s*\n)*(\S.*)\n[ \t]*:[ \t]*/cg) {
    return OpenHtmlEnvironment('dl', 1) . "<dt>$1</dt>" . AddHtmlEnvironment('dd');
  } elsif (InElement('dd') and /\G(?:\s*\n)+(\S.*)\n[ \t]*:[ \t]*/cg) {
    return OpenHtmlEnvironment('dl', 1) . "<dt>$1</dt>" . AddHtmlEnvironment('dd');
  } elsif (InElement('dd') and /\G(\s*\n)+[ \t]*:[ \t]*/cg) {
    return OpenHtmlEnvironment('dl', 1) . AddHtmlEnvironment('dd');
  }
  return;
}
