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

$ModulesDescription .= '<p>$Id: image.pl,v 1.1 2004/05/31 00:29:07 as Exp $</p>';

push( @MyRules, \&ImageSupportRule );

# [[image/class:page name|alt text|target]]

sub ImageSupportRule {
  if (m!\G\[\[image(/[a-z])?:$FreeLinkPattern(|[^]|])?(|[^]])?\]\]!gc) {
    my $class = $1 ? substr($1, 1) : 'image picture';
    my $name = $2;
    my $alt = substr($3, 1) if $3;
    my $link = substr($4, 1) if $4;
    my $id = FreeToNormal($name);
    my $linkclass;
    if ($link) {
      if ($link =~ /^$UrlPattern/) {
	$linkclass = 'outside';
      } else {
	$linkclass = 'local';
	if ($UsePathInfo and !$Monolithic) {
	  $link = $ScriptName . '/' . $link;
	} elsif ($Monolithic) {
	  $link = '#' . $link;
	} else {
	  $link = $ScriptName . '?' . $link;
	}
      }
    }
    my $src;
    if ($UsePathInfo) {
      $src = $ScriptName . "/download/" . UrlEncode($id);
    } else {
      $src = $ScriptName . "?action=download;id=" . UrlEncode($id);
    }
    my $result = $q->img({-src=>$src, -alt=>$alt, -class=>$class});
    $result = $q->a({-href=>$link, -class=>$linkclass}, $result) if $link;
    return $result;
  }
  return '';
}
