# Copyright (C) 2015  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
#
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 1;

use File::Basename;

add_module('load-lang.pl');
require("$ModuleDir/load-lang.pl");

my %choosable_translations = reverse %TranslationsLibrary;
my @missing = (); # missing in load-lang.pl

foreach (bsd_glob("modules/translations/*.p[ml]")) {
  my $filename = fileparse($_);
  next if exists $choosable_translations{$filename};
  next if $filename eq 'new-utf8.pl'; # placeholder
  next if $filename =~ /^month-names/; # month names are located in translations/ for whatever reason
  next if $filename =~ /^national-days/; # national days are located in translations/ for whatever reason
  push @missing, $_;
}

unless (ok(@missing == 0, 'All translations are listed')) {
  diag("$_ is not listed in load-lang.pl") for @missing;
}

# TODO test the module itself
