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

$ModulesDescription .= '<p>$Id: image.pl,v 1.15 2005/03/01 16:48:01 sblatt Exp $</p>';

use vars qw($ImageUrlPath);

$ImageUrlPath = '/images';      # URL where the images are to be found

push(@MyRules, \&ImageSupportRule);

# [[image/class:page name|alt text|target]]

sub ImageSupportRule {
  my $result = undef;
  if (m!\G\[\[image(/[a-z]+)?( external)?:($FreeLinkPattern|$FullUrlPattern)(\|[^]|]+)?(\|($FreeLinkPattern|$FullUrlPattern))?\]\]!gc) {
    my $oldpos = pos;
    my $class = 'image';
    $class .= ' ' . substr($1, 1) if $1;
    my $external = $2;
    my $name = $3;
    my $alt = $6 ? substr($6, 1) : T("image: %s", $name);
    my $link = $7 ? substr($7, 1) : '';
    my $id = FreeToNormal($name);
    # link to the image if no link was given
    if (not $link) {
      if ($external) {
        if ($name =~ /$FullUrlPattern/) {
          $link = $name;
        } else {
          $link = $ImageUrlPath . '/' . UrlEncode($id);
        }
      } else {
        $link = UrlEncode($id);
      }
    }
    if ($link =~ /$FullUrlPattern/) {
      $link = $1;
      $class .= ' outside';
    } else {
      if (substr($link, 0, 1) eq '/') {
        # do nothing -- relative URL on the same server
      } elsif ($UsePathInfo and !$Monolithic) {
        $link = $ScriptName . '/' . $link;
      } elsif ($Monolithic) {
        $link = '#' . $link;
      } else {
        $link = $ScriptName . '?' . $link;
      }
    }
    my $src;
    if ($external) {
      if ($name =~ /$FullUrlPattern/) {
        $src = $name;
      } else {
        $src = $ImageUrlPath . '/' . UrlEncode($id);
      }
    } else {
      $src = ImageGetInternalUrl($id);
    }
    $result = $q->img({-src=>$src, -alt=>$alt, -title=>$alt, -class=>'upload'});
    $result = $q->a({-href=>$link, -class=>$class}, $result);
    pos = $oldpos;
  }
  return $result;
}

# split off to support overriding from Static Extension
sub ImageGetInternalUrl {
  my $id = shift;
  if ($UsePathInfo) {
    return $ScriptName . "/download/" . UrlEncode($id);
  }
  return $ScriptName . "?action=download;id=" . UrlEncode($id);
}
