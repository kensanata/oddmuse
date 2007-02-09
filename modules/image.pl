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

$ModulesDescription .= '<p>$Id: image.pl,v 1.26 2007/02/09 00:37:29 as Exp $</p>';

use vars qw($ImageUrlPath);

$ImageUrlPath = '/images';      # URL where the images are to be found

push(@MyRules, \&ImageSupportRule);

# [[image/class:page name|alt text|target]]

sub ImageSupportRule {
  my $result = undef;
  if (m!\G\[\[image((/[a-z]+)*)( external)?:([^]|]+)(\|[^]|]+)?(\|[^]|]*)?(\|[^]|]*)?(\|[^]|]*)?\]\]!gc) {
    my $oldpos = pos;
    my $class = 'image' . $1;
    my $external = $3;
    my $name = $4;
    # Don't generate an alt text if none was specified, since the rule
    # forces you to pick an alt text if you're going to provide a
    # link target.
    my $alt = $5 ? substr($5, 1) : '';
    my $link = $6 ? substr($6, 1) : '';
    my $caption = $7 ? substr($7, 1) : '';
    my $reference = $8 ? substr($8, 1) : '';
    my $id = FreeToNormal($name);
    $class =~ s!/! !g;
    my $linkclass = $class;
    # link to the image if no link was given
    $link = $name unless $link;
    if ($link =~ /^($FullUrlPattern|$FreeInterLinkPattern)$/
	or $link =~ /^$FreeLinkPattern$/ and not $external) {
      ($link, $linkclass) = ImageGetExternalUrl($link, $linkclass);
    } else {
      $link = ImageUrlEncode($ImageUrlPath . '/' . $link);
    }
    my $src = $name;
    if ($src =~ /^($FullUrlPattern|$FreeInterLinkPattern)$/) {
      ($src) = ImageGetExternalUrl($src);
    } elsif ($src =~ /^$FreeLinkPattern$/ and not $external) {
      $src = ImageGetInternalUrl($src);
    } else {
      $src = ImageUrlEncode($ImageUrlPath . '/' . $name);
    }
    $result = $q->img({-src=>$src, -alt=>$alt, -title=>$alt, -class=>'upload'});
    $result = $q->a({-href=>$link, -class=>$linkclass}, $result);
    if ($caption) {
      if ($reference) {
	my $refclass = $class;
	($reference, $refclass) = ImageGetExternalUrl($reference, $refclass);
	$caption = $q->a({-href=>$reference, -class=>$refclass}, $caption);
      }
      $result .= $q->br() . $q->span({-class=>'caption'}, $caption);
      $result = CloseHtmlEnvironments() . $q->div({-class=>$class}, $result);
    }
    pos = $oldpos;
  }
  return $result;
}

sub ImageUrlEncode {
  # url encode everything except for slashes
  return join('/', map { UrlEncode($_) } split(/\//, shift));
}

sub ImageGetExternalUrl {
  my ($link, $class) = @_;
  if ($link =~ /^$FullUrlPattern$/) {
    $link = UnquoteHtml($link);
    $class .= ' outside';
  } elsif ($link =~ /^$FreeInterLinkPattern$/) {
    my ($site, $page) = split(/:/, $link, 2);
    $link = GetInterSiteUrl($site, $page, 1); # quote!
    $class .= ' inter ' . $site;
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
  return ($link, $class);
}

# split off to support overriding from Static Extension
sub ImageGetInternalUrl {
  my $id = shift;
  if ($UsePathInfo) {
    return $ScriptName . "/download/" . UrlEncode($id);
  }
  return $ScriptName . "?action=download;id=" . UrlEncode($id);
}
