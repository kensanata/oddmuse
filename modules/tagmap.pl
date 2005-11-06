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

$ModulesDescription .= '<p>$Id: tagmap.pl,v 1.1 2005/11/06 03:34:41 fletcherpenney Exp $</p>';

use vars qw($TagMapPage $TagString);

$TagMapPage = "TagMap" unless defined $TagMapPage;

$TagString = "Tags" unless defined $TagString;

$Action{tagmap} = \&DoTagMap;

my %TagList = ();
my $TagXML;


sub DoTagMap {
	
	print GetHeader('',$TagMapPage,'');
	
	CreateTagMap();
	
	print '<div class="content">';
	PrintTagMap();
	
	print '</div>';
	
	PrintFooter();
}


sub CreateTagMap{
	my @pages = AllPagesList();
	
	local %Page;
	local $OpenPageName='';
	$TagXML .= "<taglist>\n";
	
	foreach my $page (@pages) {
		OpenPage($page);
		my @tags = GetTags($Page{text});
		$page = FreeToNormal($page);
		
		my $count = @tags;
		if ($count != 0) {
			$TagXML .= "<object><id>$page</id>\n";
					
			foreach (@tags) {
				$TagXML .= "<tag>$_</tag>";
				$TagList{$_} = 1;
			}
			$TagXML .= "\n</object>\n";
		}
	}
	
	$TagXML .= "</taglist>\n";
	
}

sub PrintTagMap{
	require "$ModuleDir/TagCategorizer/TagCategorizer.pl";

	my $result = TagCategorizer::ProcessXML($TagXML);
	
	$result =~ s/\<tagHierarchy\>/<ul>/;
	$result =~ s/\<\/tagHierarchy\>/<\/ul>/;
	
	$result =~ s{
		<tag[ ]title="(.*?)">
	}{
		my $tag = $1;
		
		"<li>$tag</li>\n<ul>";
	}xsge;
	
	$result =~ s/\<\/tag\>/<\/ul>/g;
	$result =~ s{
		<object>(.*?)</object>
	}{
		my $id = $1;
		my $name = $id;
		$name =~ s/_/ /g;
		"<li><a href=\"$ScriptName\/$id\">$name</a></li>";
	}xsge;
	print $result;		
}

sub GetTags{
	my $text = shift;
	my @tags;
	
	# strip [[.*?]] bits, then split on spaces

	if ($text =~ /^$TagString:(.*)$/m) {
		my $tagstring = $1;
		while ($tagstring =~ s/\[\[(.*?)\]\]//) {
			push (@tags, $1) if ($1 !~ /^\s*$/);
		}
		foreach (split (/ +/, $tagstring)) {
			push (@tags, $_) if ($_ !~ /^\s*$/);
		}
	} else {
		return;
	}
	return @tags;
}

*TagMapOldBrowseResolvedPage = *BrowseResolvedPage;
*BrowseResolvedPage = *TagMapBrowseResolvedPage;

sub TagMapBrowseResolvedPage {
	my $title = shift;
	$title =~ s/_/ /g;
	my $id = FreeToNormal($title);
	if ($id eq $TagMapPage) {
		DoTagMap();
	} else {
		TagMapOldBrowseResolvedPage($id);
	}
}

*TagMapOldPrintWikiToHTML = *PrintWikiToHTML;
*PrintWikiToHTML = *TagMapPrintWikiToHTML;

sub TagMapPrintWikiToHTML {
	my ($pageText, $savecache, $revision, $islocked) = @_;

	# Cause an empty page with the name $ClusterMapPage to
	# display a map.
	if (($TagMapPage eq $OpenPageName)
		&& ($pageText =~ /^\s*$/s)){
		CreateTagMap();
		PrintTagMap();
	}
	TagMapOldPrintWikiToHTML(@_);
}
