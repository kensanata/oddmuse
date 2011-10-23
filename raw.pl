#! /usr/bin/perl -w

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

sub main {
  my ($regexp, $PageDir, $RawDir) = @_;
  # include dotfiles!
  local $/ = undef;   # Read complete files
  foreach my $file (glob("$PageDir/*/*.pg $PageDir/*/.*.pg")) {
    next unless $file =~ m|/.*/(.+)\.pg$|;
    my $page = $1;
    next if $regexp && $page !~ m|$regexp|o;
    mkdir($RawDir) or die "Cannot create $RawDir directory: $!"
      unless -d $RawDir;
    open(F, $file) or die "Cannot read $page file: $!";
    my $data = <F>;
    close(F);
    my $ts = (stat("$RawDir/$page"))[9];
    my %result = ParseData($data);
    if ($ts && $ts == $result{ts}) {
      print "skipping $page because it is up to date\n" if $verbose;
    } else {
      print "writing $page because $ts != $result{ts}\n" if $verbose;
      open(F,"> $RawDir/$page") or die "Cannot write $page raw file: $!";
      print F $result{text};
      close(F);
      utime $result{ts}, $result{ts}, "$RawDir/$page"; # touch file
    }
  }
}

use Getopt::Long;
my $regexp = undef;
my $page = 'page';
my $dir = 'raw';
GetOptions ("regexp=s" => \$regexp,
	    "page=s"   => \$page,
	    "dir=s"    => \$dir,
	    "help"     => \$help);

if ($help) {
  print qq{
Usage: $0 [--regexp REGEXP] [--page DIR] [--dir DIR]

Writes the raw wiki text into plain text files.

--regexp selects a subsets of pages whose names match the regular
  expression. Note that spaces have been translated to underscores.

--page designates the page directory. By default this is 'page' in the
  current directory. If you run this script in your data directory,
  the default should be fine.

--dir designates an output directory. By default this is 'raw' in the
  current directory.

Example: $0 --regexp '\\.el\$' --dir elisp
}
} else {
  main ($regexp, $page, $dir);
}
