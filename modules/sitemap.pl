# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: sitemap.pl,v 1.1 2005/06/12 16:31:03 as Exp $</p>';

$Action{'sitemap'} = \&DoSitemap;

sub DoSitemap {
  UserIsAdminOrError();
  print GetHttpHeader('application/rss+xml');
  print qq{<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.google.com/schemas/sitemap/0.84"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.google.com/schemas/sitemap/0.84
	http://www.google.com/schemas/sitemap/0.84/sitemap.xsd">};
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    $id = UrlEncode($id);
    my $url = $UsePathInfo ? "$ScriptName/$id" :  "$ScriptName?$id";
    my $ts = TimeToW3($Page{ts});
    print qq{
  <url>
    <loc>$url</loc>
    <changefreq>always</changefreq>
    <lastmod>$ts</lastmod>
  </url>};
  }
  print qq{
</urlset>};
}
