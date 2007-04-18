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
$ModulesDescription .= '<p>$Id: linktagmap.pl,v 1.3 2007/04/18 11:29:21 uvizhe Exp $</p>';

use vars qw($LinkTagMark $LinkDescMark $LinkTagClass $LinkDescClass $LinkTagMapPage $FreeLinkPattern $FullUrlPattern);

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

push (@MyRules, \&LinkTagRule, \&LinkDescriptionRule);

my $TagXML;

sub LinkTagRule { # Process link tags on a page

    if ( m/\G$LinkTagMark(.*?)$LinkTagMark/gc) {      # find tags
        my @linktags = split /,\s*/, $1;              # push them in array
        @linktags = map {                             # and print html output:
            qq{<a href="$LinkTagMapPage#$_">$_</a>};  # each tag is a link to correspondent anchor on the $LinkTagMapPage
        } @linktags;
        $linktags = join ', ', @linktags;
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

    CreateLinkTagMap();

    print '<div class="content">';

    PrintLinkTagMap();

    print '</div>';

    PrintFooter();

}

sub CreateLinkTagMap { # Create an input XML for TagCategorizer

    my @pages = AllPagesList();

    local %Page;
    local $OpenPageName='';

    $TagXML .= "<taglist>\n";

    foreach my $page (@pages) {
        OpenPage($page);                    # open page
        my @links = GetLinks($Page{text});  # find links
       	foreach my $link (@links) {
            my @tags = GetLinkTags($link->{tags});  # process tags for each link
            if ($#tags >= 0) {
                $TagXML .= "<object><id>$link->{url}|$link->{url_text}|$link->{description}</id>\n";  # put everything in 'id' block
                foreach (@tags) {                                                                     # except of tags
                    $TagXML .= "<tag>$_</tag>";                                                       # which are in 'tag' blocks
                }
                $TagXML .= "\n</object>\n";
            }
        }
    }
    $TagXML .= "</taglist>\n";

}

sub PrintLinkTagMap {

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
        <object>$FullUrlPattern\|$FreeLinkPattern?\|(.*?)</object>  # divide 'object' block content
    }{
        my $url = $1;                                               # to url,
        my $name = $2; if ( length $name == 0 ) { $name = $url; }   # name (if present)
        my $description = $3;                                       # and description
        "<li><a href=\"$url\">$name</a> <span class=\"$LinkDescClass\">$description</span></li>";
    }xsge;
    print $result;

}

sub GetLinks { # Search a page for links

    my $text = shift;
    my @links;
    while ($text =~ /\[{0,2}$FullUrlPattern\s*\|?\s*$FreeLinkPattern?\]{0,2}\s*$LinkTagMark(.+?)$LinkTagMark\s*($LinkDescMark(.+?)$LinkDescMark)?/gc) {
        push @links, { url => $1, url_text => $2, tags => $3, description => $5 };  # push found links' attributes to an array of hashes
    }
    return @links;

}
sub GetLinkTags { # Retrieve tags (if present) from links

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
