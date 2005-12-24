#! /usr/bin/perl

# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

# include dotfiles!
foreach my $file (glob("$PageDir/*/*.pg $PageDir/*/.*.pg")) {
  next unless $file =~ m|/.*/(.+)\.pg$|;
  my $page = $1;
  mkdir($RawDir) or die "Cannot create $RawDir directory: $!" unless -d $RawDir;
  open(F, $file) or die "Cannot read $page file: $!";
  my $data = <F>;
  close(F);
  my %result = ParseData($data);
  open(F,"> $RawDir/$page") or die "Cannot write $page raw file: $!";
  print F $result{text};
  close(F);
  utime $result{text}, $result{ts}, "$RawDir/$page"; # touch file
};
