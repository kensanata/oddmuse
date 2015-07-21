#! /usr/bin/perl
# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

package OddMuse;

my $dir = '/var/www/wiki'; # absolute path to the file cache
my $origname = '/wiki'; # relative url to the file cache, with trailing slash
my $script = '/usr/lib/cgi-bin/wiki.pl'; # absolute path to the wiki script
my $name = '/cgi-bin/wiki.pl'; # relative url to the wiki script
my @path = split(/\//, $ENV{REDIRECT_URL});
my $file = $path[$#path];

# for dynamic pages
use vars qw($NotFoundHandlerExceptionsPage);
$NotFoundHandlerExceptionsPage = 'NoCachePages';
$RunCGI = 0;
do $script;
Init();

# call the wiki for the page missing in the cache.  first set up CGI
# environment -- see http://localhost/cgi-bin/printenv.  then call the
# script and read output from the pipe.

local $/;
$ENV{REQUEST_METHOD}="GET";
$ENV{QUERY_STRING}=$file;
$ENV{SCRIPT_FILENAME}=$script;
$ENV{SCRIPT_NAME}=$name;
$ENV{REQUEST_URI}=$origname;
# print "Content-Type: text/plain\r\n\r\n";
# print "$script $file\n";
open(F, "$script |") || print STDERR "can't run $script: $!\n";
my $data = <F>;
close(F);

# print data to stdout and write a copy without headers into the cache
# if the script didn't print a Status (since the default is "200 Ok").

print $data;
$data =~ /^Status: ([1-9][0-9][0-9])/;
my $status = $1;
$data =~ /((.+:.*\n)*)/;
my $header = $1;
# print "<pre>$header</pre>";
if (not $status) { # ie. 200
  my %skip = ();
  foreach (split(/\n/, GetPageContent($NotFoundHandlerExceptionsPage))) {
    if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
      $skip{$1} = 1;
    }
  }
  if (not $skip{$file}) {
    $data =~ s/^(.*\r\n)+//; # strip header
    open(G, "> $dir/$file") || print STDERR "can't write $dir/$file: $!\n";
    print G $data;
    close(G);
  }
}

1;

# cache cleanup has to hook into the wiki!
