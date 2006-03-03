# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>strange-spam.pl 2</p>';

*StrangeOldBannedContent = *BannedContent;
*BannedContent = *StrangeNewBannedContent;

# copy scalar
$BannedContent = $StrangeOldBannedContent;

sub StrangeNewBannedContent {
  my $str = shift;
  my $rule = StrangeOldBannedContent($str, @_);
  $rule = StrangeOldBannedContent(GetParam('summary',''), @_)
    if not $rule and GetParam('summary','');
  return $rule if $rule;
  return "Hey, this looks like the useless spam on communitywiki.org!"
    if index($str, 'rel="itsok"') >= 0;
  return 0;
}
