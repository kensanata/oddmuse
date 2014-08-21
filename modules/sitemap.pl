# Copyright (C) 2005, 2008  Alex Schroeder <alex@gnu.org>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

AddModuleDescripton('sitemap.pl', 'Sitemap Extension');

$Action{'sitemap'} = \&DoSitemap;

sub DoSitemap {
  print GetHttpHeader('application/rss+xml');
  print qq{<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">};
  foreach my $id (AllPagesList()) {
    my $url = ScriptUrl($id);
    print qq{
<url><loc>$url</loc></url>};
  }
  print qq{
</urlset>
};
}
