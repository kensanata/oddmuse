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

$ModulesDescription .= '<p>$Id: linktagmap.pl,v 1.1 2007/04/04 07:07:28 uvizhe Exp $</p>';

use vars qw($LinkTagMark $LinkDescMark $LinkTagClass $LinkDescClass $LinkTagMapPage);

$LinkTagMark = '%T%' unless defined $LinkTagMark;
$LinkDescMark = '%D%' unless defined $LinkDescMark;

$LinkTagClass = "lntag" unless defined $LinkTagClass;
$LinkDescClass = "lndesc" unless defined $LinkDescClass;

$LinkTagMapPage = "LinkTagMap" unless defined $LinkTagMapPage;

$Action{linktagmap} = \&DoLinkTagMap;

push (@MyRules, \&LinkTagRule, \&LinkDescriptionRule);

my %TagList = ();
my $TagXML;

sub LinkTagRule {

    if ( m/\G$LinkTagMark(.*?)$LinkTagMark/gc) {
        my @linktags = split /,\s*/, $1;
        @linktags = map {
            qq{<a href="$LinkTagMapPage#$_">$_</a>};
        } @linktags;
        $linktags = join ', ', @linktags;
        return qq{<span class="$LinkTagClass">$linktags</span>};
    }
    return undef;

}

sub LinkDescriptionRule {

    if ( m/\G$LinkDescMark(.*?)$LinkDescMark/gc) {
        return qq{<span class="$LinkDescClass">$1</span>};
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

sub CreateLinkTagMap { 

    my @pages = AllPagesList();

    local %Page;
    local $OpenPageName='';
    $TagXML .= "<taglist>\n";

    foreach my $page (@pages) {
        OpenPage($page);
        my @links = GetLinks($Page{text});
    	foreach my $link (@links) {
        	my @tags = GetLinkTags($link);
            my $count = @tags;
            if ($count != 0) {
	    	$link =~ s/([fh]t{1,2}ps?\:\/\/.+?)\]+.*?($LinkTagMark.+?$LinkTagMark)($LinkDescMark.+?$LinkDescMark)?/$1$3/;
                $TagXML .= "<object><id>$link</id>\n";

                foreach (@tags) {
                    $TagXML .= "<tag>$_</tag>";
                    $TagList{$_} = 1;
                }
                $TagXML .= "\n</object>\n";
            }
        }
    }
    $TagXML .= "</taglist>\n";

}

sub PrintLinkTagMap {

    do "$ModuleDir/TagCategorizer/TagCategorizer.pl";

    my $result = TagCategorizer::ProcessXML($TagXML);

    $result =~ s/\<tagHierarchy\>/<ul>/;
    $result =~ s/\<\/tagHierarchy\>/<\/ul>/;

    $result =~ s{
        <tag[ ]title="(.*?)">
    }{
        my $tag = $1;
                
        "<li id=\"$tag\">$tag</li>\n<ul>";
    }xsge;

    $result =~ s/\<\/tag\>/<\/ul>/g;
    $result =~ s{
        <object>(.*?)(\|(.*?))?($LinkDescMark(.+?)$LinkDescMark)?</object>
    }{
        my $id = $1;
        my $name = $3;
        my $description = $5;
        "<li><a href=\"$id\">$name</a> <span class=\"$LinkDescClass\">$description</span></li>";
    }xsge;
    print $result;

}

sub GetLinks {

    my $text = shift;
    my @links;
    while ($text =~ /([fh]t{1,2}ps?\:\/\/.+?)\s*($LinkTagMark.+?$LinkTagMark)\s*($LinkDescMark.+?$LinkDescMark)?/gc) {
        push @links, $1.$2.$3;
    }
    return @links;

}
sub GetLinkTags {

    my $link = shift;
    my @tags;

    # strip [[.*?]] bits, then split on spaces
    if ($link =~ /$LinkTagMark\s*(.*)$LinkTagMark/m) {
        my $tagstring = $1;
        @tags = split /,\s*/, $tagstring;
    } else {
        return;
    }
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

    my ($pageText, $savecache, $revision, $islocked) = @_;

    # Cause an empty page with the name $ClusterMapPage to
    # display a map.
    if (($LinkTagMapPage eq $OpenPageName)
        && ($pageText =~ /^\s*$/s)){
        CreateLinkTagMap();
        PrintLinkTagMap();
    }
    LinkTagMapOldPrintWikiToHTML(@_);

}
