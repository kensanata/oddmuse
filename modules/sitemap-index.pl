# Copyright (C) 2005  Fletcher T. Penney <http://fletcher.freeshell.org/>
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

# Create a plain text listing of all pages in your wiki

use strict;
use v5.10;

AddModuleDescription('sitemap-index.pl', 'Sitemap-index Extension');

our (%Action, $ScriptName);

$Action{'sitemap-index'} = \&DoSiteMapIndex;

sub DoSiteMapIndex {
  # Basically, this is DoIndex with raw=1 and prepending the URL
  my @pages;
  push(@pages, AllPagesList());
  @pages = sort @pages;

  print GetHttpHeader('text/plain');
  foreach (@pages) {
    print $ScriptName, "/", $_, "\n";
  }
}
