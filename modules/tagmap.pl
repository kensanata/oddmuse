# Copyright (C) 2005  Fletcher T. Penney <fletcher@freeshell.org>
# Copyright (c) 2007  Alexander Uvizhev <uvizhe@yandex.ru>
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

$ModulesDescription .= '<p>$Id: tagmap.pl,v 1.4 2007/08/24 07:12:32 uvizhe Exp $</p>';

use vars qw($TagMapPage $TagMark $TagClass $TagString $TagSearchTitle);

$TagMapPage = "TagMap" unless defined $TagMapPage;

# Page tags are identified by this mark (input mark)
$TagMark = "Tags:" unless defined $TagMark;

# Page tags enclosed in DIV block of this class
$TagClass = "tags" unless defined $TagClass;

# This string precedes tags on page (output mark)
$TagString = "Tags: " unless defined $TagString;

$Action{tagmap} = \&DoTagMap;

$Action{tagsearch} = \&DoTagSearch;

$TagSearchTitle = "Pages with tag %s";

push (@MyRules, \&TagRule);

my %TagList = ();
my $TagXML;

sub TagRule { # Process page tags on a page

    if ( m/\G$TagMark\s*(.*)/gc) {  # find page tags
        my @tags = split /,\s*/, $1;  # push them in array
        @tags = map {                 # and generate html output:
            qq{<a href="$ScriptName?action=tagsearch;tag=$_">$_</a>};  # each tag is a link to search all pages with that tag
        } @tags;
        my $tags = join ', ', @tags;
        return qq{<div class="$TagClass">$TagString$tags</div>}; # tags are put in DIV block
    }
    return undef;

}

sub DoTagSearch {

    my $searchedtag = GetParam('tag');  # get tag parameter
    my $header = Ts($TagSearchTitle, $searchedtag);  # modify page title with requested tag
    print GetHeader('',$header,'');  # print title

    print '<div class="content">';
    
    my $SearchResult = GenerateSearchResult($searchedtag);
    
    print $SearchResult;
    print '</div>';
    PrintFooter();

}

sub GenerateSearchResult {
    
    my $searchedtag = shift @_;
    
    my @pages = AllPagesList();
    
    local %Page;
    local $OpenPageName='';
    
    my $SearchResult .= "<ul>";

    foreach my $page (@pages) {
        OpenPage($page);                    # open a page
        my @tags = GetTags($Page{text});    # collect tags in an array
            foreach (@tags) {
                if (/^$searchedtag$/) {
                    my $name = NormalToFree($page);
                    $SearchResult .= "<li><a href=\"$ScriptName/$page\">$name</a></li>";  # list of pages
            }
        }
    }
    $SearchResult .= "</ul>";

    return $SearchResult;

}

sub DoTagMap {
	
	print GetHeader('',$TagMapPage,'');
	
	CreateTagMap();
	
	print '<div class="content">';

	PrintTagMap();
	
	print '</div>';
	
	PrintFooter();
}


sub CreateTagMap {
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

sub PrintTagMap {
	do "$ModuleDir/TagCategorizer/TagCategorizer.pl";

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

sub GetTags {
	my $text = shift;
	my @tags;

	# strip [[.*?]] bits, then split on spaces

	if ($text =~ /^$TagMark\s*(.*)$/m) {
		my $tagstring = $1;
		@tags = split /,\s*/, $tagstring;
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
