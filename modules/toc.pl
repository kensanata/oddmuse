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

$ModulesDescription .= '<p>$Id: toc.pl,v 1.2 2004/02/09 20:31:19 as Exp $</p>';

*OldTocGetHeader = *GetHeader;
*GetHeader = *NewTocGetHeader;

sub NewTocGetHeader {
  my ($id) = @_;
  my $result = OldTocGetHeader(@_);
  # append TOC to header
  $result .= TocHeadings() if $id;
  return $result;
}

sub TocHeadings {
  $page = GetPageContent(shift);
  # ignore all the stuff that gets processed anyway
  $page =~ s/<nowiki>(.*\n)*<\/nowiki>//gi;
  $page =~ s/<pre>(.*\n)*<\/pre>//gi;
  $page =~ s/<code>(.*\n)*<\/code>//gi;
  my $Headings = '';
  my $HeadingsLevel = 1;
  # try to determine what will end up as a header
  foreach $line (grep(/^\=+.*\=+[ \t]*$/, split(/\n/, $page))) {
    next unless $line =~ /^(\=+)[ \t]*(.*?)[ \t]*\=+[ \t]*$/;
    my $depth = length($1);
    my $text = $2;
    next unless $text;
    my $link = UrlEncode($text);
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
    $Headings .= '<li>' . $text . '</li>';
  }
  while ($HeadingsLevel > 1) {
    $Headings .= '</ol>';
    $HeadingsLevel--;
  }
  return '<div class="toc">' . $Headings . '</div>' if $Headings;
}
