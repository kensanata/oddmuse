# Copyright (C) 2006 Brock Wilcox <awwaiid@thelackthereof.org>
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/searchtags.pl">searchtags.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/SearchTags_Extension">SearchTags Extension</a></p>';

push(@MyRules, \&SearchTagRule);

sub SearchTagRule {
  if (m/\GTags:\s*(.+)/gc) {
    my $tag_text = $1;
    my @tags = split /,\s*/, $tag_text;
    @tags = map {
      my $name = $_;
      my $encoded = $name;
      $encoded =~ s/ +/\\s+/g;
      $encoded = UrlEncode($encoded);
      ScriptLink("search=Tags:\\s*($encoded|.*,\\s*$encoded)(,|\\n)", $name);
    } @tags;
    $tags = join ', ', @tags;
    return CloseHtmlEnvironments()
      . "<div class=\"taglist\">Tags: $tags</div>"
      . AddHtmlEnvironment('p');
  }
  return undef;
}
