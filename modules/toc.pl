# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: toc.pl,v 1.7 2004/04/03 10:51:21 as Exp $</p>';

*WikiHeading = *NewTocWikiHeading;

sub NewTocWikiHeading {
  my ($depth, $text) = @_;
  $depth = length($depth);
  $depth = 6  if ($depth > 6);
  my $link = UrlEncode($text);
  return "<h$depth><a name=\"$link\">$text</a></h$depth>";
}

*OldTocGetHeader = *GetHeader;
*GetHeader = *NewTocGetHeader;

sub NewTocGetHeader {
  my ($id) = @_;
  my $result = OldTocGetHeader(@_);
  # append TOC to header
  $result .= TocHeadings($id) if $id;
  return $result;
}

sub TocHeadings {
  $page = GetPageContent(shift);
  # ignore all the stuff that gets processed anyway
  foreach my $tag ('nowiki', 'pre', 'code') {
    $page =~ s|<$tag>(.*\n)*?</$tag>||gi;
  }
  my $Headings = '';
  my $HeadingsLevel = 1;
  my $count = 0;
  # try to determine what will end up as a header
  foreach $line (grep(/^\=+.*\=+[ \t]*$/, split(/\n/, $page))) {
    next unless $line =~ /^(\=+)[ \t]*(.*?)[ \t]*\=+[ \t]*$/;
    my $depth = length($1);
    my $text = $2;
    next unless $text;
    my $link = UrlEncode($text);
    $count++;
    $depth = 2 if $depth < 2;
    $depth = 6 if $depth > 6;
    while ($HeadingsLevel < $depth) {
      $Headings .= '<ol>';
      $HeadingsLevel++;
    }
    while ($HeadingsLevel > $depth) {
      $Headings .= '</ol>';
      $HeadingsLevel--;
    }
    $Headings .= "<li><a href=\"#$link\">$text</a></li>";
  }
  while ($HeadingsLevel > 1) {
    $Headings .= '</ol>';
    $HeadingsLevel--;
  }
  return '' if $count <= 2;
  return '<div class="toc">' . $Headings . '</div>' if $Headings;
}
