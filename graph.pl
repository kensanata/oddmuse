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
#
#
# Usage: perl graph.pl URL StartPage depth breadth stop-regexp
# All arguments are optional.
#
# Defaults:
# URL         http://www.emacswiki.org/cgi-bin/wiki?action=links;exists=1;embed=1
# StartPage   none
# Depth       2
# Breadth     4
# Stop-Regexp ^(Category|SiteMap)
#
# The HTML data is cached.  From then on the URL parameter has no effect.
# To refresh the cache, delete the 'link.html' file.
#
# Breadth selects a number of children to include.  These are sorted by
# number of incoming links.
#
$uri = $ARGV[0];
$uri = "http://www.emacswiki.org/cgi-bin/wiki?action=links;exists=1;embed=1" unless $uri;
$start = $ARGV[1];
$depth = $ARGV[2];
$depth = 2 unless $depth;
$breadth = $ARGV[3];
$breadth = 4 unless $breadth;
$stop = $ARGV[4];
$stop = "^(Category|SiteMap)" unless $stop;
if (-f 'links.html') {
  print "Reusing links.html -- delete it if you want a fresh one.\n";
} else {
  print "Downloading links.html and saving for reuse.\n";
  $command = "wget -O links.html $uri";
  print "Using $command\n";
  system(split(/ /, $command)) == 0 or die "Cannot run wget\n";
}
undef $/;
open(F,'links.html') or warn "Cannot read links.html\n";
print "Reading links.html...\n";
$_ = <F>;
close(F);
print "Munging...\n";
@temp = split(m|>([^<>]+?)</a>: |);
shift @temp; # remove crud at the beginning
while ($key = shift @temp) {
  $_ = shift @temp;
  my @links = ();
  while (/>([^ ][^<>]+?)</g) {
    push @links, $1;
  }
  $page{$key} = \@links; # store list as reference to the list
}
print "Scoring...\n";
foreach $page (sort keys %page) {
  $linkref = $page{$page};
  foreach $target (sort @$linkref) {
    $score{$target}++;
  }
}
open(F,'>links.dot') or warn "Cannot write links.dot\n";
print "Writing links.dot...\n";
print F "digraph links {\n";
if ($start) {
  print "Starting with $start...\n";
  $count = 0;
  @pages = ($start);
  while ($count++ < $depth) {
    @current = @pages;
    foreach (@pages) { $done{$_} = 1; }
    @pages = ();
    foreach $page (@current) {
      $linkref = $page{$page};
      @links = @$linkref;
      @links = sort {$score{$a} <=> $score{$b}} @links; # only take pages with highest score
      @links = @links[0..$breadth-1] if $#links >= $breadth;
      next if $stop and eval "$page =~ /$stop/"; # no children for stop pages
      foreach $target (sort @links) {
	push(@pages, $target) unless $done{$target}; # don't cycle
	print F "\"$page\" -> \"$target\"\n";
      }
    }
  }
} else {
  print "Using all pages...\n";
  foreach $page (sort keys %page) {
    $linkref = $page{$page};
    foreach $target (sort @$linkref) {
      print F "\"$page\" -> \"$target\"\n";
    }
  }
}
print F "}\n";
close(F);
print "Done.\n";
