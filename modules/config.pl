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

$ModulesDescription .= '<p>$Id: config.pl,v 1.2 2006/08/09 18:59:06 as Exp $</p>';

$Action{config} = \&DoConfig;
$Action{clone} = \&DoClone;

sub DoConfig {
  print GetHttpHeader('text/plain') . qq{# Wiki Config
# Source Wiki: $SiteName <$ScriptName>
# } . TimeToText($Now) . qq{
\$AdminPass = "";
\$EditPass = "";
};
  my $source = GetRaw('http://www.emacswiki.org/scripts/current');
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
    my $default = undef;
    my $re = quotemeta($var);
    if ($source =~ m!\n$re\s*=\s*(\d+(\s*[*+-/]\s*\d+)*|'[^']*'|"[^"]*"|\(.*?\)|qw\(.*?\))\s*;!) {
      $default = $1;
    }
    $type = substr($var, 0, 1);
    if ($type eq '$') {
      my $val = eval($var);
      print "$var = " . ConfigStr($val) . "; # default: $default\n"
	if $val ne eval($default);
    } elsif ($type eq '@') {
      my @list = eval($var);
      my @default = eval($default);
      print "$var = (", join(', ', map { ConfigStr($_) } @list)
	. "); # default: $default\n"
	unless ConfigListEqual(\@list, \@default);
    } elsif ($type eq '%') {
      my %hash = eval($var);
      my @default = eval($default);
      print "$var = (", join(', ', map { ConfigStr($_)
					   . ' => ' . ConfigStr($hash{$_})}
			     keys %hash) . "); # default: $default\n"
	unless ConfigHashEqual(\%hash, \%default);;
    }
  }
  print "# Done!\n";
}

sub ConfigStr {
  $_ = shift;
  if (m/^\d+$/) {
    $_;
  } elsif (m/'/) {
    "q{$_}";
  } else {
    "'$_'";
  }
}

sub ConfigListEqual {
  my ($a, $b) = @_;
  return 0 if @$a != @$b;
  for ($i = 0; $i < @$a; $i++) {
    return 0 unless @$a[$i] eq @$b[$i];
  }
  return 1;
}

sub ConfigHashEqual {
  my ($a, $b) = @_;
  return 0 unless ConfigListEqual([keys %$a], [keys %$b]);
  foreach my $key (keys %$a) {
    next if $$a{$key} eq $$b{$key};
    return 0;
  }
  return 1;
}
