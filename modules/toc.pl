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

$ModulesDescription .= '<p>$Id: toc.pl,v 1.24 2005/08/28 17:38:22 as Exp $</p>';

push(@MyRules, \&TocRule);

# This must come *before* the usemod.pl rules and adds support for
# portrait-support.pl
$RuleOrder{ \&TocRule } = 90;

use vars qw($TocAutomatic);

$TocAutomatic = 1;
my $TocCounter = 0;
my $TocShown = 0;

sub TocRule {
  if (m/\G&lt;toc&gt;/gci) {
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings() unless $TocShown;
    $html .= AddHtmlEnvironment('p');
    $TocShown = 1;
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  } elsif ($bol
	   && $UseModMarkupInTitles
	   && m/\G(\s*\n)*(\=+)[ \t]*(?=[^=\n]+=)/cg) {
    my $depth = length($2);
    $depth = 6 if $depth > 6;
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings() if not $TocShown and $TocAutomatic;
    $html .= AddHtmlEnvironment('h' . $depth)
      . $q->a({-id=>'toc' . $TocCounter++});
    $TocShown = 1;
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  } elsif ($UseModMarkupInTitles
	   && m/\G[ \t]*=+\n?/cg
	   && (InElement('h1')
		|| InElement('h2')
		|| InElement('h3')
		|| InElement('h4')
		|| InElement('h5')
		|| InElement('h6'))) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  } elsif ($bol
	   && !$UseModMarkupInTitles
	   && m/\G(\s*\n)*(\=+)[ \t]*(.+?)[ \t]*(=+)[ \t]*\n?/cg) {
    my $depth = length($2);
    $depth = 6 if $depth > 6;
    my $text = $3;
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings() if not $TocShown and $TocAutomatic;
    $html .= "<h$depth>"
      . $q->a({-id=>'toc' . $TocCounter++}, $text)
      . "</h$depth>"
      . AddHtmlEnvironment('p');
    $TocShown = 1;
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  }
  return undef;
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
  my $count              = 0;
  # try to determine what will end up as a header
  foreach my $line (grep(/^\=+.*\=+[ \t]*$/, split(/\n/, $page))) {
    next unless $line =~ /^(\=+)[ \t]*(.*?)[ \t]*\=+[ \t]*$/;
    my $depth = length($1);
    my $text  = $2;
    next unless $text;
    my $link = "toc$count";
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
    $depth = 6 if $depth > 6;
    # the order of the three expressions is important!
    while ($HeadingsLevel > $depth) {
      $Headings .= '</li></ol>';
      $HeadingsLevel--;
    }
    if ($HeadingsLevel == $depth) {
      $Headings .= '</li><li>';
    }
    while ($HeadingsLevel < $depth) {
      $Headings .= '<ol><li>';
      $HeadingsLevel++;
    }
    $Headings .= "<a href=\"#$link\">$text</a>";
  }
  while ($HeadingsLevel > $HeadingsLevelStart) {
    $Headings .= '</li></ol>';
    $HeadingsLevel--;
  }
  pos = $oldpos;
  return '' if $count <= 2;
  return $q->div({-class=>'toc'}, $Headings)
    if $Headings;
}
