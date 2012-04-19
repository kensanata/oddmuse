# Copyright (C) 2004, 2005  Fletcher T. Penney <fletcher@freeshell.org>
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/aawrapperdiv.pl">aawrapperdiv.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/WrapperDiv_Module">WrapperDiv Module</a></p>';


*OldGetHeader = *GetHeader;
*GetHeader = *WrapperGetHeader;

sub WrapperGetHeader {
	my ($id, $title, $oldId, $nocache, $status) = @_;
	my $result = OldGetHeader ($id, $title, $oldId, $nocache, $status);
	$result .= $q->start_div({-class=>'wrapper'});
}

*OldPrintFooter = *PrintFooter;
*PrintFooter = *WrapperPrintFooter;

sub WrapperPrintFooter {
	my ($id, $rev, $comment) = @_;
	print $q->start_div({-class=>'wrapper close'});
	print $q->end_div(), $q->end_div();
	OldPrintFooter($id, $rev, $comment);
}



