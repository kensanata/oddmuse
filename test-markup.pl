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
print F "\$NetworkFile = 1;\n";
close(F);
open(F,'>/tmp/oddmuse/intermap');
print F "OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n";
close(F);

### SIMPLE MARKUP TESTS

%Test = split('\n',<<'EOT');
ordinary text
ordinary text
WikiWord
WikiWord<a href="test-wrapper.pl?action=edit&amp;id=WikiWord">?</a>
WikiWord:
WikiWord<a href="test-wrapper.pl?action=edit&amp;id=WikiWord">?</a>:
OddMuse
OddMuse<a href="test-wrapper.pl?action=edit&amp;id=OddMuse">?</a>
OddMuse:
OddMuse<a href="test-wrapper.pl?action=edit&amp;id=OddMuse">?</a>:
OddMuse:test
<a href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test">OddMuse:test</a>
Foo::Bar
Foo::Bar
||one||
<table class="user"><tr><td>one</td></tr></table>
||one||two||three||\n||||one two||three||\n
<table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table>
http://www.emacswiki.org
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>
http://www.emacswiki.org/
<a href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>
http://www.emacswiki.org.
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>.
http://www.emacswiki.org,
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>,
http://www.emacswiki.org;
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>;
http://www.emacswiki.org!
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>!
http://www.emacswiki.org?
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>?
http://www.emacswiki.org/?
<a href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>?
"http://www.emacswiki.org".
"<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>".
http://www.emacswiki.org,
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>,
[http://www.emacswiki.org]
<a href="http://www.emacswiki.org">[1]</a>
[http://www.emacswiki.org] and [http://www.emacswiki.org]
<a href="http://www.emacswiki.org">[1]</a> and <a href="http://www.emacswiki.org">[2]</a>
[http://www.emacswiki.org],
<a href="http://www.emacswiki.org">[1]</a>,
[http://www.emacswiki.org and a label]
<a href="http://www.emacswiki.org">[and a label]</a>
[file://home/foo/tutorial.pdf local link]
<a href="file://home/foo/tutorial.pdf">[local link]</a>
file://home/foo/tutorial.pdf
<a href="file://home/foo/tutorial.pdf">file://home/foo/tutorial.pdf</a>
file:///home/foo/tutorial.pdf
file:///home/foo/tutorial.pdf
EOT

# Now translate embedded newlines (other backslashes remain untouched)
my %New;
foreach (keys %Test) {
  $Test{$_} =~ s/\\n/\n/g;
  my $new = $Test{$_};
  s/\\n/\n/g;
  $New{$_} = $new;
}

# Note that the order of tests is not specified!

foreach my $input (keys %New) {
  print '.';
  open(F,"|perl test-wrapper.pl > $resultfile");
  print F $input;
  close F;
  open(F,$resultfile);
  $output = <F>;
  close F;
  if ($output eq $New{$input}) {
    $passed++;
  } else {
    $failed++;
    print "\n\"", $input, '" -> "', $output, '" instead of "', $New{$input}, "\"\n";
  }
}

### END OF TESTS

print "\n";
print "$passed passed, $failed failed.\n";
