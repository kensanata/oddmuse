# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

=head1 Preview Extension

This module allows you to preview changes in HTML output. Oddmuse keeps a cache
of the HTML produced for each wiki page. If you install new modules, the HTML
produced for a page can change, but visitors will not see the new HTML because
the cache still contains the old HTML. Now you have two options: 1. clear the
HTML cache (Oddmuse will regenerate it as visitors look at the old pages), or 2.
edit each page in order to regenerate the HTML cache. What happens in practice
is that you add new modules and you aren't sure whether this breaks old pages
and so you do don't dare clear the HTML cache. Let sleeping dogs lie.

The Preview Extension produces a list of all the pages where the cached HTML
differs from the HTML produced by the current set of modules. If you agree with
the new HTML, feel free to clear the HTML cache. That's the point of this
extension.

=cut
    
our ($q, %Action, $UseCache);

AddModuleDescription('preview.pl', 'Preview Extension');

$Action{preview} = \&DoPreview;

sub DoPreview {
  print GetHeader('', T('Pages with changed HTML'));
  print $q->start_div({-class=>'content preview'}), $q->start_p();
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    my $cache = ToString(\&PrintPageHtml);
    local $UseCache = 0;
    my $html = ToString(\&PrintPageHtml);
    if ($cache ne $html) {
      print GetPageLink($id), ' ',
      ScriptLink('action=browse;id=$id;cache=0', T('Preview')),
      $q->br();
    }
  }
  print $q->end_p(), $q->end_div();
  PrintFooter();
}
