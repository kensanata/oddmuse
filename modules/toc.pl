# Copyright (C) 2004, 2005, 2006, 2007  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>XXX $Id: toc.pl,v 1.46 2007/08/17 16:03:09 as Exp $</p>';

push(@MyRules, \&TocRule);

# This must come *before* either headers.pl or the usemod.pl rules and
# adds support for portrait-support.pl
$RuleOrder{\&TocRule} = 90;

use vars qw($TocAutomatic $TocProcessing $TocShown $TocCounter);

$TocAutomatic = 1;
my $TocPage;

push(@MyInitVariables, \&TocInit);

sub TocInit {
  $TocPage = GetId(); # this is the TOC target
  $TocCounter = 0;
  $TocProcessing = 0;
  $TocShown = 0;
}

# If we're rendering the headings inside the sidebar, we want to refer
# to the headings in the real page. $OpenPageName points to the
# $SidebarName, however, so that the forms extension works. That's why
# we have a separate variable being used, here.

sub TocRule {
  # When rendering a heading in the SideBar, $TocPage will be ne
  # $OpenPageBar, making sure that this heading doesn't get an id
  # attribute. The test for an empty $OpenPageName serves to
  # facilitate tests.
  my $id_required = ($TocPage eq $OpenPageName || $OpenPageName eq '');
  if (m!\G&lt;toc(/[A-Za-z\x80-\xff/]+)?&gt;!gci) {
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings(split(m|/|, $1)) unless $TocShown;
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
    if ($id_required) {
      $TocCounter++;
      $html .= AddHtmlEnvironment('h' . $depth, qq{id="toc$TocCounter"});
    } else {
      $html .= AddHtmlEnvironment('h' . $depth);
    }
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
  } elsif ($bol && (defined(&UsemodRule) || defined(&CreoleRule))
	   && !$UseModMarkupInTitles
	   && m/\G(\s*\n)*(\=+)[ \t]*(.+?)[ \t]*(=*)[ \t]*(\n|$)/cg) {
    my $depth = length($2);
    $depth = 6 if $depth > 6;
    $depth = 2 if $depth < 2;
    my $text = $3;
    my $html = CloseHtmlEnvironments()
      . ($PortraitSupportColorDiv ? '</div>' : '');
    $html .= TocHeadings() if not $TocShown and $TocAutomatic;
    $TocShown = 1 if $TocAutomatic;
    if ($id_required) {
      $TocCounter++;
      $html .= qq{<h$depth id="toc$TocCounter">$text</h$depth>};
    } else {
      $html .= qq{<h$depth>$text</h$depth>};
    }
    $html .= AddHtmlEnvironment('p');
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
    if ($id_required) {
      $TocCounter++;
      $html .= qq{<h$depth id="toc$TocCounter">$text</h$depth>};
    } else {
      $html .= qq{<h$depth>$text</h$depth>};
    }
    $html .= AddHtmlEnvironment('p');
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  }
  return undef;
}

sub TocHeadings {
  # avoid recursion
  return '' if $TocProcessing;
  local $TocProcessing = 1;
  local $TocCounter; # these numbers must be temporary
  # don't mess up \G
  my ($oldpos, $old_) = (pos, $_);
  my $class = 'toc' . join(' ', @_);
  my $key = 'toc';
  # double rendering
  my $html = PageHtml($TocPage);
  my $Headings = $q->h2(T('Contents'));
  my $HeadingsLevel      = undef;
  my $HeadingsLevelStart = undef;
  my $count = 1;
  while ($html =~ m!<h([1-6]) id=[^>]*>(.*?)</h[1-6]>!g) {
    my ($depth, $text) = ($1, $2);
    my $link = $key . $count;
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
  ($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
  return '' if $count <= 2;
  return $q->div({-class=>$class}, $Headings) if $Headings;
}
