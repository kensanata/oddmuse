#!/usr/bin/env perl
# ====================[ toc.pl                             ]====================

=head1 NAME

toc - An Oddmuse module for adding a "Table of Contents" to Oddmuse Wiki pages.

=head1 INSTALLATION

toc is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
$ModulesDescription .= '<p>$Id: toc.pl,v 1.53 2008/11/05 06:19:18 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

toc is easily configurable; set these variables in the B<wiki/config.pl> file
for your Oddmuse Wiki.

=cut
use vars qw($TocHeaderText
            $TocAutomatic
            $TocIsConvertingH1TagsToH2Tags

            $TocProcessing $TocShown $TocCounter);

=head2 $TocHeaderText

The string to be displayed as the header for each page's table of contents.

=cut
$TocHeaderText = 'Contents';

=head2 $TocAutomatic

A boolean that, if true, automatically prepends the table of contents to the
first header for a page or, if false, does not. If false, you must explicitly
add the table of contents to each page for which you'd like one by explicitly
adding the "<toc>" markup to that page.

By default, this boolean is true.

=cut
$TocAutomatic = 1;

=head2 $TocIsConvertingH1TagsToH2Tags

A boolean that, if true, converts all "<h1>...</h2>" tags to "<h2>...</h2>" tags
for all pages. So, if true, this converts all level-1 headers to level-2 headers
and leaves all other headers unchanged. This is the Usemod convention and, as
Oddmuse is derived from Usemod, the default convention for this module, too.

By default, this boolean is true.

=cut
$TocIsConvertingH1TagsToH2Tags = 1;

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&TocInit);

# If we're rendering the headings inside the sidebar, we want to refer
# to the headings in the real page. $OpenPageName points to the
# $SidebarName, however, so that the Forms extension works. That's why
# we have a separate variable being used, here.
my $TocPage;

sub TocInit {
  $TocPage = GetId(); # this is the TOC target
  $TocCounter = 0;
  $TocProcessing = 0;
  $TocShown = 0;
}

# ....................{ MARKUP                             }....................
push(@MyRules, \&TocRule);

# This must come *before* either headers.pl or the usemod.pl rules and
# adds support for portrait-support.pl
$RuleOrder{\&TocRule} = 90;

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
       $depth = 2 if $depth < 2 and $TocIsConvertingH1TagsToH2Tags;

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
  } elsif ($UseModMarkupInTitles &&
           (InElement('h1')
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
       $depth = 2 if $depth < 2 and $TocIsConvertingH1TagsToH2Tags;

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
  return if $TocProcessing > 1;
  local $TocProcessing = $TocProcessing + 1;
  # these numbers must be temporary
  local $TocCounter;
  # don't mess up \G
  my ($oldpos, $old_) = (pos, $_);
  my $class = 'toc' . join(' ', @_);
  my $key =   'toc';

  # Double rendering to make sure we get the table of contents right,
  # even though we don't know what markup rules are in effect.
  my $html =  TocPageHtml($TocPage);
  my $Headings = $q->h2(T($TocHeaderText));
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

# A Footnotes extension-specific hack; see TocPageHtml() comments, below.
use vars qw(@FootnoteList);

sub TocPageHtml {
  # HACK ALERT: PageHtml -> PrintPageHtml -> PrintWikiToHTML with
  # $savecache = 1, but the cache will not be saved because
  # $Page{blocks} and $Page{flags} are already equal unless we
  # localize them here. Without localization, the first request
  # returns the correct TOC, but subsequent requests from the cache do
  # not. (A "local %Page;" will not work here, since that hash has within it
  # several hash entries that must be persisted unmolested through the call to
  # "PageHtml": namely, $Page{text}, having the raw Wiki text for this page).
  local $Page{blocks};
  local $Page{flags};

  # HACK ALERT: If using the Footnotes extension and this page has at least
  # one such footnote, ensure the list of those footnotes is properly saved and
  # restored in between calls to this function. (i.e., "...nuthin' to see here,
  # folks.")
  my @FootnoteListOld = @FootnoteList if defined &FootnotesRule;
  my $html = PageHtml(shift);
     @FootnoteList = @FootnoteListOld if defined &FootnotesRule;

  return $html;
}

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyright 2004, 2005, 2006, 2007 by Alex Schroeder <alex@emacswiki.org>.
Copyleft  2008                   by B.w.Curry <http://www.raiazome.com>.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see L<http://www.gnu.org/licenses/>.

=cut
