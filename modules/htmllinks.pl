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

AddModuleDescription('htmllinks.pl', 'HtmlLinks Module');

our ($OpenPageName, %RuleOrder, @MyRules);
our ($HtmlLinks);

$HtmlLinks = 0;		# Mask all email, not just those in []'s

push(@MyRules, \&HtmlLinksRule);

$RuleOrder{\&HtmlLinksRule} = 105;

sub HtmlLinksRule {
	if (IsFile(GetLockedPageFile($OpenPageName))) {
		$HtmlLinks = 1;
	} else {
		$HtmlLinks = 0;
	}
	return;
}
