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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/weblog-2.pl">weblog-2.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Complex_Weblog_Extension">Complex Weblog Extension</a></p>';

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
