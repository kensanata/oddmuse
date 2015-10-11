#! /usr/bin/env perl

# This script only works with a version of Mojolicious::Plugin::CGI better than
# the official 0.23. One version would be my fork:
# https://github.com/kensanata/mojolicious-plugin-cgi

# If you use the fork, you might want to simply add its lib directory to your
# libraries instead of installing it?

# use lib '/Users/alex/src/mojolicious-plugin-cgi/lib';

use Mojolicious::Lite;

plugin CGI => {
  support_semicolon_in_query_string => 1,
};
 
plugin CGI => {
  route => '/wiki',
  script => 'wiki.pl',
  run => \&OddMuse::DoWikiRequest,
  before => sub {
    $OddMuse::RunCGI = 0;
    $OddMuse::DataDir = '/tmp/oddmuse';
    require 'wiki.pl' unless defined &OddMuse::DoWikiRequest;
  },
  env => {},
  errlog => 'wiki.log', # path to where STDERR from cgi script goes
};

get '/' => sub {
  my $self = shift;
  $self->redirect_to('/wiki');
};
 
app->start;
