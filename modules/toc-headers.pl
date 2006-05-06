# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2006  Igor Afanasyev <afan@mail.ru>
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
# This is a simplified mix of headers.pl and toc.pl to work together.
# It is based on headers.pl 1.12 and toc.pl 1.30.

$ModulesDescription .= '<p>$Id: toc-headers.pl,v 1.1 2006/05/06 21:12:50 as Exp $</p>';

use vars qw($MinTocSize $OrderedLists);

push(@MyRules, \&HeadersRule);

my $MinTocSize = 4; # show toc only if the number of headings is greater or equal to this value
my $OrderedLists = 0; # 1 if use <ol> instead of <ul>

my $TocCounter = 0; # private
my $TocShown = 0; # private

sub HeadersRule {
  my $html = undef;
  
  if (!$TocShown) {
    $html = CloseHtmlEnvironments() . TocHeadings() . AddHtmlEnvironment('p');
    $TocShown = 1;
  }
    
  if ($bol && (m/\G((.+?)[ \t]*\n(---+|===+)[ \t]*\n)/gc)) {
    $html .= CloseHtmlEnvironments();
    $TocCounter++;
    $html .= "<a name=\"#$TocCounter\"></a>";
    if (substr($3,0,1) eq '=') {
      $html .= $q->h2($2);
    } else {
      $html .= $q->h3($2);
    }
    $html .= AddHtmlEnvironment('p');
  }
  
  return $html;
}

sub TocHeadings {
  my $oldpos = pos;          # make this sub not destroy the value of pos
  my $page = $Page{text};   # work on the page that is currently open!
  # ignore all the stuff that gets processed anyway
  foreach my $tag ('nowiki', 'pre', 'code') {
    $page =~ s|<$tag>(.*\n)*?</$tag>||gi;
  }
  my $Headings           = "<h2>" . T('Contents') . "</h2>";
  my $HeadingsLevel      = undef;
  my $HeadingsLevelStart = undef;
  my $count              = 1;
  my $tag				 = $OrderedLists ? 'ol' : 'ul';

  while ($page =~ m/((.+?)[ \t]*\n(---+|===+)[ \t]*\n)/g) {
    my $depth = (substr($3,0,1) eq '=') ? 2 : 3;
    my $text  = $2;
    next unless $text;
    my $link = "$count"; #1, #2, etc. links seem to work fine
    $text = QuoteHtml($text);
    if (not defined $HeadingsLevelStart) {
      # $HeadingsLevel is set to $depth - 1 so that we get an opening
      # of the list.  We need $HeadingsLevelStart to close all open
      # tags at the end.
      $HeadingsLevel      = $depth - 1;
      $HeadingsLevelStart = $depth - 1;
    }
    $count++;
    # if the first subheading is has depth 2, then
    # $HeadingsLevelStart is 1, and later subheadings may not be
    # at level 1 or below.
    $depth = $HeadingsLevelStart + 1 if $depth <= $HeadingsLevelStart;
    # the order of the three expressions is important!
    while ($HeadingsLevel > $depth) {
      $Headings .= "</li></$tag>";
      $HeadingsLevel--;
    }
    if ($HeadingsLevel == $depth) {
      $Headings .= '</li><li>';
    }
    while ($HeadingsLevel < $depth) {
      $Headings .= "<$tag class=\"h$depth\"><li>";
      $HeadingsLevel++;
    }
    $Headings .= "<a href=\"#$link\">$text</a>";
  }
  while ($HeadingsLevel > $HeadingsLevelStart) {
    $Headings .= "</li></$tag>";
    $HeadingsLevel--;
  }
  pos = $oldpos;
  return '' if $count <= $MinTocSize;
  return $q->div({-class=>'toc'}, $Headings)
    if $Headings;
}
