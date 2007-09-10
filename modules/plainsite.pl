# Copyright (C) 2005-2007  Fletcher T. Penney <fletcher@freeshell.org>
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

$ModulesDescription .= '<p>$Id: plainsite.pl,v 1.2 2007/09/10 04:15:23 fletcherpenney Exp $</p>';

use vars qw($PlainSiteAllowCommentLink);

*OldGetFooterLinks = *GetFooterLinks;
*GetFooterLinks = *PlainSiteGetFooterLinks;

sub PlainSiteGetFooterLinks {
	return if (GetParam('action','') eq 'static');
	if (UserIsAdmin() or UserIsEditor()) {
		return OldGetFooterLinks(@_);
	} else {
		if ($PlainSiteAllowCommentLink) {
			return CommentFooterLink(@_);
		} else {
			return;
		}
	}
}

sub CommentFooterLink {
  my ($id, $rev) = @_;
  my @elements;
  if ($id and $rev ne 'history' and $rev ne 'edit') {
    if ($CommentsPrefix) {
      if ($OpenPageName =~ /^$CommentsPrefix(.*)/o) {
	push(@elements, GetPageLink($1, undef, 'original'));
      } else {
	push(@elements, GetPageLink($CommentsPrefix . $OpenPageName, undef, 'comment'));
      }
    }
  }
  return @elements ? $q->span({-class=>'edit bar'}, $q->br(), @elements) : '';
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

*GetNearLinksUsed = *PlainSiteGetNearLinksUsed;

sub PlainSiteGetNearLinksUsed {
	return;
}


# Disable the Recent Change function on cluster pages
# Must load before clustermap module if that module is used


*OldPrintRc = *PrintRc;
*PrintRc = *PlainSitePrintRc;

sub PlainSitePrintRc{
	my ($id, $standalone) = @_;
	if (!(UserIsAdmin() or UserIsEditor())) {
		DoRc(\&PlainSiteRcHtml);
	} else {
		return OldPrintRc($id, $standalone);
	}
}

sub PlainSiteRcHtml {
	my ($html, $inlist) = ('', 0);
	if (!(UserIsAdmin() or UserIsEditor())) {
		return;
	} else {
		*GetRcHtml = *OldGetRcHtml;
		return OldGetRcHtml();
	}
}
