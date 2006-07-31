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

$ModulesDescription .= '<p>$Id: irc.pl,v 1.7 2006/07/31 20:24:59 as Exp $</p>';

use vars qw($IrcNickRegexp $IrcLinkNick);

push(@MyRules, \&IrcRule);
$RuleOrder{\&IrcRule} = 200; # after HTML tags in Usemod Markup Extension.

$IrcNickRegexp = qr{[]a-zA-Z^[;\\`_{}|][]^[;\\`_{}|a-zA-Z0-9-]*};
$IrcLinkNick = 0;

# This adds an extra <br> at the beginning.  Alternatively, add it to
# the last line, or only add it when required.
sub IrcRule {
  if ($bol && m/\G(?:\[?(\d\d?:\d\d(?:am|pm)?)\]?)?\s*&lt;($IrcNickRegexp)&gt; ?/gc) {
    my ($time, $nick) = ($1, $2);
    my ($error) = ValidId($nick);
    # if we're in a dl, close the open dd but not the dl.  (if we're
    # not in a dl, that closes all environments.)  then open a dl
    # unless we're already in a dl.  put the nick in a dt.
    my $html = CloseHtmlEnvironmentUntil('dd') . OpenHtmlEnvironment('dl', 1, 'irc')
      . AddHtmlEnvironment('dt');
    $html .= $q->span({-class=>'time'}, $time, ' ') if $time;
    if ($error or not $IrcLinkNick) {
      $html .= $q->b($nick);
    } else {
      $html .= GetPageOrEditLink($nick);
    }
    $html .= CloseHtmlEnvironment('dt') . AddHtmlEnvironment('dd');
    return $html;
  }
  return undef;
}
