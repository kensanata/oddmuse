#! /usr/bin/env perl

use Mojolicious::Lite;

plugin CGI => {
  support_semicolon_in_query_string => 1,
};
 
plugin CGI => {
  route => '/wiki',
  script => 'wiki.pl',
  env => {},
  errlog => 'wiki.log', # path to where STDERR from cgi script goes
};

get '/' => sub {
  my $self = shift;
  $self->redirect_to('/wiki');
};
 
app->start;
