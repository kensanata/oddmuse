# Copyright (C) 2005  Fletcher T. Penney <fletcher@freeshell.org>
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

$ModulesDescription .= '<p>$Id: plainsite.pl,v 1.1 2005/11/11 02:15:32 fletcherpenney Exp $</p>';

*OldGetFooterLinks = *GetFooterLinks;
*GetFooterLinks = *PlainSiteGetFooterLinks;

sub PlainSiteGetFooterLinks {
	return if (GetParam('action','') eq 'static');
	if (UserIsAdmin() or UserIsEditor()) {
		return OldGetFooterLinks(@_);
	} else {
		return;
	}
}

*OldGetFooterTimestamp = *GetFooterTimestamp;
*GetFooterTimestamp = *PlainSiteGetFooterTimestamp;

sub PlainSiteGetFooterTimestamp {
	return if (GetParam('action','') eq 'static');
	if (UserIsAdmin() or UserIsEditor()) {
		return OldGetFooterTimestamp(@_);
	} else {
		return;
	}
}

*OldGetRcRss = *GetRcRss;
*GetRcRss = *PlainSiteGetRcRss;

sub PlainSiteGetRcRss {
	# Have Rss point to HomePage rather than RecentChanges, since we want
	# to avoid drawing visitors to RecentChanges
	$RCName = $HomePage;
	OldGetRcRss(@_);
}

*DoRc = *PlainSiteDoRc;

sub PlainSiteDoRc {
	# must load before clustermap module if used
	return;
}

*GetNearLinksUsed = *PlainSiteGetNearLinksUsed;

sub PlainSiteGetNearLinksUsed {
	return;
}