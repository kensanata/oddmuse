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
$| = 1; # no output buffering

# Create temporary data directory as expected by the script
# and create a config file in this directory.

mkdir '/tmp/oddmuse';
open(F,'>/tmp/oddmuse/config');
close(F);
open(F,'>/tmp/oddmuse/intermap');
print F "OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n";
close(F);

### SIMPLE MARKUP TESTS

%Test = split('\n',<<EOT);
Foo::Bar
Foo::Bar
OddMuse
OddMuse<a href="test-wrapper.pl?action=edit&amp;id=OddMuse">?</a>
OddMuse:
OddMuse<a href="test-wrapper.pl?action=edit&amp;id=OddMuse">?</a>:
OddMuse:test
<a href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test">OddMuse:test</a>
WikiWord
WikiWord<a href="test-wrapper.pl?action=edit&amp;id=WikiWord">?</a>
WikiWord:
WikiWord<a href="test-wrapper.pl?action=edit&amp;id=WikiWord">?</a>:
ordinary text
ordinary text
EOT

foreach my $input (keys %Test) {
  print '.';
  open(F,"|perl test-wrapper.pl > $resultfile");
  print F $input;
  close F;
  open(F,$resultfile);
  $output = <F>;
  close F;
  if ($output eq $Test{$input}) {
    $passed++;
  } else {
    $failed++;
    print "\nTest ", $failed + $passed, ': "', $input, '" -> "', $output, '" instead of "', $Test{$input}, "\"\n";
  }
}

### END OF TESTS

print "\n";
print "$passed passed, $failed failed.\n";
