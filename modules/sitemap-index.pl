# Copyright (C) 2005  Fletcher T. Penney <http://fletcher.freeshell.org/>
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

# Create a plain text listing of all pages in your wiki

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/sitemap-index.pl">sitemap-index.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Sitemap-index_Extension">Sitemap-index Extension</a></p>';

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
