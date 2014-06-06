# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

$Action{upgrade} = \&DoUpgrade;

sub DoUpgrade {
  UserIsAdminOrError();
  RequestLockOrError();

  print GetHeader('', T('Upgrading Database')),
    $q->start_div({-class=>'content upgrade'});

  if (-e $IndexFile) {
    unlink $IndexFile;
  }

  print "<p>Renaming files...";

  for my $dir ($PageDir, $KeepDir, $RefererDir, $JoinerDir, $JoinerEmailDir) {
    next unless $dir;
    for my $old (bsd_glob("$dir/*/*", bsd_glob("$dir/*/.*"))) {
      next if $old eq '.' or $old eq '..';
      print "<br />\n$old";
      my $new = $old;
      $new =~ s!/([A-Z]|other)!!;
      if ($old eq $new) {
	print " does not fit the pattern!";
      } elsif (not rename $old, $new) {
	print " failed!";
      }
    }
  }
  ReleaseLockDir();
  print $q->end_p(), $q->end_div();
  PrintFooter();
}
