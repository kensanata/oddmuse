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

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use Encode;

sub unescape {
  my $str = shift;
  $str = decode('utf-8', join('', map { chr(hex($_)) } split(/%/, substr($str, 1))));
  return uc(join('', map { sprintf("%%%02x", ord($_)) } split(//, encode('latin-1', $str))));
}

sub translate {
  my $str = shift;
  $str =~ s/((%[0-9a-f][0-9a-f])+)/unescape($1)/eigo;
  return $str;
}

if (not param('url')) {
  print header(),
    start_html('UTF-8 to Latin-1 Escapes'),
    h1('UTF-8 to Latin-1 Escapes'),
    p('Translates URLs containing URL-encoded UTF-8 to ',
      'URLs  containing URL-encoded Latin-1 and redirects to it.'),
    start_form(-method=>'GET'),
    p('URL: ', textfield('url', '', 70)),
    p(submit()),
    end_form(),
    end_html();
  exit;
}

print CGI::redirect(translate(param('url')));

# Stuff for testing:

# print 'Communaut%C3%A9Crao', "\n";
# print translate('Communaut%C3%A9Crao'), "\n";
# print 'Communaut%E9Crao', "\n";

# perl latin-1.pl url=http://wiki.crao.net/index.php/Communaut%C3%A9Crao
