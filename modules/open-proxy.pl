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

$ModulesDescription .= '<p>$Id: open-proxy.pl,v 1.1 2005/08/08 12:46:50 as Exp $</p>';

*OpenProxyOldDoEdit = *DoEdit;
*DoEdit = *OpenProxyNewDoEdit;

sub OpenProxyNewDoEdit {
  BanOpenProxy();
  OpenProxyOldDoEdit(@_);
}

sub BanOpenProxy {
    my ($force) = @_;

    my $ip = $ENV{REMOTE_ADDR};

    # Only check each IP address once a month
    my $checked = ReadFile("$DataDir/openproxy");
    my $checkCount = 0;
    my $appendChecked;
    while( $checked =~ s/^$ip (\d+)\n//mg ) {
        if( $Now - $1 < 60*60*24*30 ) {
            $checkCount++;
            $appendChecked.= "$ip $Now\n";
        }
    }
    $checked .= $appendChecked;
    return if $checkCount >= 3;

    $checked .= "$ip $Now\n";

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

    foreach my $port (@ports)
    {
        $browser->proxy("http","http://$ip:".$port);
        my $response = $browser->head("$SiteBase$ScriptName?action=$SelfBan");
        last unless defined $response;
        last unless $response->is_error;
    }

    WriteStringToFile("$DataDir/openproxy", $checked);

    exit unless $force;
}
