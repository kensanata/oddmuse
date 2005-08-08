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

$ModulesDescription .= '<p>$Id: self-ban.pl,v 1.1 2005/08/08 12:45:52 as Exp $</p>';

use vars qw($SelfBan);

$SelfBan = "xyzzy"; # change this from time to time in your config file

$Action{$SelfBan} = \&DoSelfBan;

sub DoSelfBan {
  my $date = &TimeToText($Now);
  my $str = '^' . quotemeta($ENV{REMOTE_ADDR});
  OpenPage($BannedHosts);
  Save ($BannedHosts, $Page{text} . "\n\nself-ban on $date\n $str",
	Ts("Self-ban by %s", $ENV{REMOTE_ADDR}), 1); # minor edit
  ReportError(T("You have banned your own IP."));
}
