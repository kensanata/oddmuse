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

use vars qw($MonitorUser $MonitorPassword $MonitorHost
	    $MonitorFrom $MonitorTo $MonitorRegexp);

# example settings:
# $MonitorUser = 'oddmuse.wiki';
# $MonitorPassword = '***secret***';
# $MonitorHost = 'smpt.google.com';
# $MonitorFrom = 'oddmuse.wiki@gmail.com';
# $MonitorTo = 'kensanata@gmail.com';
# $MonitorRegexp = '.';

push(@MyInitVariables, \&MonitorInit);

sub MonitorLog {
  $Message .= $q->p(shift);
}

sub MonitorInit {
  $MonitorTo = $MonitorFrom unless $MonitorTo;
  if (!$MonitorUser or !$MonitorPassword
      or !$MonitorHost or !$MonitorFrom) {
    $Message .= $q->p('Monitor extension has been installed but not configured.');
  }
  if ($q->request_method() eq 'POST'
      && !$q->param('Preview')
      && $q->url =~ /$MonitorRegexp/) {
    eval {
      MonitorSend();
    };
    if ($@) {
      MonitorLog("monitor error: $@");
    }
  }
}

sub MonitorSend {
  # MonitorLog("monitor send");
  require File::Temp;
  require MIME::Entity;
  # MonitorLog("monitor require");
  my $fh = File::Temp->new(SUFFIX => '.html');
  my $home = ScriptLink(UrlEncode($HomePage), "$SiteName: $HomePage");
  print $fh qq(<p>Monitor mail from $home.</p><hr />)
    . $q->Dump();
  $fh->close;
  # MonitorLog("monitor file");
  my $mail = new MIME::Entity->build(To => $MonitorTo,
				     From => $MonitorFrom,
				     Subject => "Oddmuse Monitor",
				     Path => $fh,
				     Type=> "text/html");
  # MonitorLog("monitor mail");
  eval {
    require Net::SMTP::TLS;
    my $smtp = Net::SMTP::TLS->new($MonitorHost,
				   User => $MonitorUser,
				   Password => $MonitorPassword);
    $smtp->mail($MonitorFrom);
    $smtp->to($MonitorTo);
    $smtp->data;
    $smtp->datasend($mail->stringify);
    $smtp->dataend;
    $smtp->quit;
  };
  MonitorLog("monitor TSL error: $@") if $@;
  if ($@) {
    require Net::SMTP::SSL;
    my $smtp = Net::SMTP::SSL->new($MonitorHost, Port => 465);
    $smtp->auth($MonitorUser, $MonitorPassword);
    $smtp->mail($MonitorFrom);
    $smtp->to($MonitorTo);
    $smtp->data;
    $smtp->datasend($mail->stringify);
    $smtp->dataend;
    $smtp->quit;
  }
  MonitorLog("monitor SSL error: $@") if $@;
}
