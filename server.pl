#!/usr/bin/env perl

# Copyright (C) 2015-2016  Alex Schroeder <alex@gnu.org>

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

package OddMuse;

our $RunCGI = 0;
do 'wiki.pl';

my $dir = $DataDir; # used for Mojolicious::Plugin::CGI setup

use Mojolicious::Lite;

plugin CGI => {
  support_semicolon_in_query_string => 1,
  route => '/wiki',
  run => \&OddMuse::DoWikiRequest,
  env => {},
  # path to where STDERR from cgi script goes
  errlog => "$dir/wiki.log",
};

get '/' => sub {
  my $self = shift;
  $self->redirect_to('/wiki');
};

app->start;
