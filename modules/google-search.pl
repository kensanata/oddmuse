# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/google-search.pl">google-search.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Use_Google_For_Searches">Use Google For Searches</a></p>';

use vars qw($GoogleSearchDomain $GoogleSearchExclusive);

$GoogleSearchDomain = undef;
$GoogleSearchExclusive = 1;

$Action{search} = \&DoGoogleSearch;

push(@MyInitVariables, \&GoogleSearchInit);

sub GoogleSearchInit {
  # If $ScriptName does not contain a hostname, this extension will
  # have no effect. Domain regexp based on RFC 2396 section 3.2.2.
  if (!$GoogleSearchDomain) {
    my $alpha = '[a-zA-Z]';
    my $alphanum = '[a-zA-Z0-9]';
    my $alphanumdash = '[-a-zA-Z0-9]';
    my $domainlabel = "$alphanum($alphanumdash*$alphanum)?";
    my $toplabel = "$alpha($alphanumdash*$alphanum)?";
    if ($ScriptName =~ m!^(https?://)?([^/]+\.)?($domainlabel\.$toplabel)\.?(:|/|\z)!) {
      $GoogleSearchDomain = $3;
    }
  }
  if ($GoogleSearchDomain
      and GetParam('search', undef)
      and not GetParam('action', undef)
      and not GetParam('old', 0)) {
    SetParam('action', 'search');
  }
  *SearchTitleAndBody = *GoogleSearchDoNothing if $GoogleSearchExclusive;
}

# disable all other searches
sub GoogleSearchDoNothing {
  undef;
}

sub DoGoogleSearch {
  my $search = GetParam('search', undef);
  print $q->redirect({-uri=>"http://www.google.com/search?q=site%3A$GoogleSearchDomain+$search"});
}
