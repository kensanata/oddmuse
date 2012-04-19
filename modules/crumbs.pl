# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/crumbs.pl">crumbs.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/List_Parent_Pages_Extension">List Parent Pages Extension</a></p>';

push(@MyRules, \&CrumbsRule);
$RuleOrder{\&CrumbsRule} = -10; # run before default rules!

sub CrumbsRule {
  if (not (pos) # first!
      and (($WikiLinks && /\G($LinkPattern\n)/cgo)
	   or ($FreeLinks && /\G(\[\[$FreeLinkPattern\]\]\n)/cgo))) {
    my $oldpos = pos; # will be trashed below
    my $cluster = FreeToNormal($2);
    my %seen = ($cluster => 1);
    my @links = ($cluster);
    AllPagesList();		# set IndexHash
    while ($cluster) {
      my $text = GetPageContent($cluster); # opening n files is slow!
      if (($WikiLinks && $text =~ /^$LinkPattern\n/)
	  or ($FreeLinks && $text =~ /^\[\[$FreeLinkPattern\]\]\n/)) {
	$cluster = FreeToNormal($1);
      }
      last if not $cluster or $seen{$cluster};
      $seen{$cluster} = 1;
      push(@links, $cluster);
    }
    my $result = $q->span({-class=>'crumbs'}, map { GetPageLink($_) } reverse(@links));
    pos = $oldpos; # set after $_ is set!
    return $result; # clean rule, will be cached!
  }
  return undef;
}
