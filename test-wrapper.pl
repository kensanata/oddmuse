#!/usr/bin/perl

# Copyright (C) 2003  Alex Schroeder <alex@emacswiki.org>
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

# This program reads the input from stdin, applies the markup rules,
# and prints the output to stdout.

package OddMuse;
$_ = 'nocgi';
do 'wiki.pl';

if ($UseConfig && (-f $ConfigFile)) {
  do $ConfigFile;
}
&InitLinkPatterns();
$q = new CGI;
$Now = time;
my @ScriptPath = split('/', $q->script_name());
$ScriptName = pop(@ScriptPath);
$IndexInit = 0;
$InterSiteInit = 0;
%InterSite = ();
$MainPage = '.';
$OpenPageName = '';

undef $/;

$input = <STDIN>;
&ApplyRules($input,1);
