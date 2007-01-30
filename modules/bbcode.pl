# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: bbcode.pl,v 1.1 2007/01/30 15:36:05 as Exp $</p>';

push(@MyRules, \&bbCodeRule);

sub bbCodeRule {
  if (/\G(\[([a-z]+)(?:=([^]]+))?\])/cgi) {
    my $bbcode = $1;
    my $tag = $2;
    my $option = $3;
    if ($tag eq 'b') { 
      return AddHtmlEnvironment('b'); }
    elsif ($tag eq 'i') { 
      return AddHtmlEnvironment('i'); }
    elsif ($tag eq 'u') {
      return AddHtmlEnvironment('em', qq{style="text-decoration: underline; }
				. qq{font-style: normal;"}); }
    elsif ($tag eq 'color') {
      return AddHtmlEnvironment('em', qq{style="color: $option; }
				. qq{font-style: normal;"}); }
    elsif ($tag eq 'size') {
      $option *= 100;
      return $bbcode unless $option; # non-numeric?
      return AddHtmlEnvironment('em', qq{style="font-size: $option%; }
				. qq{font-style: normal;"}); }
    elsif ($tag eq 'font') {
      return AddHtmlEnvironment('span', qq{style="font-family: $option;"}); }
    else {
      return $bbcode;
    }
  } elsif (/\G(\[\/([a-z]+)\])/cgi) {
    my $bbcode = $1;
    my $tag = $2;
    %translate = qw{b b i i u em color em size em font span};
    if (defined $HtmlStack[0] && $HtmlStack[0] eq $translate{$tag}) {
      return CloseHtmlEnvironment(); }
    else {
      return $bbcode;
    }
  }
  return undef;
}
