# Copyright (C) 2008  Alex Schroeder <alex@gu.org>
# Copyright (C) 2004, 2005  Fletcher T. Penney <fletcher@freeshell.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

AddModuleDescription('logbannedcontent.pl', 'LogBannedContent Module');

use vars qw($BannedFile);

$BannedFile = "$DataDir/spammer.log" unless defined $BannedFile;

*LogOldBannedContent = *BannedContent;
*BannedContent = *LogNewBannedContent;
$BannedContent = $LogOldBannedContent; # copy variable

sub LogNewBannedContent {
  my $str = shift;
  my $rule = LogOldBannedContent($str);
  LogWrite($rule) if $rule;
  return $rule;
}

*LogOldUserIsBanned = *UserIsBanned;
*UserIsBanned = *LogNewUserIsBanned;

sub LogNewUserIsBanned {
  my $str = shift;
  my $rule = LogOldUserIsBanned($str);
  LogWrite(Ts('Host or IP matched %s', $rule)) if $rule;
  return $rule;
}

sub LogWrite {
  my $rule = shift;
  my $id = $OpenPageName || GetId();
  AppendStringToFile($BannedFile,
		     join("\t", TimeToW3($Now), GetRemoteHost(), $id, $rule)
		     . "\n");
}
