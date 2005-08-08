# Copyright (C) 2005  Sunir Shah <sunir@sunir.org>
# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: open-proxy.pl,v 1.2 2005/08/08 13:05:50 as Exp $</p>';

# We scan proxies by attempting to self-ban ourselves.  If we're
# hitting an open proxy, our request will in fact be forwarded, and
# the proxy has banned himself.  Ordinary users should never call the
# self-ban action.

use vars qw($SelfBan $OpenProxies);

$SelfBan = "xyzzy"; # change this from time to time in your config file
$OpenProxies = "$DataDir/openproxies"; # file storing when what IP got scanned

$Action{$SelfBan} = \&DoSelfBan;

sub DoSelfBan {
  my $date = &TimeToText($Now);
  my $str = '^' . quotemeta($ENV{REMOTE_ADDR});
  OpenPage($BannedHosts);
  Save ($BannedHosts, $Page{text} . "\n\nself-ban on $date\n $str",
	Ts("Self-ban by %s", $ENV{REMOTE_ADDR}), 1); # minor edit
  ReportError(T("You have banned your own IP."));
}

# Before you can edit a page, we do the open proxy scanning.

*OpenProxyOldDoEdit = *DoEdit;
*DoEdit = *OpenProxyNewDoEdit;

sub OpenProxyNewDoEdit {
  BanOpenProxy();
  OpenProxyOldDoEdit(@_);
}

sub BanOpenProxy {
  my ($force) = @_;
  my $ip = $ENV{REMOTE_ADDR};
  my $limit = 60*60*24*30; # rescan after 30 days
  # Only check each IP address once a month
  my %proxy = split(/\s+/,  ReadFile($OpenProxies));
  return if $Now - $proxy{$ip} < $limit;
  # If possible, do the scanning in a forked process so that the user
  # does not have to wait.
  return if !$force && fork;
  require LWP::UserAgent;
  my @ports = qw/23 80 81 1080 3128 8080 8081 scx-proxy dproxy sdproxy
		 funkproxy dpi-proxy proxy-gateway ace-proxy plgproxy
		 csvr-proxy flamenco-proxy awg-proxy trnsprntproxy
		 castorproxy ttlpriceproxy privoxy ezproxy ezproxy-2/;
  my $browser = LWP::UserAgent->new(
				    timeout =>10,
				    max_size =>2048,
				    requests_redirectable => []
				   );
  foreach my $port (@ports) {
    $browser->proxy("http","http://$ip:".$port);
    my $response = $browser->head("$SiteBase$ScriptName?action=$SelfBan");
    last unless defined $response;
    last unless $response->is_error;
  }
  # Now update the list
  $proxy{$ip} = $Now;
  my $data = '';
  foreach (keys %proxy) {
    $data .= $_ . ' ' . $proxy{$_} . "\n";
  }
  WriteStringToFile($OpenProxies, $data);
  exit unless $force; # exit if we're in the fork
}
