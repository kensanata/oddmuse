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

$ModulesDescription .= '<p>$Id: clustermap.pl,v 1.16 2007/04/02 14:45:00 fletcherpenney Exp $</p>';

use vars qw($ClusterMapPage $ClusterMapTOC $FilterUnclusteredRegExp @ClusterMapAdminPages);

$ClusterMapPage = "Site_Map" unless defined $ClusterMapPage;

# Don't list the following pages as unclustered
# By default, journal pages and Comment pages
$FilterUnclusteredRegExp = '\d\d\d\d-\d\d-\d\d|\d* *Comments on .*'
	unless defined $FilterUnclusteredRegExp;

# The following pages are added to the AdminPage list and
# are not classified as unclustered.
# They are also added to the Important Pages list on the administration page
@ClusterMapAdminPages = ( $HomePage, $DeletedPage, $BannedContent,
	$BannedHosts, $InterMap, $NearMap, $RCName, $RssExclude)
	
	unless defined @ClusterMapAdminPages;
	
$ClusterMapTOC = 1 unless defined $ClusterMapTOC;
$PrintTOCAnchor = 0;

%ClusterMap = ();

*OldDoRc = *DoRc;
*DoRc = *ClusterMapDoRc;

push(@MyAdminCode, \&ClusterMapAdminRule);

$Action{clustermap} = \&DoClusterMap;

$Action{unclustered} = \&DoUnclustered;

push(@MyRules, \&ClusterMapRule);

foreach (@ClusterMapAdminPages){
	$AdminPages{$_} = 1;
}

sub ClusterMapRule {
	if (/\G^([\n\r]*\<\s*clustermap\s*\>\s*)$/mgc) {
		Dirty($1);
		my $oldpos = pos;
		$oldstr = $_;
		CreateClusterMap();
		print "</p>";		# Needed to clean up, but could cause problems
							# if <clustermap> isn't put into a new paragraph
		PrintClusterMap();
		pos = $oldpos;
		$oldstr =~ s/.*?\<\s*clustermap\s*\>//s;
		$_ = $oldstr;
		return '';
	}
	
	return undef;
}


sub DoClusterMap {
	# Get list of all clusters
	# For each cluster, get list of all pages in that cluster
	# Create map, using body of cluster pages, followed by titles of pages
	#	within that cluster
	
	print GetHeader('',$ClusterMapPage,'');

	CreateClusterMap();
	if ($ClusterMapTOC) {
		my $TOCCount = 0;
		print '<div class="toc"><h2>Categories</h2><ol>';
		foreach my $cluster ( sort keys %ClusterMap) {
			$cluster =~ s/_/ /g;
			print "<li><a href=\"#toc$TOCCount\">$cluster</a></li>";
			$TOCCount++;
		}
		print '</ol></div>';
		$PrintTOCAnchor = 1;
	}
	print '<div class="content">';	
	PrintClusterMap(); 
	
	print '</div>';
	PrintFooter();
}

sub DoUnclustered {
	
	print GetHeader('','Pages without a Cluster','');
	print '<div class="content">';
	
	CreateClusterMap();
	PrintUnclusteredMap();
	
	print '</div>';
	PrintFooter();
}

sub PrintClusterMap {
	my $TOCCount = 0;
	foreach my $cluster (sort keys %ClusterMap) {
	    local %Page;
	    local $OpenPageName='';
		my $free = $cluster;
		$free =~ s/_/ /g;

		OpenPage($cluster);
		
		if ( FreeToNormal(GetCluster($Page{text})) eq $cluster ) {
			# Don't display the page name twice if the cluster page is also
			# a member of the cluster
			$Page{text} =~ s/^\[*($cluster|$free)\]*\n*//s;
		}

		if ($PrintTOCAnchor) {
			print $q->h1("<a id=\"toc$TOCCount\"></a>" . GetPageOrEditLink($free, $free));
			$TOCCount++;

		} else {
			print $q->h1(GetPageOrEditLink($free, $free));
		}
		PrintWikiToHTML($Page{text}, 0);
		
		print "<ul>";
		foreach my $page (sort keys %{$ClusterMap{$cluster}}) {
			my $title = $page;
			$title =~ s/_/ /g;
			print "<li>" . ScriptLink($page, $title, 'local') . "</li>";
		}
		print "</ul>";
	}
}

sub CreateClusterMap {
	my @pages = AllPagesList();
	
	local %Page;
	local $OpenPageName='';
	
	foreach my $page ( @pages) {
		OpenPage($page);
		my $cluster = FreeToNormal(GetCluster($Page{text}));
		
		next if ($cluster eq $DeletedPage);		# Don't map Deleted Pages
		
		next if (TextIsFile($Page{text}));		# Don't map files
		
		if ($cluster eq "") {					# Grab Unclustered Pages
			$Unclustered{$page} = 1;
			next;
		}
		
		if ($cluster ne FreeToNormal($page)) {				# Create Cluster Map
			$ClusterMap{$cluster}{$page} = 1;
		}
	}
	
	# Strip out Admin Pages
	foreach my $page (@AdminPages) {
		delete($Unclustered{$page});
	}
}

sub ClusterMapDoRc {
	my ( @options ) = @_;
	my $page = "";
	my $cluster = GetParam(rcclusteronly);
	
	if ($cluster ne "") {
		CreateClusterMap();
		print "Pages in this cluster:";
		print "<ul>";
		foreach $page (sort keys %{$ClusterMap{$cluster}}) {
			my $title = $page;
			$title =~ s/_/ /g;
			print "<li>" . ScriptLink($page, $title, 'local') . "</li>";
		}
		print "</ul>";
	}
	
	OldDoRc(@options);
}

sub PrintUnclusteredMap {
		print "<ul>";
		foreach $page (sort keys %Unclustered) {
			my $title = $page;
			$title =~ s/_/ /g;
			if ($title !~ /^($FilterUnclusteredRegExp)$/) {
				print "<li>" . ScriptLink($page, $title, 'local') . "</li>";
			}
		}
		print "</ul>";

}

sub ClusterMapAdminRule {
	($id, $menuref, *restref) = @_;
	
	push(@$menuref, ScriptLink('action=clustermap', T('Clustermap'), 'clustermap'));
	push(@$menuref, ScriptLink('action=unclustered', T('Pages without a Cluster'), 'unclustered'));
}

*OldBrowseResolvedPage = *BrowseResolvedPage;
*BrowseResolvedPage = *ClusterMapBrowseResolvedPage;

sub ClusterMapBrowseResolvedPage {
	my $title = shift;
	$title =~ s/_/ /g;
	my $id = FreeToNormal($title);
	if ($id eq $ClusterMapPage) {
		CreateClusterMap();
		print GetHeader('',$title,'');
		print '<div class="content">';	
		if ($ClusterMapTOC) {
			my $TOCCount = 0;
			print '<div class="toc"><h2>Categories</h2><ol>';
			foreach my $cluster ( sort keys %ClusterMap) {
				$cluster =~ s/_/ /g;
				print "<li><a href=\"#toc$TOCCount\">$cluster</a></li>";
				$TOCCount++;
			}
			print '</ol></div>';
			$PrintTOCAnchor = 1;
		}
		PrintClusterMap();
		print '</div>';	
		PrintFooter();
	} else {
		OldBrowseResolvedPage($id);
	}
}

*OldPrintWikiToHTML = *PrintWikiToHTML;
*PrintWikiToHTML = *ClusterMapPrintWikiToHTML;

sub ClusterMapPrintWikiToHTML {
	my ($pageText, $savecache, $revision, $islocked) = @_;

	# Cause an empty page with the name $ClusterMapPage to
	# display a map.
	if (($ClusterMapPage eq $OpenPageName)
		&& ($pageText =~ /^\s*$/s)){
		SetParam('rcclusteronly',0);
		CreateClusterMap();
		print '<div class="content">';	
		if ($ClusterMapTOC) {
			my $TOCCount = 0;
			print '<div class="toc"><h2>Contents</h2><ol>';
			foreach my $cluster ( sort keys %ClusterMap) {
				print "<li><a href=\"#toc$TOCCount\">$cluster</a></li>";
				$TOCCount++;
			}
			print '</ol></div>';
			$PrintTOCAnchor = 1;
		}
		PrintClusterMap();
		print '</div>';	
	}
	OldPrintWikiToHTML(@_);
}
