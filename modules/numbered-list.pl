# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: numbered-list.pl,v 1.2 2008/01/03 01:01:00 as Exp $</p>';

push(@MyRules, \&NumberedListRule);

sub NumberedListRule {
  # numbered lists using # copied from usemod.pl but allow leading
  # whitespace
  if ($bol && m/\G(\s*\n)*\s*(\#+)[ \t]/cog
      or InElement('li') && m/\G(\s*\n)+\s*(\#+)[ \t]/cog) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ol',length($2))
      . AddHtmlEnvironment('li');
  }
  return undef;
}
