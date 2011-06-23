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

$ModulesDescription .= '<p>$Id: offline.pl,v 1.2 2011/06/23 00:35:56 as Exp $</p>';

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
  # Switch to HTML5:
  if (GetParam('offline', 0)) {
    my $manifest = ScriptUrl('action=manifest');
    $DocumentHeader = qq{<!DOCTYPE HTML>
<html manifest="$manifest">
};
  }
  if ($HtmlHeaders !~ /apple-mobile-web-app-capable/) {
    $HtmlHeaders .= qq{
<meta name="apple-mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-status-bar-style" content="black" />
};
  }
}

$Action{manifest} = \&DoManifest;

# List all the pages necessary for the offline application.
sub DoManifest {
  print GetHttpHeader('text/cache-manifest');
  my $offline = ScriptUrl('action=offline');
  print "CACHE MANIFEST\n";
  foreach my $id (AllPagesList()) {
    print ScriptUrl($id) . "\n";
  }
  # Missing pages that should show the default text such as
  # RecentChanges
  foreach my $id (@UserGotoBarPages) {
    print ScriptUrl($id) . "\n" unless $IndexHash{$id};
  }
  # External CSS
  print $StyleSheet . "\n" if $StyleSheet;
  # FIXME: $StyleSheetPage
  # FIXME: external images, stuff in $HtmlHeaders
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
	      '503 SERVICE UNAVAILABLE',
	      0, $q->p(T('You are currently offline and the page you requested has not been added to the cache. Reconnect to the network and visit the page in order to add it to the cache.')));
}
