# Copyright (C) 2020  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2020  Daniel MacKay <daniel@bonmot.ca>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('grep-filtered.pl', 'Grep Filtered');

our ($PageDir);
our ($UseGrep);

$UseGrep = 1;

*OldGrepFiltered = \&Filtered;
*Filtered = \&NewGrepFiltered;

sub NewGrepFiltered {
  my ($string, @pages) = @_;
  my @pages = OldGrepFiltered(@_);
  my $regexp = SearchRegexp($string);
  return @pages unless GetParam('grep', $UseGrep) and $regexp;
  my @result = grep(/$regexp/i, @pages); # search parameter for page titles
  my %found = map {$_ => 1} @result;
  $regexp =~ s/\\n(\)*)$/\$$1/g; # sometimes \n can be replaced with $
  $regexp =~ s/([?+{|()])/\\$1/g; # basic regular expressions from man grep
  # if we know of any remaining grep incompatibilities we should
  # return @pages here!
  $regexp = quotemeta($regexp);
    open(F, '-|:encoding(UTF-8)', "find $PageDir -type f -print0 | xargs -0 -n10 -P4 grep --ignore-case -l '$regexp'") ;
  while (<F>) {
    my ($pageName) = m/.*\/(.*)\.pg$/ ;
    push(@result, $pageName) if not $found{$pageName};
  }  close(F);
  return sort @result;
}
