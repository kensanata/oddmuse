#!/usr/bin/env perl
# ====================[ smarttitles.pl                     ]====================

=head1 NAME

smarttitles - An Oddmuse module for embedding user-readable titles and subtitles
              for a page in the content for that page.

=head1 INSTALLATION

smarttitles is easily installable: move this file into the B<wiki/modules/>
directory of your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: smarttitles.pl,v 1.7 2008/09/22 10:59:15 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

smarttitles is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($SmartTitlesBrowserTitle
            $SmartTitlesBrowserTitleWithoutSubtitle);

=head2 $SmartTitlesBrowserTitle

The browser title for pages having a subtitle. The browser title is the string
displayed in your browser's titlebar for each page.

smarttitles performs variable substitution on this string, as follows:

=over

=item The first '%s' in this string, if present, is replaced with the Wiki's
      C<$SiteName>.

=item The second '%s' in this string, if present, is replaced with this Wiki
      page's title.

=item The third '%s' in this string, if present, is replaced with this Wiki
      page's subtitle.

=back

=cut
$SmartTitlesBrowserTitle = '%s: %s (%s)';

=head2 $SmartTitlesBrowserTitleWithoutSubtitle

The browser title for pages lacking a subtitle.

smarttitles performs variable substitution on this string, as follows:

=over

=item The first '%s' in this string, if present, is replaced with the Wiki's
      C<$SiteName>.

=item The second '%s' in this string, if present, is replaced with this Wiki
      page's title.

=back

=cut
$SmartTitlesBrowserTitleWithoutSubtitle = '%s: %s';

# ....................{ RULES                              }....................
push(@MyRules, \&SmartTitlesRule);

# "#TITLE" and "#SUBTITLE" conflict with Creole-style numbered lists, and
# "poetry.pl"-style poetry blocks; as such, rules filtering these strings should
# be applied before rules filtering Creole- and "poetry.pl"-style strings. As it
# is likely that these rules, also, conflict with other Oddmuse markup modules,
# this module requests that these rules be applied with high priority -
# presumably before another module is permitted to muck them up.
$RuleOrder{\&SmartTitlesRule} = -50;

=head2 SmartTitlesRule

Strips "#TITLE ...\n" and "#SUBTITLE ...\n" text from the current Wiki page.
Since GetHeaderSmartTitles() already parses this text, it serves little use past
that point.

=cut
sub SmartTitlesRule {
     if (m/\G#TITLE[ \t]+(.*?)\s*\n+/cg   ) { return ''; }
  elsif (m/\G#SUBTITLE[ \t]+(.*?)\s*\n+/cg) { return ''; }

  return undef;
}

# ....................{ FUNCTIONS                          }....................
*GetHeaderSmartTitlesOld = *GetHeader;
*GetHeader =               *GetHeaderSmartTitles;

=head2 GetSmartTitles

Returns the title and subtitle for this page. (Presumably, this page has been
opened with an earlier call to C<OpenPage()>.)

This function is provided as a separate subroutine so as to permit other
extensions (namely, hibernal) to obtain the title and subtitle for pages.

=cut
sub GetSmartTitles {
  return (
    ($Page{text} =~    m/\#TITLE[ \t]+(.*?)\s*\n+/c),
    ($Page{text} =~ m/\#SUBTITLE[ \t]+(.*?)\s*\n+/c)
  );
}

=head2 GetHeaderSmartTitles

Changes the passed page's HTML header to reflect any "#TITLE" or "#SUBTITLE"
within that passed page's Wiki content.

=cut
sub GetHeaderSmartTitles {
  my ($page_name, $title, undef, undef, undef, undef, $subtitle) = @_;
  my ($smart_title, $smart_subtitle);
  my  $html_header = GetHeaderSmartTitlesOld(@_);

  if ($page_name) {
    OpenPage($page_name);
    $title = NormalToFree($title);
    ($smart_title, $smart_subtitle) = GetSmartTitles();
  }

  if (!$smart_title    && $title   ) { $smart_title =    $title; }
  if (!$smart_subtitle && $subtitle) { $smart_subtitle = $subtitle; }

  #          .........{ TITLE                              }.........
  if ($smart_title and $smart_title ne $title) {
    $html_header =~ s~\Q>${title}</a>\Q~>${smart_title}</a>~g;
  }

  #          .........{ SUBTITLE                           }.........
  if ($smart_subtitle) {
    $html_header =~ s~\Q</h1>\Q~</h1><p class="subtitle">${smart_subtitle}</p>~;
  }

  #          .........{ HEADER                             }.........
  {
    my $smart_header;

    if ($SiteName eq $smart_title) {
      $smart_header = $smart_subtitle
        ? sprintf($SmartTitlesBrowserTitleWithoutSubtitle, $SiteName, $smart_subtitle)
        : $SiteName;
    }
    else {
      $smart_header = $smart_subtitle
        ? sprintf($SmartTitlesBrowserTitle,                $SiteName, $smart_title, $smart_subtitle)
        : sprintf($SmartTitlesBrowserTitleWithoutSubtitle, $SiteName, $smart_title);
    }

    $html_header =~ s~\<title\>.*?\<\/title\>~<title>${smart_header}</title>~;
  }

  return $html_header;
}

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008 by B.w.Curry <http://www.raiazome.com>.
Copyright 2006 by Charles Mauch <mailto://cmauch@gmail.com>.

This file is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

=cut
