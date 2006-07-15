# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

use vars qw($PageTypesName);

# You need to define the available types on the following page.

$PageTypesName = 'PageTypes';

# do this later so that the user can customize $SidebarName
push(@MyInitVariables, \&PageTypeInit);

sub PageTypeInit {
  $PageTypesName = FreeToNormal($PageTypesName); # spaces to underscores
  $AdminPages{$PageTypesName} = 1; # mod_perl!
}

# A page type has to appear as a bullet list item on the page.
#
# Example list defining three types:
#
# * foo
# * bar
# * quux baz

# The page type will be prepended to the beginning of a page.  If you
# have page clustering enabled (see the manual), then the page type
# will automatically act as a cluster.

$ModulesDescription .= '<p>$Id: page-type.pl,v 1.6 2006/07/15 23:13:37 as Exp $</p>';

*OldPageTypeDoPost = *DoPost;
*DoPost = *NewPageTypeDoPost;

sub NewPageTypeDoPost {
  my $id = shift;
  my $type = GetParam('types', '');
  if ($type and $type ne T('None')) {
    $type = "[[$type]]" unless $WikiLinks and $type =~ /^$LinkPattern$/;
    my $text = $type . "\n\n" . GetParam('text','');
    # We can't use SetParam(), because we're trying to override a
    # parameter used by the script.  GetParam prefers the actual
    # script parameters to parameters set by the cookie (which is what
    # SetParam manipulates).  We also need to unquote, because
    # GetParam automatically unquotes.
    $q->param(-name=>'text', -value=>UnquoteHtml($text));
  }
  OldPageTypeDoPost($id);
}

*OldPageTypeGetTextArea = *GetTextArea;
*GetTextArea = NewPageTypeGetTextArea;

sub NewPageTypeGetTextArea {
  my ($name, $text) = @_;
  return OldPageTypeGetTextArea(@_) if ($name ne 'text'); # comment box!
  my @types = (T('None'),);
  # read categories
  foreach (split ('\n', GetPageContent($PageTypesName))) {
    if ($WikiLinks and (m/^\*[ \t]($LinkPattern)/)) {
      push (@types, $1);
    } elsif ($FreeLinks and (m/^\*[ \t]\[\[($FreeLinkPattern)\]\]/)) {
      push (@types, $1);
    }
  }
  my $cluster;
  # This duplicates GetCluster code so that this works even when
  # $PageCluster==0.
  $cluster = $1 if ($WikiLinks && $text =~ /^$LinkPattern\n/)
    or ($FreeLinks && $text =~ /^\[\[$FreeLinkPattern\]\]\n/);
  if (grep(/^$cluster$/, @types)) {
    $text =~ s/^.*\n+//; # delete cluster line, and clean up further empty lines
  } else {
    $cluster = T('None');
  }
  #build the new input
  my $html = OldPageTypeGetTextArea($name, $text);
  my $list = T('Type') . ': <select name="types">';
  foreach my $type (@types) {
    if ($type eq $cluster) {
      $list .= "<option value=\"$type\" selected>$type";
    } else {
      $list .= "<option value=\"$type\">$type";
    }
  }
  $list .= "</select>";
  $html .= $q->p($list);
  return $html;
}
