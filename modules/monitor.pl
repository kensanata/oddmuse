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

package OddMuse;

use vars qw($MonitorUser $MonitorPassword $MonitorHost $MonitorRegexp);

push(@MyInitVariables, \&MonitorInit);

sub MonitorInit {
  if (!$MonitorUser or !$MonitorPassword or !$MonitorHost) {
    $Message .= $q->p('Monitor extension has been installed but not configured.');
  }
  MonitorSend() if $q->url() =~ /$MonitorRegexp/;
}

sub MonitorSend {
  my $fh = File::Temp->new(SUFFIX => '.html');
  my $home = ScriptLink(UrlEncode($HomePage), $HomePage);
  print $fh qq(<p>Monitor mail from <a href="$home">$SiteName:$HomePage</a>.</p><hr />)
    . $q->Dump();
  $fh->close;
  my $mail = new MIME::Entity->build(To => $MonitorUser,
				     From => $MonitorUser,
				     Subject => "Oddmuse Monitor",
				     Path => $fh,
				     Type=> "text/html");
  eval {
    require Net::SMTP::TLS;
    my $smtp = Net::SMTP::TLS->new($MonitorHost,
				   User => $MonitorUser,
				   Password => $MonitorPassword);
    $smtp->mail($MonitorUser);
    $smtp->to($MonitorUser);
    $smtp->data;
    $smtp->datasend($mail->stringify);
    $smtp->dataend;
    $smtp->quit;
  };
  if ($@) {
    require Net::SMTP::SSL;
    my $smtp = Net::SMTP::SSL->new($host, Port => 465);
    $smtp->auth($MonitorUser, $MonitorPassword);
    $smtp->mail($MonitorUser);
    $smtp->to($MonitorUser);
    $smtp->data;
    $smtp->datasend($mail->stringify);
    $smtp->dataend;
    $smtp->quit;
  }
}
