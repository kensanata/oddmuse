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

my $LinkPattern = '(\p{Uppercase}+\p{Lowercase}+\p{Uppercase}\p{Alphabetic}*)';
my $FreeLinkPattern = "([-,.()'%&?;<> _1-9A-Za-z\x{0080}-\x{fffd}]|[-,.()'%&?;<> _0-9A-Za-z\x{0080}-\x{fffd}][-,.()'%&?;<> _0-9A-Za-z\x{0080}-\x{fffd}]+)";
my $UrlProtocols = 'http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|prospero|telnet|gopher|irc|feed';
my $UrlChars = '[-a-zA-Z0-9/@=+$_~*.,;:?!\'"()&#%]'; # see RFC 2396
my $FullUrlPattern="((?:$UrlProtocols):$UrlChars+)"; # when used in square brackets

# either a single letter, or a string that begins with a single letter and ends with a non-space
my $words = '([A-Za-z\x{0080}-\x{fffd}](?:[-%.,:;\'"!?0-9 A-Za-z\x{0080}-\x{fffd}]*?[-%.,:;\'"!?0-9A-Za-z\x{0080}-\x{fffd}])?)';
# zero-width assertion to prevent km/h from counting
my $nowordstart = '(?:(?<=[^-0-9A-Za-z\x{0080}-\x{fffd}])|^)';
# zero-width look-ahead assertion to prevent km/h from counting
my $nowordend = '(?=[^-0-9A-Za-z\x{0080}-\x{fffd}]|$)';

my $IrcNickRegexp = qr{[]a-zA-Z^[;\\`_{}|][]^[;\\`_{}|a-zA-Z0-9-]*};

sub FreeToNormal {    # trim all spaces and convert them to underlines
  my $id = shift;
  return '' unless $id;
  $id =~ s/ /_/g;
  $id =~ s/__+/_/g;
  $id =~ s/^_//;
  $id =~ s/_$//;
  return $id;
}

sub parse_local_names {
  my $filename = shift;
  print "Reading $filename\n";
  open(my $fh, '<:utf8', $filename) or die "Cannot read $filename: $!";
  my $data = <$fh>;
  close($fh);
  print "Parsing $filename\n";
  my %names = ();
  while ($data =~ m/\[$FullUrlPattern\s+([^\]]+?)\]/g) {
    my ($page, $url) = ($2, $1);
    my $id = FreeToNormal($page);
    $names{$id} = $url;
  }
  return \%names;
}

sub write_file {
  my ($file, $data) = @_;
  return unless $data;
  open(my $fh, '>:utf8', $file) or die "Cannot write $file: $!";
  print $fh $data;
  close($fh);
}  

sub replacement {
  my ($names, $id, $pos, @no_go) = @_;

  while (@no_go) {
    my $first = shift @no_go;
    print "Is $pos between " . $first->[0] . " and " . $first->[1] . "?\n" if $verbose;
    return $id if $pos >= $first->[0] and $pos <= $first->[1];
  }

  return "[[$id]]" if exists $index{$id}; # local page exists
  return $id unless $names->{$id};
  return '[' . $names->{$id} . ' ' . $id . ']';
}

sub translate_file {
  my ($names, $data) = @_;
  my @no_go = ();

  while ($data =~ /( <nowiki>.*?<\/nowiki>
                   | <code>.*?<\/code>
                   | ^ <pre> (.*\n)+ <\/pre>
                   | ^ {{{ (.*\n)+ }}}
                   | ${nowordstart} \* ${words} \* ${nowordend}
                   | ${nowordstart} \/ ${words} \/ ${nowordend}
                   | ${nowordstart} \_ ${words} \_ ${nowordend}
                   | ${nowordstart} \! ${words} \! ${nowordend}
                   | \[\[ $FreeLinkPattern .*? \]\]
                   | \[ $FullUrlPattern \s+ [^\]]+? \]
                   | ^( \h+.+\n )+
                   | ^(?: \[? \d\d?:\d\d (?:am|pm)?  \]? )? \s* < $IrcNickRegexp > )/gmx) {
    push @no_go, [pos($data) - length $1, pos($data)];
    print "no go from " . $no_go[-1]->[0] . ".." . $no_go[-1]->[1] . " for $1\n" if $verbose;
  }

  my $subs = $data =~ s/(?<![:![])\b$LinkPattern(?![:])/replacement($names, $1, pos($data), @no_go)/ge;
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
  my ($dir, $local_names) = @_;
  mkdir($dir . '-new') or die "Cannot create $dir-new: $!";
  my $names = parse_local_names("$dir/$local_names");
  print "Indexing files\n";
  foreach my $file (glob("$dir/.* $dir/*")) {
    next unless $file =~ /$dir\/(.+)/;
    my $id = $1;
    next if $id eq ".";
    next if $id eq "..";
    next if $id eq "$local_names";
    $index{$id} = 1;
  }
  print "Converting files\n";
  foreach my $id (sort keys %index) {
    # this is where you debug a particular page
    # $verbose = $id eq '2014-12-18_Emacs_Wiki_Migration';
    write_file("$dir-new/$id", translate_file($names, read_file("$dir/$id")));
  }
}

use Getopt::Long;

my $names = 'LocalNames';
my $dir = 'raw';
my $help = '';

GetOptions ("names=s"   => \$names,
	    "dir=s"    => \$dir,
	    "help"     => \$help);

if ($help) {
  print qq{
Usage: $0 [--dir=DIR] [--names=LocalNames]

You need to use the raw.pl script to create a directory full of raw
wiki text files.

--dir=DIR is where the raw wiki text files are. Default: raw. The
  converted files will be stored in DIR-new, ie. in raw-new by
  default.

--names=LocalNames is the page name with all the local names on
  it. Default: LocalNames

Example: $0 --dir=~/alexschroeder/raw --names=Names
}
} else {
  main ($dir, $names);
}
