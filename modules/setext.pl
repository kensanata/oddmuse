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

$ModulesDescription .= '<p>$Id: setext.pl,v 1.7 2004/11/27 21:32:43 as Exp $</p>';

push(@MyRules, \&SeTextRule);

# The trickiest part is the first rule.  It finds titles like the following:
#
# foo
# ===
#
# It ignores the amount of whitespace after the title and the
# underlining, and it allows underlining using ==== or ----.  The
# underlining has to be exactly as wide as the title itself.  If it is
# too long or too short, the entire thing is not a title.
#
# If the length does not match, pos is reset and zero is returned so
# that the remaining rules will be tested instead.

my $word = '([-A-Za-z\x80-\xff]+)';
sub SeTextRule {
  my $oldpos = pos;
  if ($bol && ((m/\G((.+?)[ \t]*\n(-+|=+)[ \t]*\n)/gc
		and (length($2) == length($3)))
	       or ((pos = $oldpos) and 0))) {
    my $html = CloseHtmlEnvironments() . ($PortraitSupportColorDiv ? '</div>' : '');
    if (substr($3,0,1) eq '=') {
      $html .= $q->h2($2);
    } else {
      $html .= $q->h2($3);
    }
    $PortraitSupportColorDiv = 0;
    return $html;
  } elsif ($bol && m/\G((&gt; .*\n)+)/gc) {
    return "<pre>$1</pre>";
  } elsif (m/\G\*\*($word( $word)*)\*\*/goc) {
    return "<b>$1</b>";
  } elsif (m/\G~$word~/goc) {
    return "<i>$1</i>";
  } elsif (m/\G\b_($word(_$word)*)_\b/goc) {
    return '<em style="text-decoration: underline; font-style: normal;">'
      . join(' ', split(/_/, $1)) . "</em>"; # don't clobber pos
  } elsif (m/\G`_(.+)_`/gc) {
    return $1;
  }
  return undef;
}
