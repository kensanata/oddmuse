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

$ModulesDescription .= '<p>$Id: headers.pl,v 1.8 2004/11/27 21:20:02 as Exp $</p>';

push(@MyRules, \&HeadersRule);

# The trickiest part is the first rule.  It finds titles like the following:
#
# foo
# ---
#
# This assumes that --- is not found at the beginning of a line.
# Normally this is used as an M-dash in the middle of text with no
# surrounding whitespace---like this.
#
# Similarly, the horizontal rule requires an empty preceding line to
# work.  We'll see how it goes.  ;)

sub HeadersRule {
  my $oldpos = pos;
  if ($bol && (m/\G((.+?)[ \t]*\n(---+|===+)[ \t]*\n)/gc)) {
    my $html;
    if (substr($3,0,1) eq '=') {
      CloseHtmlEnvironments() . ($PortraitSupportColorDiv ? '</div>' : '') . "<h2>$2</h2>";
    } else {
      CloseHtmlEnvironments() . ($PortraitSupportColorDiv ? '</div>' : '') . "<h3>$2</h3>";
    }
    $PortraitSupportColorDiv = 0;
    return $html;
  } elsif ($bol && m/\G(\s*\n)*----+[ \t]*\n?/cg) {
    return CloseHtmlEnvironments() . $q->hr();
  }
  return undef;
}
