#! /usr/bin/perl -w

# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
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

use utf8;
use strict;
use warnings;
undef $/; # slurp

my %index = ();
my $verbose = '';

sub write_file {
  my ($file, $data) = @_;
  return unless $data;
  open(my $fh, '>:utf8', $file) or die "Cannot write $file: $!";
  print $fh $data;
  close($fh);
}  

sub replacement_block {
  my ($block, $pos, @no_go) = @_;

  while (@no_go) {
    my $first = shift @no_go;
    print "Is $pos between " . $first->[0] . " and " . $first->[1] . "?\n" if $verbose;
    return $block if $pos >= $first->[0] and $pos <= $first->[1];
  }

  return "[quote]\n" . join("\n", split(/ \n :+ \h? /x, $block)) . "[/quote]\n";
}

sub replacement {
  my ($block, $tag, $pos, @no_go) = @_;

  while (@no_go) {
    my $first = shift @no_go;
    print "Is $pos between " . $first->[0] . " and " . $first->[1] . "?\n" if $verbose;
    return $block if $pos >= $first->[0] and $pos <= $first->[1];
  }

  return $tag . $block . $tag;
}

sub translate_file {
  my ($data) = @_;
  my @no_go = ();

  while ($data =~ /( <nowiki>.*?<\/nowiki>
                   | <code>.*?<\/code>
                   | ^ <pre> (.*\n)+ <\/pre>
                   | ^ {{{ (.*\n)+ }}} )/gmx) {
    push @no_go, [pos($data) - length $1, pos($data)];
    print "no go from " . $no_go[-1]->[0] . ".." . $no_go[-1]->[1] . " for $1\n" if $verbose;
  }

  # The problem is that these replacements don't adjust @no_go! Perhaps it is good enough?
  my $subs = '';
  $subs = $subs || $data =~ s/ ''' (.*?) ''' /replacement($1, '**', pos($data), @no_go)/gxe;
  $subs = $subs || $data =~ s/  '' (.*?) ''  /replacement($1, '\/\/', pos($data), @no_go)/gxe;
  $subs = $data =~ s/ ^ :+ \h? ( .* \n (?: .+ \n ) * ) /replacement_block($1, pos($data), @no_go)/gmxe;
  return $data if $subs;
}

sub read_file {
  my $file = shift;
  open(my $fh, '<:utf8', $file) or die "Cannot read $file: $!";
  my $data = <$fh>;
  close($fh);
  return $data;
}

sub main {
  my ($dir) = @_;
  mkdir($dir . '-new') or die "Cannot create $dir-new: $!";
  print "Indexing files\n";
  foreach my $file (glob("$dir/.* $dir/*")) {
    next unless $file =~ /$dir\/(.+)/;
    my $id = $1;
    next if $id eq ".";
    next if $id eq "..";
    $index{$id} = 1;
  }
  print "Converting files\n";
  foreach my $id (sort keys %index) {
    # this is where you debug a particular page
    # $verbose = $id eq '2014-12-18_Emacs_Wiki_Migration';
    write_file("$dir-new/$id", translate_file(read_file("$dir/$id")));
  }
}

use Getopt::Long;

my $dir = 'raw';
my $help = '';

GetOptions ("dir=s"    => \$dir,
	    "help"     => \$help);

if ($help) {
  print qq{
Usage: $0 [--dir=DIR]

You need to use the raw.pl script to create a directory full of raw
wiki text files.

--dir=DIR is where the raw wiki text files are. Default: raw. The
  converted files will be stored in DIR-new, ie. in raw-new by
  default.

Example: $0 --dir=~/alexschroeder/raw
}
} else {
  main ($dir);
}
