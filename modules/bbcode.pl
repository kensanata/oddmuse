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

$ModulesDescription .= '<p>$Id: bbcode.pl,v 1.4 2007/01/31 08:35:27 as Exp $</p>';

push(@MyRules, \&bbCodeRule);

use vars qw($bbBlock);

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
    elsif ($tag eq 'url') {
      if ($option) {
	$option =~ /^($UrlProtocols)/o;
	my $class = "url $1";
	return AddHtmlEnvironment('a', qq{href="$option" class="$class"}); }
      elsif (/\G$FullUrlPattern\s*\[\/url\]/cogi) {
	return GetUrl($1); }}
    elsif ($tag eq 'img' and /\G$FullUrlPattern\s*\[\/img\]/cogi) {
      return GetUrl($1, undef, undef, 1); } # force image
    elsif ($tag eq 'quote') {
      my $html = CloseHtmlEnvironments();
      $html .= "</$bbBlock>" if $bbBlock;
      $html .= "<blockquote>";
      $bbBlock = 'blockquote';
      return $html . AddHtmlEnvironment('p'); }
    elsif ($tag eq 'code' and /\G((?:.*\n)*?.*?)\[\/code\]/cgi) {
      return CloseHtmlEnvironments() . $q->pre($1); }
    return $bbcode;
  } elsif (/\G(\[\/([a-z]+)\])/cgi) {
    my $bbcode = $1;
    my $tag = $2;
    %translate = qw{b b i i u em color em size em font span url a
		    quote blockquote};
    if (InElement($translate{$tag})) {
      return CloseHtmlEnvironmentUntil($translate{$tag}); }
    elsif ($bbBlock eq $translate{$tag}) {
      $bbBlock = undef;
      return CloseHtmlEnvironments() . "</$translate{$tag}>"; }
    else {
      return $bbcode;
    }
  } elsif (/\G(:-?[()])/cg) { # smiley fallback
    if (substr($1,-1) eq ')') {
      # '☺' 0009786 00263a WHITE SMILING FACE, So, 0, ON, N,
      return '&#x263a;';
    } else {
      # '☹' 0009785 002639 WHITE FROWNING FACE, So, 0, ON, N,
      return '&#x2639;';
    }
  } elsif (/\G:(?:smile|happy):/cg) {
    return '&#x263a;';
  } elsif (/\G:(?:sad|frown):/cg) {
    return '&#x2639;';
  }
  return undef;
}
