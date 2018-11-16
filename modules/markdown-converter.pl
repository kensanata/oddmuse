#! /usr/bin/perl
# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>

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

AddModuleDescription('markdown-converter.pl', 'Markdown Convert');

our (%Action, @MyAdminCode);

push(@MyAdminCode, \&AdminPower);

sub AdminPower {
  return unless UserIsAdmin();
  my ($id, $menuref, $restref) = @_;
  my $name = $id;
  $name =~ s/_/ /g;
  if ($id) {
    push(@$menuref, ScriptLink('action=convert;id=' . $id, Ts('Help convert %s to Markdown', $name), 'convert'));
  }
}

$Action{convert} = \&MarkdownConvert;

# some text that doesn't start and end with a space, or just one non-space
sub MarkdownConvertString {
  my $c = shift;
  return qr"([^\\$c \n][^\\$c\n]*[^\\$c \n]|[^\\$c \n])";
}

sub MarkdownConvert {
  my $id = GetParam('id', '');
  ValidIdOrDie($id);
  print GetHeader('', Ts('Converting %s', $id), '');
  $_ = GetPageContent($id);

  s/^\{\{\{((?:.*\n)+)\}\}\}$/```$1```/gm;

  my $s = MarkdownConvertString('*');
  s/\*$s\*/**$1**/g;

  # avoid URL schemas like http://example.org
  $s = MarkdownConvertString('/');
  s#(?<!:/)/$s/#*$1*#g;
  s#(?<!:)//$s//#*$1*#g;


  s/^# /1. /gm;

  s/##(.*)##/`$1`/g;

  s/^(=+) (.*) =+$/'#' x length($1) . $2/gme;

  s!\[(https?://\S+) (.*?)\]![$2]($1)!g;

  return DoEdit($id, "#MARKDOWN\n" . $_, 1); # preview
}
