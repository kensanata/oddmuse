# Copyright (C) 2004, 2005  Fletcher T. Penney <fletcher@freeshell.org>
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

$ModulesDescription .= '<p>$Id: logbannedcontent.pl,v 1.3 2005/04/10 16:57:22 fletcherpenney Exp $</p>';

use vars qw($BannedFile); 

$BannedFile = "$DataDir/spammer.log" unless defined $BannedFile;

*OldBannedContent = *BannedContent;
*BannedContent = *LogBannedContent;

sub LogBannedContent {
	my $str = shift;
	*BannedContent = *OldBannedContent;
	my $rule = BannedContent($str);
	if ($rule) {
		my $visitor = $ENV{'REMOTE_ADDR'};

		# Create timestamp
		($sec, $min, $hr, $mday, $mon, $year, $wday, $yday, $isdst) =localtime(time);
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