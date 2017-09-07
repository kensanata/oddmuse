#! /usr/bin/perl
# Copyright (C) 2015–2017  Alex Schroeder <alex@gnu.org>

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

AddModuleDescription('ditaa.pl', 'Ditaa for Diagrams');

our ($q, $bol, @MyRules, @KnownLocks, $TempDir);

push (@MyRules, \&DitaaRule);
push(@KnownLocks, 'diagram');

sub DitaaRule {
  if ($bol && m/\G&lt;diagram(\s+style=".*")?&gt;\n((.*\n)+)&lt;\/diagram&gt;/cg) {
    return "MIME::Base64 not installed" unless eval { require MIME::Base64; };
    my $style = $1;
    my $map = UnquoteHtml($2);
    RequestLockDir('diagram', undef, undef, 1);
    WriteStringToFile("$TempDir/diagram.txt", $map);
    $ENV{LANG}='en_US.UTF-8'; # Java needs Locale to match as well!
    my $output = `ditaa "$TempDir/diagram.txt" "$TempDir/diagram.png"`;
    my $image = '';
    # not UTF-8 layer!
    if (open(IN, '<', "$TempDir/diagram.png")) {
      local $/ = undef; # Read complete files
      $image = <IN>;
      close IN;
    }
    ReleaseLockDir('diagram');
    my $data = MIME::Base64::encode_base64($image);
    my $url = "data:image/png;base64,$data";
    return CloseHtmlEnvironments()
      . "<div$style>" . $q->img({-src=>$url, -alt=>$map}) . "</div>";
  }
  return undef;
}
