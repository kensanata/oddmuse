#!/usr/bin/env perl
# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require './t/test.pl';
package OddMuse;
use Test::More;
use JSON;
use utf8;

add_module('common-markdown.pl');

sub load_tests {
  my $spec = "t/common-markdown-spec-0.28.json";
  open(my $fh, "<", $spec)
      or die "Cannot open $spec: $!";
  local $/ = undef;
  return decode_json <$fh>;
}

sub normalize {
  my $html = shift;
  $html =~ s/\n$//s;
  return $html;
}

my $tests = load_tests();

for my $test (@$tests) {
  my $name = $test->{example} . ". (" . $test->{section} . ")";
  my $input = $test->{markdown};
  my $output = apply_rules($input, 'p');
  my $correct = normalize($test->{html});
  is($output, $correct, $name);
}

done_testing();
