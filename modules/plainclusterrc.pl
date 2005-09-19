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

# This module is designed to be used in conjunction with the ClusterMap Module
# and the Static Hybrid Module.  It alters the code that generates the 
# RecentChanges page so that links to a Cluster Page are direct links, not 
# action links.  This allows your RecentChanges page to be more useful and 
# use the pre-cached pages, rather than calling the Oddmuse script.

$ModulesDescription .= '<p>$Id: plainclusterrc.pl,v 1.1 2005/09/19 19:26:21 fletcherpenney Exp $</p>';


*GetRcHtml = *PlainGetRcHtml;

sub PlainGetRcHtml {
  my ($html, $inlist);
  # Optimize param fetches and translations out of main loop
  my $all = GetParam('all', 0);
  my $admin = UserIsAdmin();
  my $tEdit = T('(minor)');
  my $tDiff = T('diff');
  my $tHistory = T('history');
  my $tRollback = T('rollback');
  GetRc
    # printDailyTear
    sub {
      my $date = shift;
      if ($inlist) {
	$html .= '</ul>';
	$inlist = 0;
      }
      $html .= $q->p($q->strong($date));
      if (!$inlist) {
	$html .= '<ul>';
	$inlist = 1;
      }
    },
      # printRCLine
      sub {
	my($pagename, $timestamp, $host, $username, $summary, $minor, $revision, $languages, $cluster) = @_;
	$host = QuoteHtml($host);
	my $author = GetAuthorLink($host, $username);
	my $sum = $q->span({class=>'dash'}, ' &#8211; ') . $q->strong(QuoteHtml($summary)) if $summary;
	my $edit = $q->em($tEdit)  if $minor;
	my $lang = '[' . join(', ', @{$languages}) . ']'  if @{$languages};
	my ($pagelink, $history, $diff, $rollback);
	if ($all) {
	  $pagelink = GetOldPageLink('browse', $pagename, $revision, $pagename, $cluster);
	  if ($cluster) {
		$pagelink = GetPageLink($pagename,$cluster);
	  }
	  if ($admin and RollbackPossible($timestamp)) {
	    $rollback = '(' . ScriptLink('action=rollback;to=' . $timestamp,
					 $tRollback, 'rollback') . ')';
	  }
	} elsif ($cluster) {
	 # $pagelink = GetOldPageLink('browse', $pagename, $revision, $pagename, $cluster);
	 $pagelink = GetPageLink($pagename, $cluster);
	} else {
	  $pagelink = GetPageLink($pagename, $cluster);
	  $history = '(' . GetHistoryLink($pagename, $tHistory) . ')';
	}
	if ($cluster and $PageCluster) {
	  $diff .= GetPageLink($PageCluster) . ':';
	} elsif ($UseDiff and GetParam('diffrclink', 1)) {
	  if ($revision == 1) {
	    $diff .= '(' . $q->span({-class=>'new'}, T('new')) . ')';
	  } elsif ($all) {
	    $diff .= '(' . ScriptLinkDiff(2, $pagename, $tDiff, '', $revision) . ')';
	  } else {
	    $diff .= '(' . ScriptLinkDiff($minor ? 2 : 1, $pagename, $tDiff, '') . ')';
	  }
	}
	$html .= $q->li($q->span({-class=>'time'}, CalcTime($timestamp)), $diff, $history, $rollback,
			$pagelink, T(' . . . . '), $author, $sum, $lang, $edit);
      },
	@_;
  $html .= '</ul>' if ($inlist);
  return $html;
}
