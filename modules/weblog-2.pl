# Copyright (C) 2004–2014  Alex Schroeder <alex@gnu.org>
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

use strict;
use v5.10;

use Time::ParseDate;

AddModuleDescription('weblog-2.pl', 'Complex Weblog Extension');

our ($q, @MyInitVariables, @UserGotoBarPages);

push(@MyInitVariables, \&WebLog2Init);

sub WebLog2Init {
  my $id = GetId();
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime; # CalcDay uses gmtime!
  my $today = sprintf('%4d-%02d-%02d', $year + 1900, $mon + 1, $mday);
  my ($current) = ($id =~ m|^(\d\d\d\d-\d\d-\d\d)|);
  if ($current and $current ne $today) {
    my $time = parsedate($current, GMT => 1);
    ($sec,$min,$hour,$mday,$mon,$year) = localtime($time - 60*60*24);
    my $previous = sprintf("%4d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    ($sec,$min,$hour,$mday,$mon,$year) = localtime($time + 60*60*24);
    my $next = sprintf("%4d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    push(@UserGotoBarPages,$next) unless grep(/^$next$/, @UserGotoBarPages);
    push(@UserGotoBarPages,$current) unless grep(/^$current$/, @UserGotoBarPages);
    push(@UserGotoBarPages,$previous) unless grep(/^$previous$/, @UserGotoBarPages);
  }
}
