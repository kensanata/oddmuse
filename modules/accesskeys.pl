# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>

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

AddModuleDescription('accesskeys.pl', 'Links With AccessKeys Extension');

push(@MyRules, \&LinksWithAccessKeys);
sub LinksWithAccessKeys {
  if (m/\G(\[\[$FreeLinkPattern\{(.)\}\]\])/cog) {
    my ($id, $key) = ($2, $3);
    Dirty($1);
    $id = FreeToNormal($id);
    my ($class, $resolved, $title, $exists) = ResolveId($id);
    my $text = NormalToFree($id);
    if ($resolved) { # anchors don't exist as pages, therefore do not use $exists
      print ScriptLink(UrlEncode($resolved), $text, $class, undef, $title, $key);
    } else {
      print "[[" . QuoteHtml($text) . GetEditLink($id, '?') . "]]";
    }
    return ''; # this is a dirty rule that depends the definition of other pages
  }
  return undef; # the rule didn't match
}
