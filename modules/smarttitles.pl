# Copyright (C) 2006 Charles Mauch <cmauch@gmail.com>
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

$ModulesDescription .= '<p>$Id: smarttitles.pl,v 1.5 2006/10/01 04:26:11 xterminus Exp $</p>';

push(@MyRules, \&StripTitlesRule);

sub StripTitlesRule {
    if ( m/\G#TITLE[ \t]+(.*?)\s*\n+/cg ) {
            return undef;
    }
    return undef;
}

push( @MyRules, \&StripSubTitlesRule );

sub StripSubTitlesRule {
    if ( m/\G#SUBTITLE[ \t]+(.*?)\s*\n+/cg ) {
      return undef;
    }
  return undef;
}

*OldSmartGetHeader = *GetHeader;
*GetHeader = *NewSmartGetHeader;

sub NewSmartGetHeader {
    my ($id, $title, $oldId, $nocache, $status, $rev) = @_;
    my $header = OldSmartGetHeader(@_);
    $title = NormalToFree($title);

    return $header unless $id;    
    OpenPage($id);
 
    my ( $smarttitle ) = ( $Page{ text } =~ /\#TITLE[ \t]+(.*?)\s*\n+/ );    
 
    if ($smarttitle) {
        my $OldGetHtmlHeader = '>' . $title . '</a>';
        my $NewGetHtmlHeader = '>' . $smarttitle . '</a>';
        $header =~ s/$OldGetHtmlHeader/$NewGetHtmlHeader/g;

        my $OldTitle = '<title>' . $SiteName . ': ' . $title . '</title>';
        my $NewTitle = '<title>' . $SiteName . ': ' . $smarttitle . '</title>';
        $header =~ s/$OldTitle/$NewTitle/;
    }
    
    my ( $subtitle ) = ( $Page{ text } =~ m/\#SUBTITLE[ \t]+(.*?)\s*\n+/ );

    if ( $subtitle ) {
        my $OldSubGetHtmlHeader = '</a></h1>';
        my $NewSubGetHtmlHeader =
          '</a></h1><p class="subtitle">' . $subtitle . '</p>';
        $header =~ s/$OldSubGetHtmlHeader/$NewSubGetHtmlHeader/g;
    }

    return $header;
}
