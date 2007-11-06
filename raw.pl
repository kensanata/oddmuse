#! /usr/bin/perl

# Copyright (C) 2005, 2007  Alex Schroeder <alex@emacswiki.org>
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

sub ParseData {
  my $data = shift;
  my %result;
  while ($data =~ /(\S+?): (.*?)(?=\n[^ \t]|\Z)/sg) {
    my ($key, $value) = ($1, $2);
    $value =~ s/\n\t/\n/g;
    $result{$key} = $value;
  }
  return %result;
}

my $PageDir = 'page';
my $RawDir  = 'raw';
local $/ = undef;   # Read complete files

my $regexp = $ARGV[0];

# include dotfiles!
foreach my $file (glob("$PageDir/*/*.pg $PageDir/*/.*.pg")) {
  next unless $file =~ m|/.*/(.+)\.pg$|;
  my $page = $1;
  next if $regexp && $page !~ m|$regexp|o;
  mkdir($RawDir) or die "Cannot create $RawDir directory: $!" unless -d $RawDir;
  open(F, $file) or die "Cannot read $page file: $!";
  my $data = <F>;
  close(F);
  my $ts = (stat("$RawDir/$page"))[9];
  my %result = ParseData($data);
  if ($ts == $result{ts}) {
    print "skipping $page because it is up to date\n" if $verbose;
  } else {
    print "writing $page because $ts != $result{ts}\n" if $verbose;
    open(F,"> $RawDir/$page") or die "Cannot write $page raw file: $!";
    print F $result{text};
    close(F);
    utime $result{ts}, $result{ts}, "$RawDir/$page"; # touch file
  }
};
