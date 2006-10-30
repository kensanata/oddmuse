# Copyright (C) 2004, 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: toc.pl,v 1.36 2006/10/30 11:19:17 ingob Exp $</p>';

push(@MyRules, \&TocRule);

# This must come *before* either headers.pl or the usemod.pl rules and
# adds support for portrait-support.pl
$RuleOrder{ \&TocRule } = 90;

use vars qw($TocAutomatic);

$TocAutomatic = 0;
my %TocCounter = ();
my $TocShown = 0;

sub TocRule {
  # Using such a key makes sure that we're not getting confused by
  # headings in the sidebar.
  my $key = $OpenPageName||'toc';
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
    $depth = 2 if $depth < 2;
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings() if not $TocShown and $TocAutomatic;
    $TocShown = 1 if $TocAutomatic;
    my $TocKey = $key . ++$TocCounter{$key};
    $html .= AddHtmlEnvironment('h' . $depth, qq{id="$TocKey"});
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  } elsif ($UseModMarkupInTitles
	   && (InElement('h1')
	       || InElement('h2')
	       || InElement('h3')
	       || InElement('h4')
	       || InElement('h5')
	       || InElement('h6'))
	   && m/\G[ \t]*=+\n?/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  } elsif ($bol && defined(&UsemodRule)
	   && !$UseModMarkupInTitles
	   && m/\G(\s*\n)*(\=+)[ \t]*(.+?)[ \t]*(=+)[ \t]*\n?/cg) {
    my $depth = length($2);
    $depth = 6 if $depth > 6;
    $depth = 2 if $depth < 2;
    my $text = $3;
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings() if not $TocShown and $TocAutomatic;
    $TocShown = 1 if $TocAutomatic;
    my $TocKey = $key . ++$TocCounter{$key};
    $html .= qq{<h$depth id="$TocKey">$text</h$depth>}
      . AddHtmlEnvironment('p');
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  } elsif ($bol && defined(&HeadersRule)
	   && (m/\G((.+?)[ \t]*\n(---+|===+)[ \t]*\n)/gc)) {
    my $depth = substr($3,0,1) eq '=' ? 2 : 3;
    my $text = $2;
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings() if not $TocShown and $TocAutomatic;
    $TocShown = 1 if $TocAutomatic;
    my $TocKey = $key . ++$TocCounter{$key};
    $html .= qq{<h$depth id="$TocKey">$text</h$depth>}
      . AddHtmlEnvironment('p');
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  }
  return undef;
}

sub TocHeadings {
  # Using such a key makes sure that we're not getting confused by
  # headings in the sidebar. If we're rendering the headings inside
  # the sidebar, we want to refer to the headings in the real page.
  # $OpenPageName points to the $SidebarName, however, so that the
  # forms extension works. That's why we have a separate variable
  # being used, here.
  my $key = $SideBarOpenPageName||$OpenPageName||'toc';
  my $oldpos = pos;          # make this sub not destroy the value of pos
  my $page = $Page{text};   # work on the page that is currently open!
  # ignore all the stuff that gets processed anyway
  $page =~ s!<nowiki>.*?</nowiki>!!gis if defined &UsemodRule;
  $page =~ s!<code>.*?</code>!!gis if defined &UsemodRule;
  $page =~ s!(^|\n)<pre>.*?</pre>!!gis if defined &UsemodRule;
  $page =~ s!##.*?##!!gis if defined &MarkupRule;
  $page =~ s!%%.*?%%!!gis if defined &MarkupRule;
  # transform headers markup to usemod markup to 
  $page =~ s!(.+?)[ \t]*\n===+[ \t]*\n!== $1 =\n!gi if defined &HeadersRule;
  $page =~ s!(.+?)[ \t]*\n---+[ \t]*\n!=== $1 =\n!gi if defined &HeadersRule;
  my $Headings           = "<h2>" . T('Contents') . "</h2>";
  my $HeadingsLevel      = undef;
  my $HeadingsLevelStart = undef;
  my $count              = 1;
  # try to determine what will end up as a header
  foreach my $line (grep(/^(=|<h\d>)/, split(/\n/, $page))) {
    my ($depth, $text, $link);
    if ($line =~ /^(\=+)[ \t]*(.*?)[ \t]*\=+[ \t]*$/) {
      $depth = length($1);
      $link = $key . $count;
      $text  = $2;
    } elsif ($line =~ /^<h(\d)><a id\="(.+)">[ \t]*(.*?)[ \t]*<\/a><\/h\1>[ \t]*$/) {
      $depth = $1;
      $link  = $2;
      $text  = $3;
    }
    next unless $text;
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
