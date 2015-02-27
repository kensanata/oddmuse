# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2008  flipflip

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package OddMuse;

AddModuleDescription('new-window.pl', 'New Window Links Extension');

# Opening links in new windows is evil
push(@MyRules, \&NewWindowLink);
sub NewWindowLink {
  # compare sub LinkRules in oddmuse.pl
  if ($BracketText && m/\G(\[new:$FullUrlPattern\s+([^\]]+?)\])/cog
      or m/\G(\[new:$FullUrlPattern\])/cog) {
    my ($url, $text) = ($2, $3);
    $url =~ /^($UrlProtocols)/;
    my $class = "url $1";      # get protocol (http, ftp, ...)
    $text = $url unless $text; # use url as link text if text empty
    $url = UnquoteHtml($url);  # quote special chars
    $class .= ' newwindow';    # add newwindow to class
    # output link
    my $link = $q->a({-href=>$url, -class=>$class, -target=>"_new"}, $text);
    return $link;
  }
  return;
}
