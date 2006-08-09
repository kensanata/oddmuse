# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: config.pl,v 1.1 2006/08/09 16:19:10 as Exp $</p>';

$Action{config} = \&DoConfig;
$Action{clone} = \&DoClone;

sub DoConfig {
  print GetHttpHeader('text/plain') . qq{# Wiki Config
# Source Wiki: $SiteName
# } . TimeToText($Now) . qq{
\$AdminPass = "";
\$EditPass = "";
};
  print "# $ARGV[0]\n";
  foreach my $var qw($HomePage $MaxPost $HttpCharset $StyleSheet
		     $StyleSheetPage $NotFoundPg $NewText $NewComment
		     $EditAllowed $BannedHosts $BannedCanRead
		     $BannedContent $WikiLinks $FreeLinks $BracketText
		     $BracketWiki $NetworkFile $AllNetworkFiles
		     $PermanentAnchors $InterMap $NearMap
		     $RssInterwikiTranslate $SurgeProtection
		     $SurgeProtectionTime $SurgeProtectionViews
		     $DeletedPage $RCName @RcDays $RcDefault $KeepDays
		     $KeepMajor $SummaryHours $SummaryDefaultLength
		     $ShowEdits $UseLookup $RecentTop $RecentLink
		     $PageCluster $InterWikiMoniker $SiteDescription
		     $RssImageUrl $RssRights $RssExclude
		     $RssCacheHours $RssStyleSheet $UploadAllowed
		     @UploadTypes $EmbedWiki $FooterNote $EditNote
		     $TopLinkBar @UserGotoBarPages $UserGotoBar
		     $ValidatorLink $CommentsPrefix $HtmlHeaders
		     $IndentLimit $LanguageLimit $JournalLimit
		     $SisterSiteLogoUrl %SpecialDays %Smilies
		     %Languages) {
    print "$var = q{" . eval($var) . "};\n";
  }
}
