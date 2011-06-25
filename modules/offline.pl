# Copyright (C) 2011  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: offline.pl,v 1.5 2011/06/25 13:54:00 as Exp $</p>';

# Based on http://diveintohtml5.org/offline.html

push(@MyAdminCode, \&OfflineMenu);

sub OfflineMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=browse;id=' . UrlEncode($id) . ';offline=1',
		  T('Make available offline'),
		  'offline'));
}

push(@MyInitVariables, \&InitOffline);

sub InitOffline {
  # Make sure we parse path_info and parameters
  GetId();
  # Switch to HTML5 if the offline parameter is set
  if (GetParam('offline', 0)) {
    # add link to the manifest listing all the pages
    my $manifest = ScriptUrl('action=manifest');
    $DocumentHeader = qq{<!DOCTYPE HTML>
<html manifest="$manifest">
};
    # HACK ALERT: In order to allow the browser to cache all the pages
    # listed in the manifest, we need to disable surge protection for
    # the offline pages.
    $SurgeProtection = 0;
    # every offline page will link to other offline pages
    $ScriptName .= '/offline' unless $ScriptName =~ m!/offline$!;
    # add some links for Apple devices (boo!)
    if ($HtmlHeaders !~ /apple-mobile-web-app-capable/) {
      $HtmlHeaders .= qq{
<meta name="apple-mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-status-bar-style" content="black" />
};
    }
  }
}

$Action{manifest} = \&DoManifest;

# List all the pages necessary for the offline application.
sub DoManifest {
  print GetHttpHeader('text/cache-manifest');
  print "CACHE MANIFEST\n";
  # make sure to list the URLs for the offline version
  local $ScriptName = $ScriptName . '/offline';
  # don't forget to URL encode
  foreach my $id (AllPagesList()) {
    print ScriptUrl(UrlEncode($id)) . "\n";
  }
  # Missing pages that should show the default text such as
  # RecentChanges cannot be added because fetching them results in a
  # 404 error.
  # foreach my $id (@UserGotoBarPages) {
  #   print ScriptUrl($id) . "\n" unless $IndexHash{$id};
  # }
  # External CSS
  print $StyleSheet . "\n" if $StyleSheet;
  # FIXME: $StyleSheetPage
  # FIXME: external images, stuff in $HtmlHeaders
  # Error message all the stuff that's not available offline.
  my $offline = ScriptUrl('action=offline');
  print qq{
FALLBACK:
/ $offline
NETWORK:
*
};
}

$Action{offline} = \&DoOffline;

# Show an excuse for the pages that have not been cached.
sub DoOffline {
  ReportError(T('Offline'),
	      '200 OK',
	      0, $q->p(T('You are currently offline and what you requested is not part of the offline application. You need to be online to do this.')));
}

# Fix redirection.
*OldOfflineReBrowsePage = *ReBrowsePage;
*ReBrowsePage = *NewOfflineReBrowsePage;

sub NewOfflineReBrowsePage {
  my ($id) = @_;
  if (GetParam('offline', 0)) {
    BrowsePage($id);
  } else {
    OldOfflineReBrowsePage(@_);
  }
}
