# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

use Time::ParseDate;

$ModulesDescription .= '<p>$Id: weblog-2.pl,v 1.5 2005/01/06 11:35:04 as Exp $</p>';

push(@MyInitVariables, \&WebLog2Init);

sub WebLog2Init {
  my $id = join('_', $q->keywords);
  $id = $q->path_info() unless $id;
  my $current;
  ($current, $year, $mon, $mday) = ($id =~ m|^/?((\d\d\d\d)-(\d\d)-(\d\d))|);
  if ($current and $current ne $today) {
    my $time = parsedate($current, GMT => 1);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime($time - 60*60*24);
    my $previous = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime($time + 60*60*24);
    my $next = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    push(@UserGotoBarPages,$next) unless grep(/^$next$/, @UserGotoBarPages);
    push(@UserGotoBarPages,$current) unless grep(/^$current$/, @UserGotoBarPages);
    push(@UserGotoBarPages,$previous) unless grep(/^$previous$/, @UserGotoBarPages);
  }
}
