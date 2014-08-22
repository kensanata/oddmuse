# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.
#
# This file must load before logbannedcontent.pl such that quick
# editors will be logged.

AddModuleDescription('ban-quick-editors.pl', 'Banning Quick Editors');

*BanQuickOldUserIsBanned = *UserIsBanned;
*UserIsBanned = *BanQuickNewUserIsBanned;

sub BanQuickNewUserIsBanned {
  my $rule = BanQuickOldUserIsBanned(@_);
  if (not $rule
      and $SurgeProtection # need surge protection
      and GetParam('title')) {
    my $name = GetParam('username', GetRemoteHost());
    my @entries = @{$RecentVisitors{$name}};
    # $entry[0] is $Now after AddRecentVisitor
    my $ts = $entries[1];
    if ($Now - $ts < 5) {
      return "fast editing spam bot";
    }
  }
  return $rule;
}
