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
# URL         http://www.emacswiki.org/cgi-bin/wiki?action=links;exists=1;raw=1
# StartPage   none -- all other options only have effect if this one is set!
# Depth       2
# Breadth     4
# Stop-Regexp ^(Category|SiteMap)
#
# The HTML data is cached.  From then on the URL parameter has no effect.
# To refresh the cache, delete the 'graph.cache' file.
#
# Breadth selects a number of children to include.  These are sorted by
# number of incoming links.
#
# Example usage:
#   perl graph.pl -> download cache file and produce a graph.dot for the entire wiki
#   perl graph.pl cache AlexSchroeder -> from the cache, start with AlexSchroeder
#   springgraph < cache.dot > cache.png
#
$uri = $ARGV[0];
$uri = "http://www.emacswiki.org/cgi-bin/wiki?action=links;exists=1;raw=1" unless $uri;
$start = $ARGV[1];
$depth = $ARGV[2];
$depth = 2 unless $depth;
$breadth = $ARGV[3];
$breadth = 4 unless $breadth;
$stop = $ARGV[4];
$stop = "^(Category|SiteMap)" unless $stop;
if (-f 'graph.cache') {
  print "Reusing graph.cache -- delete it if you want a fresh one.\n";
} else {
  print "Downloading graph.cache and saving for reuse.\n";
  $command = "wget -O graph.cache $uri";
  print "Using $command\n";
  system(split(/ /, $command)) == 0 or die "Cannot run wget\n";
}

if (not $start) {
  open (F,'<graph.cache') or warn "Cannot read graph.cache\n";
  print "Reading graph.cache...\n";
  undef $/;
  $data = <F>;
  close (F);
  open (F,'>graph.dot') or warn "Cannot write graph.dot\n";
  print "Writing graph.dot...\n";
  print "Using all pages...\n";
  print F "digraph links {\n";
  print F $data;
  print F "}\n";
  close (F);
  exit;
}

open(F,'graph.cache') or warn "Cannot read graph.cache\n";
print "Reading graph.cache...\n";
while($_ = <F>) {
  if (m/^"(.*?)" -> "(.*?)"$/) {
    push (@{$page{$1}}, $2);
    $score{$2}++;
  }
}
close(F);
open(F,'>graph.dot') or warn "Cannot write graph.dot\n";
print "Writing graph.dot...\n";
print F "digraph links {\n";
print "Starting with $start...\n";
$count = 0;
@pages = ($start);
while ($count++ < $depth) {
  @current = @pages;
  foreach (@pages) {
    $done{$_} = 1;
  }
  @pages = ();
  foreach $page (@current) {
    @links = @{$page{$page}};
    @links = sort {$score{$a} <=> $score{$b}} @links; # only take pages with highest score
    @links = @links[0..$breadth-1] if $#links >= $breadth;
    next if $stop and eval "$page =~ /$stop/"; # no children for stop pages
    foreach $target (sort @links) {
      push(@pages, $target) unless $done{$target}; # don't cycle
      print F "\"$page\" -> \"$target\"\n";
    }
  }
}
print F "}\n";
close(F);
print "Done.\n";
