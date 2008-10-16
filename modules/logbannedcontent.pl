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

$ModulesDescription .= '<p>$Id: logbannedcontent.pl,v 1.6 2008/10/16 04:53:17 as Exp $</p>';

use vars qw($BannedFile);

$BannedFile = "$DataDir/spammer.log" unless defined $BannedFile;

*OldBannedContent = *BannedContent;
*BannedContent = *LogBannedContent;
$BannedContent = $OldBannedContent; # copy variable

sub LogBannedContent {
  my $str = shift;
  my $rule = OldBannedContent($str);
  if ($rule) {
    my $visitor = $ENV{'REMOTE_ADDR'};
    ($sec, $min, $hr, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    $year=$year+1900;
    $mon += 1;
    # Fix for 0's
    $mon = sprintf("%02d", $mon);
    $mday = sprintf("%02d", $mday);
    $sec = sprintf("%02d", $sec);
    $min = sprintf("%02d", $min);
    $hr = sprintf("%02d", $hr);
    AppendStringToFile($BannedFile, "$year/$mon/$mday\t$hr:$min:$sec\t$visitor: $OpenPageName - $rule\n");
  }
  return $rule;
}
