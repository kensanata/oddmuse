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

$ModulesDescription .= '<p>$Id: irc.pl,v 1.1 2004/11/24 22:09:02 as Exp $</p>';

use vars qw($IrcRegexp $IrcLinkNick);

push(@MyRules, \&IrcRule);

$IrcRegexp = qr{[]a-zA-Z^[;\\`_{}|][]^[;\\`_{}|a-zA-Z0-9-]*};
$ircLinkNick = 0;

sub IrcRule {
  if ($bol && m/\G&lt;($IrcRegexp)&gt;/gc) {
    my $str = $1;
    my $error = ValidId($str);
    if ($error or not $IrcLinkNick) {
      return $q->br() . '<' . $q->b($str) . '>';
    } else {
      return $q->br() . '<' . GetPageOrEditLink($str) . '>';
    }
  }
  return undef;
}
