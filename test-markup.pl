#!/usr/bin/perl

# Copyright (C) 2003  Alex Schroeder <alex@emacswiki.org>
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

# This program uses test-wrapper.el to run ApplyRules,
# because ApplyRules prints the result to stdout.

my ($passed, $failed) = (0, 0);
my $resultfile = "/tmp/test-markup-result-$$";
undef $/;

### SIMPLE MARKUP TESTS

%Test = split('\n',<<EOT);
ordinary text
ordinary text
WikiWord
WikiWord<a href="test-wrapper.pl?action=edit&amp;id=WikiWord">?</a>
EOT

foreach my $input (keys %Test) {
  open(F,"|perl test-wrapper.pl > $resultfile");
  print F $input;
  close F;
  open(F,$resultfile);
  $output = <F>;
  close F;
  if ($output eq $Test{$input}) {
    $passed++;
  } else {
    print $input, ' -> ', $output, ' instead of ', $Test{$input}, "\n";
    $failed++;
  }
}

### END OF TESTS

print "$passed passed, $failed failed.\n";
