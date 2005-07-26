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

$ModulesDescription .= '<p>$Id: subscriberc.pl,v 1.5 2005/07/26 10:30:00 as Exp $</p>';

push(@MyRules, \&SubscribedRecentChangesRule);

sub SubscribedRecentChangesRule {
  if ($bol) {
    if (m/\GMy\s+subscribed\s+pages:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)+)categories:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)*(?:$LinkPattern|\[\[$FreeLinkPattern\]\]))/gc) {
      return Subscribe($1, $4);
    } elsif (m/\GMy\s+subscribed\s+pages:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)*(?:$LinkPattern|\[\[$FreeLinkPattern\]\]))/gc) {
      return Subscribe($1, '');
    } elsif (m/\GMy\s+subscribed\s+categories:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)*(?:$LinkPattern|\[\[$FreeLinkPattern\]\]))/gc) {
      return Subscribe('', $1);
    }
  }
  return undef;
}

sub Subscribe {
  my ($pages, $categories) = @_;
  my $oldpos = pos;
  my @pageslist = map {
    if (/\[\[$FreeLinkPattern\]\]/) {
      FreeToNormal($1);
    } else {
      $_;
    }
  } split(/\s*,\s*/, $pages);
  my @catlist = map {
    if (/\[\[$FreeLinkPattern\]\]/) {
      FreeToNormal($1);
    } else {
      $_;
    }
  } split(/\s*,\s*/, $categories);
  my $regexp;
  $regexp .= '^(' . join('|', @pageslist) . ")\$" if @pageslist;
  $regexp .= '|' if @pageslist and @catlist;
  $regexp .= '(' . join('|', @catlist) . ')' if @catlist;
  pos = $oldpos;
  my $html = 'My subscribed ';
  return $html unless @pageslist or @catlist;
  $html .= 'pages: ' . join(', ', map { s/_/ /g; $_; } @pageslist)
    if @pageslist;
  $html .= ', ' if @pageslist and @catlist;
  $html .= 'categories: ' . join(', ', map { s/_/ /g; $_; } @catlist)
    if @catlist;
  return ScriptLink('action=rc;rcfilteronly=' . $regexp, $html);
}
