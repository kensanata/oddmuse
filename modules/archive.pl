# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: archive.pl,v 1.4 2007/07/04 20:14:44 as Exp $</p>';

*OldArchiveGetHeader = *GetHeader;
*GetHeader = *NewArchiveGetHeader;

# this assumes that *all* calls to GetHeader will print!
sub NewArchiveGetHeader {
  my ($id) = @_;
  print OldArchiveGetHeader(@_);
  my %dates = ();
  for (AllPagesList()) {
    $dates{$1}++ if /^(\d\d\d\d-\d\d)-\d\d/;
  }
  print $q->div({-class=>'archive'},
		$q->p($q->span(T('Archive:')),
		      map {
			$key = $_;
			my ($year, $month) = split(/-/, $key);
			if (defined(&month_name)) {
			  ScriptLink('action=collect;match=' . UrlEncode("^$year-$month"),
				     month_name($month) . " $year ($dates{$key})");
			} else {
			  ScriptLink('action=index;match=' . UrlEncode("^$year-$month"),
				     "$year-$month ($dates{$key})");
			}
		      } sort { $b <=> $a } keys %dates));
  return '';
}
