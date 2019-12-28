#!/usr/bin/env perl
# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

# What is this?
# =============
#
# This is a script that will server a wiki using a web server written in Perl,
# without a fancy framework like Mojolicious. Instead, it uses
# HTTP::Server::Simple::CGI.
#
# A simple usecase would be that you have had a wiki running years ago but then
# you forgot all about it and your Apache config no longer works and who knows
# how the system Perl is doing. So check out the data dir and notice that the
# files belong to a user called _www... And so you run the following:
#
# sudo -u _www perl stuff/server.pl ./wiki.pl 3000 \
#                   /Users/alex/WebServer/Oddmuse
#
# Your old wiki is served on localhost:3000 for you to examine.

my $wiki = $ARGV[0] || './wiki.pl';
my $port = $ARGV[1] || 8080;
my $dir  = $ARGV[2];
$ENV{WikiDataDir} = $dir if $dir;

{
  package Oddmuse::Server;

  use HTTP::Server::Simple::CGI;
  use base qw(HTTP::Server::Simple::CGI);

  $OddMuse::RunCGI = 0;
  do $wiki; # load just once

  sub handle_request {
    my $self = shift;

    package OddMuse;
    $q = shift;

    # NPH, or "no-parsed-header", scripts bypass the server completely by
    # sending the complete HTTP header directly to the browser.
    $q->nph(1);

    DoWikiRequest();
  }
}

die <<'EOT' unless -f $wiki;
Usage: perl server.pl [WIKI [PORT [DIR]]]

Example: perl server.pl ./wiki.pl 8080 ~/src/oddmuse/test-data

You may provide the Oddmuse wiki script on the command line. If you do not
provide it, WIKI will default to './wiki.pl'.

You may provide a port number on the command line. If you do not provide it,
PORT will default to 8080.

You may provide a data directory on the command line. It will be used to set the
environment variable 'WikiDataDir'. If it is not not set, Oddmuse will default
to '/tmp/oddmuse'.

A simple test setup would be the following shell script:

#/bin/sh
if test -z "$WikiDataDir"; then
    export WikiDataDir=/tmp/oddmuse
fi
mkdir -p "$WikiDataDir"
echo <<EOF > "$WikiDataDir/config"
$AdminPass = 'foo';
$ScriptName = 'http://localhost/';
EOF
perl stuff/server.pl ./wiki.pl &
SERVER=$!
sleep 1
w3m http://localhost:8080/
kill $!

This will run the server exactly once, allow you to browse the site using w3m,
and when you're done, it'll kill the server for you.

EOT

my $server = Oddmuse::Server->new($port);

# $server->background();
$server->run();
