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

$ModulesDescription .= '<p>$Id: setext.pl,v 1.3 2004/06/27 23:47:02 as Exp $</p>';

push(@MyRules, \&SeTextRule);

my $word = '([-A-Za-z\x80-\xff]+)';
sub SeTextRule {
  my $oldpos = pos;
  if ($bol && ((m/\G((.+?)[ \t]*\n(-+|=+)[ \t]*\n)/gc
		and (length($2) == length($3)))
	       or ((pos = $oldpos) and 0))) {
    if (substr($3,0,1) eq '=') {
      return CloseHtmlEnvironments() . "<h2>$2</h2>";
    } else {
      return CloseHtmlEnvironments() . "<h3>$2</h3>";
    }
  } elsif ($bol && m/\G((&gt; .*\n)+)/gc) {
    return "<pre>$1</pre>";
  } elsif (m/\G\*\*($word( $word)*)\*\*/goc) {
    return "<b>$1</b>";
  } elsif (m/\G~$word~/goc) {
    return "<i>$1</i>";
  } elsif (m/\G\b_($word(_$word)*)_\b/goc) {
    return "<u>" . join(' ', split(/_/, $1)) . "</u>"; # don't clobber pos
  } elsif (m/\G`_(.+)_`/gc) {
    return $1;
  }
  return undef;
}
