# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: enclosure.pl,v 1.2 2007/08/16 19:59:13 as Exp $</p>';

use vars qw(@Enclosures);

push(@MyRules, \&EnclosureRule);

# [[enclosure:page name]]
# [[enclosure:page name|alt text]]
# [[enclosure:url|size in bytes|mime type]]

sub EnclosureRule {
  if (m!\G\[\[enclosure:\s*$FreeLinkPattern(\|([^\]]+))?\]\]!ogci) {
    my $id = FreeToNormal($1);
    # Make sure we don't add duplicates; we will add non-existing
    # enclosures as well. We test for existence only when the RSS feed
    # is being produced.
    my %enclosures = map { $_ => 1 } split(' ', $Page{enclosures});
    $enclosures{$id} = 1;
    $Page{enclosures} = join(' ', keys %enclosures);
    return GetDownloadLink($id, undef, undef, $3);
  }
  return undef;
}

* OldEnclosurePrintWikiToHTML = *PrintWikiToHTML;
* PrintWikiToHTML = *NewEnclosurePrintWikiToHTML;

sub NewEnclosurePrintWikiToHTML {
  $Page{enclosures} = '';
  return OldEnclosurePrintWikiToHTML(@_);
}

* OldEnclosureRssItem = *RssItem;
* RssItem = *NewEnclosureRssItem;

sub NewEnclosureRssItem {
  my $id = shift;
  my $rss = OldEnclosureRssItem($id, @_);
  require MIME::Base64;
  my %data = ParseData(ReadFileOrDie(GetPageFile($id)));
  my @enclosures = split(' ', $data{enclosures});
  my $enclosures = '';
  foreach my $enclosure (@enclosures) {
    # Don't add the enclosure if the page has been deleted in the mean
    # time (or never existed in the first place).
    next unless $IndexHash{$enclosure};
    my $url = GetDownloadLink($enclosure, 2); # just the URL
    my %item = ParseData(ReadFileOrDie(GetPageFile($enclosure)));
    my ($type) = TextIsFile($item{text});
    my ($data) = $item{text} =~ /^[^\n]*\n(.*)/s;
    my $size = length(MIME::Base64::decode($data));
    $enclosures .= qq{<enclosure url="$url" length="$size" type="$type" />\n};
  }
  $rss =~ s!</item>$!$enclosures</item>! if $enclosures;
  return $rss;
}
