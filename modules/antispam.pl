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

$ModulesDescription .= '<p>$Id: antispam.pl,v 1.2 2005/04/08 21:23:43 fletcherpenney Exp $</p>';

use vars qw($DoMaskEmail $CreateMailtoLinks); 

$DoMaskEmail = 1;		# Mask all email, not just those in []'s
$CreateMailtoLinks = 1;		# Create mailto's for all addresses

$EmailRegExp = '[\w\.\-]+@([\w\-]+\.)+[\w]+';


push(@MyRules, \&MaskEmailRule);
    
sub MaskEmailRule {
	# Allow [email@foo.bar Email Me] links
	if (m/\G\[($EmailRegExp(\s\w+)*\s*)\]/igc) {
		$chunk = $1;
		$chunk =~ s/($EmailRegExp)//i;
		$email = $1;
		$chunk =~ s/^\s*//;
		$chunk =~ s/\s*$//;
		
		$masked="";
		@decimal = unpack('C*', $email);
		foreach $i (@decimal) {
			$masked.="&#".$i.";";
		}
		$email = $masked;
		$chunk = $email if $chunk eq "";
		return "<a href=\"mailto:" . $email . "\">$chunk</a>";
	}
	
	if (m/\G($EmailRegExp)/igc) {
		$email=$1;
		if ($DoMaskEmail) {
			$masked="";
			@decimal = unpack('C*', $email);
			foreach $i (@decimal) {
				$masked.="&#".$i.";";
			}
			$email = $masked;
		}
		if ($CreateMailtoLinks) {
			$email = "<a href=\"mailto:" . $email . "\">$email</a>";
		}
		return $email;
	}
	return undef;
}
