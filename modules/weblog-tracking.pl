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

# Weblog Tracker Notification Extension

use vars qw(%NotifyJournalPage @NotifyUrlPatterns);

# Put this file in your modules directory.

%NotifyJournalPage = ();
@NotifyUrlPatterns = ();

# NotifyJournalPage maps page names matching a certain pattern to
# another page.  In the example given below, \d stands for any number.
# Thus any page name matching a date such as 2004-01-23 will map to
# the Diary page.  You can add more statements like these right here.

$NotifyJournalPage{'\d\d\d\d-\d\d-\d\d'}='Diary';

# NotifyUrlPatterns is a list of URLs to visit.  They may contain three variables:

# 1. $name is replaced by the name of the page.
# 2. $url is replaced by the URL to the page.
# 3. $rss is replaced by the RSS feed for your site.

# You can push more of these statements onto the list.

push (@NotifyUrlPatterns, 'http://ping.blo.gs/?name=$name&url=$url&rssUrl=$rss&direct=1');

# You should not need to change anything below this point.

*OldWeblogTrackingSave = *Save;
*Save = *NewWeblogTrackingSave;

sub NewWeblogTrackingSave {
  my ($id, $new, $summary, $minor, $upload) = @_;
  OldWeblogTrackingSave(@_);
  if (not $minor) {
    PingTracker($id);
  }
}

sub PingTracker {
  my $id = shift;
  foreach my $regexp (keys %NotifyJournalPage) {
    if ($id =~ m/$regexp/) {
      $id = $NotifyJournalPage{$regexp};
      last;
    }
  }
  if ($q->url(-base=>1) !~ m|^http://localhost|) {
    my $url;
    if ($UsePathInfo) {
      $url = $ScriptName . '/' . $id;
    } else {
      $url = $ScriptName . '?' . $id;
    }
    $url = UrlEncode($url);
    my $name = UrlEncode($SiteName . ': ' . $id);
    my $rss = UrlEncode($q->url . '?action=rss');
    require LWP::UserAgent;
    foreach $uri (@NotifyUrlPatterns) {
      my $fork = fork();
      if (not ($fork > 0)) { # either we're the child or forking failed
	$uri =~ s/\$name/$name/g;
	$uri =~ s/\$url/$url/g;
	$uri =~ s/\$rss/$rss/g;
	my $ua = LWP::UserAgent->new;
	my $request = HTTP::Request->new('GET', $uri);
	$ua->request($request);
	exit if ($fork == 0); # exit when we're the child
      }
    }
  }
}
