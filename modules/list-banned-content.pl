# Copyright (C) 2012  Alex Schroeder <alex@gnu.org>
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

AddModuleDescripton('list-banned-content.pl');

$Action{'list-banned-content'} = \&DoListBannedContent;

sub DoListBannedContent {
  print GetHeader('', T('Banned Content'), '');
  my @pages = AllPagesList();
  my %url_regexps;
  my %text_regexps;
  foreach (split(/\n/, GetPageContent($BannedContent))) {
    next unless m/^\s*([^#]+?)\s*(#\s*(\d\d\d\d-\d\d-\d\d\s*)?(.*))?$/;
    $url_regexps{qr($1)} = $4;
  }
  foreach (split(/\n/, GetPageContent($BannedRegexps))) {
    next unless m/^\s*([^#]+?)\s*(#\s*(\d\d\d\d-\d\d-\d\d\s*)?(.*))?$/;
    $text_regexps{qr($1)} = $4;
  }
  print '<div class="content banned"><p>';
  print $BannedContent . ': ' . scalar(keys(%url_regexps)) . $q->br() . "\n";
  print $BannedRegexps . ': ' . scalar(keys(%text_regexps)) . $q->br() . "\n";
 PAGE: foreach my $id (@pages) {
    OpenPage($id);
    my @urls = $str =~ /$FullUrlPattern/go;
    foreach my $url (@urls) {
      foreach my $re (keys %url_regexps) {
	if ($url =~ $re) {
	  print GetPageLink($id) . ': '
	    . Tss('Rule "%1" matched "%2" on this page.', $re, $url) . ' '
	      . ($url_regexps{$re}
		 ? Ts('Reason: %s.', $url_regexps{$re})
		 : T('Reason unknown.')) . $q->br() . "\n";
	  next PAGE;
	}
      }
    }
    foreach my $re (keys %text_regexps) {
      if ($Page{text} =~ $re) {
	print GetPageLink($id) . ': '
	  . Tss('Rule "%1" matched on this page.', $re) . ' '
	    . ($text_regexps{$re}
	       ? Ts('Reason: %s.', $text_regexps{$re})
	       : T('Reason unknown.')) . $q->br() . "\n";
	next PAGE;
      }
    }
  }
  print '</p></div>';
  PrintFooter();
}
