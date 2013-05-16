# Copyright (C) 2007–2013  Alex Schroeder <alex@gnu.org>
#
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/duckduckgo-search.pl">duckduckgo-search.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Use_DuckDuckGo_For_Searches">Use DuckDuckGo For Searches</a></p>';

use vars qw($DuckDuckGoSearchDomain);

$DuckDuckGoSearchDomain = undef;

$Action{search} = \&DoDuckDuckGoSearch;

push(@MyInitVariables, \&DuckDuckGoSearchInit);

sub DuckDuckGoSearchInit {
  # If $ScriptName does not contain a hostname, this extension will
  # have no effect. Domain regexp based on RFC 2396 section 3.2.2.
  if (!$DuckDuckGoSearchDomain) {
    my $alpha = '[a-zA-Z]';
    my $alphanum = '[a-zA-Z0-9]';
    my $alphanumdash = '[-a-zA-Z0-9]';
    my $domainlabel = "$alphanum($alphanumdash*$alphanum)?";
    my $toplabel = "$alpha($alphanumdash*$alphanum)?";
    if ($ScriptName =~ m!^(https?://)?([^/]+\.)?($domainlabel\.$toplabel)\.?(:|/|\z)!) {
      $DuckDuckGoSearchDomain = $3;
    }
  }
  if ($DuckDuckGoSearchDomain
      and GetParam('search', undef)
      and not GetParam('action', undef)
      and not GetParam('old', 0)) {
    SetParam('action', 'search');
  }
}

sub DoDuckDuckGoSearch {
  my $search = GetParam('search', undef);
  print $q->redirect({-uri=>"https://www.duckduckgo.com/?q=$search+site%3A$DuckDuckGoSearchDomain"});
}
