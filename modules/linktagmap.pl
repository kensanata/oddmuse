# Copyright (C) 2007 Alexander Uvizhev <uvizhe@yandex.ru>
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
#
# Based on code of tagmap.pl module by Fletcher T. Penney
# and searchtags.pl module by Brock Wilcox
$ModulesDescription .= '<p>$Id: linktagmap.pl,v 1.7 2008/03/27 13:18:05 uvizhe Exp $</p>';

use vars qw($LinkTagMark $LinkDescMark $LinkTagClass $LinkDescClass $LinkTagMapPage $UrlPattern $FullUrlPattern $LinkTagSearchTitle);

# Tags and descripton are embraced with this sequences
$LinkTagMark = '%T%' unless defined $LinkTagMark;
$LinkDescMark = '%D%' unless defined $LinkDescMark;

# In output html these will be values for property "class" of SPAN tag
$LinkTagClass = "lntag" unless defined $LinkTagClass;
$LinkDescClass = "lndesc" unless defined $LinkDescClass;

# Wiki page, where links will be present in a structured way
$LinkTagMapPage = "LinkTagMap" unless defined $LinkTagMapPage;

# The same output with wiki.pl?action=linktagmap
$Action{linktagmap} = \&DoLinkTagMap;

# Action to search and show all links with specified tag
$Action{linktagsearch} = \&DoLinkTagSearch;

# Header of a search result
$LinkTagSearchTitle = "Links with tag %s";

my $rstr = crypt($$,$$);

push (@MyRules, \&LinkTagRule, \&LinkDescriptionRule);

sub LinkTagRule { # Process link tags on a page

    if ( m/\G$LinkTagMark(.*?)$LinkTagMark/gc) {      # find tags
        my @linktags = split /,\s*/, $1;              # push them in array
        @linktags = map {                             # and generate html output:
            qq{<a href="$ScriptName?action=linktagsearch;linktag=$_">$_</a>};  # each tag is a link to search all links with that tag
        } @linktags;
        my $linktags = join ', ', @linktags;
        return qq{<span class="$LinkTagClass">$linktags</span>}; # tags are put in SPAN block
    }
    return undef;

}

sub LinkDescriptionRule { # Process link descriptions on a page

    if ( m/\G$LinkDescMark(.*?)$LinkDescMark/gc) {          # find description
        return qq{<span class="$LinkDescClass">$1</span>};  # put it in SPAN block
    }
    return undef;

}

sub DoLinkTagMap {

    print GetHeader('',$LinkTagMapPage,'');

    my $TagXML = GenerateLinkTagMap();

    print '<div class="content">';

    PrintLinkTagMap($TagXML);

    print '</div>';

    PrintFooter();

}

sub DoLinkTagSearch {
    
    my $searchedtag = GetParam('linktag');  # get tag parameter
    my $header = Ts($LinkTagSearchTitle, $searchedtag);  # modify page title with requested tag
    print GetHeader('',$header,'');  # print title

    print '<div class="content">';

    my $SearchResult = GenerateLinkSearchResult($searchedtag);
    
    print $SearchResult;
    print '</div>';
    PrintFooter();

}

sub GenerateLinkSearchResult {

    my $searchedtag = shift @_;

    my @pages = AllPagesList();

    local %Page;
    local $OpenPageName='';

    my $SearchResult .= "<ul>";

    foreach my $page (@pages) {
        OpenPage($page);                    # open a page
        my @links = GetLinks($Page{text});  # find links
        foreach my $link (@links) {
            my @tags = GetLinkTags($link->{tags});  # collect tags in an array
            foreach (@tags) {
                if (/^$searchedtag$/) {
                    my @linktags = split /,\s*/, $link->{tags};   # push tags in an array
                    @linktags = map {                             # and print html output:
                        qq{<a href="$ScriptName?action=linktagsearch;linktag=$_">$_</a>};  # each tag is a link to search all links with that tag
                    } @linktags;
                    my $linktags = join ', ', @linktags;
                    if ( length $link->{name} == 0 ) { $link->{name} = $link->{url}; }  # if link has no name we use url instead
                    $SearchResult .= "<li><a href=\"$link->{url}\">$link->{name}</a><span class=\"$LinkTagClass\">$linktags</span><span class=\"$LinkDescClass\">$link->{description}</span></li>";
                }
            }
        }
    }
    $SearchResult .= "</ul>";

    return $SearchResult;

}

sub GenerateLinkTagMap { # Generate an input XML for TagCategorizer

    my @pages = AllPagesList();

    local %Page;
    local $OpenPageName='';

    my $TagXML .= "<taglist>\n";

    foreach my $page (@pages) {
        OpenPage($page);                    # open a page
        my @links = GetLinks($Page{text});  # find links
       	foreach my $link (@links) {
            my @tags = GetLinkTags($link->{tags});  # collect tags in an array
            $TagXML .= "<object><id>$link->{url}\|$rstr\|$link->{name}\|$rstr\|$link->{description}</id>\n";  # put everything in 'id' block
            foreach (@tags) {                                                                                 # except of tags
                $TagXML .= "<tag>$_</tag>";                                                                   # which are in 'tag' blocks
            }
            $TagXML .= "\n</object>\n";
        }
    }
    $TagXML .= "</taglist>\n";

    return $TagXML;

}

sub PrintLinkTagMap {

    my $TagXML = shift @_;

    do "$ModuleDir/TagCategorizer/TagCategorizer.pl";

    my $result = TagCategorizer::ProcessXML($TagXML);  # get an output XML from TagCategorizer

    $result =~ s/\<tagHierarchy\>/<ul>/;               # and convert it to html
    $result =~ s/\<\/tagHierarchy\>/<\/ul>/;

    $result =~ s{
        <tag[ ]title="(.*?)">
    }{
        my $tag = $1;
                
        "<li id=\"$tag\">$tag</li>\n<ul>";
    }xsge;

    $result =~ s/\<\/tag\>/<\/ul>/g;
    $result =~ s{
        <object>$FullUrlPattern\|$rstr\|(.*?)\|$rstr\|(.*?)</object>  # divide 'object' block content
    }{
        my $url = $1;                                               # to url,
        my $name = $2; if ( length $name == 0 ) { $name = $url; }   # name (if not present use url instead)
        my $description = $3;                                       # and description
        "<li><a href=\"$url\">$name</a> <span class=\"$LinkDescClass\">$description</span></li>";
    }xsge;
    print $result;

}

sub GetLinks { # Search a page for links

    my $text = shift;
    my $text1 = $text;
    my @links;
    while ( $text =~ /($UrlPattern)\s*($LinkTagMark(.+?)$LinkTagMark\s*($LinkDescMark(.+?)$LinkDescMark)?)/cg  # simple link
        or $text1 =~ /\[+$FullUrlPattern(.*?)\]+\s*($LinkTagMark(.+?)$LinkTagMark\s*($LinkDescMark(.+?)$LinkDescMark)?)/cg) {  # link in brackets
        push @links, { url => $1, name => $2, tags => $4, description => $6 };  # push found links' attributes to an array of hashes
    }
    return @links;

}
sub GetLinkTags { # Retrieve tags (if present) from a link

    my $tags = shift;
    my @tags;
    @tags = split /\s*,\s*/, $tags;
    return @tags;

}

*LinkTagMapOldBrowseResolvedPage = *BrowseResolvedPage;
*BrowseResolvedPage = *LinkTagMapBrowseResolvedPage;

sub LinkTagMapBrowseResolvedPage {

    my $title = shift;
    $title =~ s/_/ /g;
    my $id = FreeToNormal($title);
    if ($id eq $LinkTagMapPage) {
        DoLinkTagMap();
    } else {
        LinkTagMapOldBrowseResolvedPage($id);
    }

}

*LinkTagMapOldPrintWikiToHTML = *PrintWikiToHTML;
*PrintWikiToHTML = *LinkTagMapPrintWikiToHTML;

sub LinkTagMapPrintWikiToHTML {

    my ($pageText) = @_;

    # Cause an empty page with the name $LinkTagMapPage to
    # display a map.
    if (($LinkTagMapPage eq $OpenPageName)
        && ($pageText =~ /^\s*$/s)){
        CreateLinkTagMap();
        PrintLinkTagMap();
    }
    LinkTagMapOldPrintWikiToHTML(@_);

}
