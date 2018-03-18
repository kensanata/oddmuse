#! /usr/bin/perl -w

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

sub EncodePage {
  my @data = @_;
  my $result = '';
  $result .= (shift @data) . ': ' . EscapeNewlines(shift @data) . "\n" while (@data);
  return $result;
}

sub EscapeNewlines {
  $_[0] =~ s/\n/\n\t/g;   # modify original instead of copying
  return $_[0];
}

sub main {
  die "There is no temp directory, here.\n"
      . "Perhaps this isn't an Oddmuse data directory?\n"
      unless -d 'temp';
  die "The main lock already exists in the temp directory.\n"
      if -d "temp/lockmain";
  mkdir "temp/lockmain" or die "Cannot create main lock in temp: $!\n";
  local $/ = undef;   # Read complete files
  foreach my $dir (qw/keep page/) {
    warn "Did not find the $dir directory.\n" unless -d $dir;
  }
  # include dotfiles!
  my $t = 0;
  my $n = 0;
  foreach my $file (glob("page/*.pg page/.*.pg"),
		    glob("keep/*/*.kp keep/.*.kp")) {
    $t++;
    open(my $fh, '<', $file) or die "Cannot read $file file: $!\n";
    my $data = <$fh>;
    close($fh);
    next unless $data;
    my %result = ParseData($data);
    if (exists($result{host}) or exists($result{ip})) {
      delete($result{host});
      delete($result{ip});
      open($fh,'>', "$file~") or die "Cannot $file~: $!\n";
      print $fh EncodePage(%result);
      close($fh);
      rename("$file~", $file) or die "Cannot rename $file~ to $file: $!\n";
      $n++;
    }
  }
  rmdir "temp/lockmain" or die "Cannot remove main lock: $!\n";
  print "I looked at $t files and found $n host or ip keys which I removed.\n";
}

if (@ARGV) {
  print qq{
Usage: $0 [--page DIR]

Goes through the wiki and removes the hostname or IP number from page and
keep files. Make a backup before running this script! Run this script in
your data directory.
}
} else {
  main ();
}
