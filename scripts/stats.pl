#! /usr/bin/perl -w

# Copyright (C) 2005, 2007, 2021  Alex Schroeder <alex@gnu.org>
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

use Modern::Perl;

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
  my ($PageDir) = @_;
  my $pages = 0;
  my $texts = 0;
  my $redirects = 0;
  my $files = 0;
  my $big = 0;
  # include dotfiles!
  local $/ = undef;   # Read complete files
  say "Reading files...";
  my @files = glob("$PageDir/*.pg $PageDir/.*.pg");
  my $n = @files;
  local $| = 1; # flush!
  foreach my $file (@files) {
    if (not --$n % 10) {
      printf("\r%06d files to go", $n);
    }
    next unless $file =~ m|.*/(.+)\.pg$|;
    my $page = $1;
    open(F, $file) or die "Cannot read $page file: $!";
    my $data = <F>;
    close(F);
    my %result = ParseData($data);
    $pages++;
    if ($result{text} =~ /^#FILE /) {
      $files++;
    } elsif ($result{text} =~ /^#REDIRECT /) {
      $redirects++;
    } else {
      $texts++;
      $big++ if length($result{text}) > 15000;
    }
  }
  printf("\r%06d files to go\n", 0);
  printf("Pages:    %7d\n", $pages);
  printf("Files:    %7d\n", $files);
  printf("Redirects: %6d\n", $redirects);
  printf("Texts:    %7d\n", $texts);
  printf("Big:      %7d\n", $big);
}

use Getopt::Long;
my $regexp = undef;
my $page = 'page';
my $help;
GetOptions ("page=s"   => \$page,
	    "help"     => \$help);

if ($help) {
  print qq{
Usage: $0 [--page DIR]

Prints some stats about the pages in DIR.

--page designates the page directory. By default this is 'page' in the
  current directory. If you run this script in your data directory,
  the default should be fine.
}
} else {
  main ($page);
}
