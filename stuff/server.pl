#!/bin/env perl
{
  package Oddmuse::Server;

  use HTTP::Server::Simple::CGI;
  use base qw(HTTP::Server::Simple::CGI);

  my $wiki = $ARGV[0];
  my $port = $ARGV[1]||'8080';
  my $dir  = $ARGV[2];

  die <<'EOT' unless $wiki;
Usage: perl server.pl WIKI [PORT [DIR]]

Example: perl server.pl wiki.pl 8080 ~/src/oddmuse/test-data

You need to provide the Oddmuse wiki script on the command line. If you provide
a data directory on the command line, this will override the WikiDataDir
environment variable. If neither is set, /tmp will be used.

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
perl stuff/server.pl wiki.pl &
SERVER=$!
sleep 1
w3m http://localhost:8080/
kill $!

This will run the server exactly once, allow you to browse the site using w3m,
and when you're done, it'll kill the server for you.

EOT

  $ENV{WikiDataDir} = $dir if $dir;

  $OddMuse::RunCGI = 0;
  do $wiki;
  
  sub handle_request {
    my $self = shift;
    my $cgi  = shift;
    wiki($cgi);
  }

  sub wiki {
    package OddMuse;
    $q = shift;
    DoWikiRequest();
  }
}

# start the server
my $pid = Oddmuse::Server->new($port)->run();
