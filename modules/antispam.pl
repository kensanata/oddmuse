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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('antispam.pl', 'Antispam Module');

our (@MyRules);
our ($DoMaskEmail, $CreateMailtoLinks, $EmailRegExp);

$DoMaskEmail = 1;		# Mask all email, not just those in []'s
$CreateMailtoLinks = 1;		# Create mailto's for all addresses

$EmailRegExp = '[\w\.\-]+@([\w\-]+\.)+[\w]+';


push(@MyRules, \&MaskEmailRule);

sub MaskEmailRule {
	# Allow [email@foo.bar Email Me] links
	if (m/\G\[($EmailRegExp(\s\w+)*\s*)\]/cgi) {
		my $chunk = $1;
		$chunk =~ s/($EmailRegExp)//i;
		my $email = $1;
		$chunk =~ s/^\s*//;
		$chunk =~ s/\s*$//;

		my $masked = '';
		my @decimal = unpack('C*', $email);
		for (@decimal) {
			$masked .= '&#' . $_ . ';';
		}
		$email = $masked;
		$chunk = $email if $chunk eq "";
		return "<a href=\"mailto:$email\">$chunk</a>";
	}

	if (m/\G($EmailRegExp)/cgi) {
		my $email = $1;
		if ($DoMaskEmail) {
			my $masked="";
			my @decimal = unpack('C*', $email);
			for (@decimal) {
				$masked .= '&#' . $_ . ';';
			}
			$email = $masked;
		}
		if ($CreateMailtoLinks) {
			$email = "<a href=\"mailto:" . $email . "\">$email</a>";
		}
		return $email;
	}
	return;
}
