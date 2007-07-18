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

$ModulesDescription .= '<p>$Id: blockquote.pl,v 1.1 2007/07/18 08:09:29 as Exp $</p>';

push(@MyRules, \&BlockQuoteRule);

sub BlockQuoteRule {
  # indented text using : with the option of spanning multiple text
  # paragraphs (but not lists etc).
  if (InElement('blockquote') && m/\G(\s*\n)+:[ \t]*/cog) {
    return CloseHtmlEnvironmentUntil('blockquote')
      . AddHtmlEnvironment('p');
  } elsif ($bol && m/\G(\s*\n)*:[ \t]*/cog) {
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment('blockquote')
      . AddHtmlEnvironment('p');
  }
  return undef;
}
