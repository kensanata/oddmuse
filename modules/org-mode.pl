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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/org-mode.pl">org-mode.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Comments_on_Writing_Extensions">Comments on Writing Extensions</a></p>';

push(@MyRules, \&OrgModeRule);

my $org_emph_re = qr!\G([ \t('\"])*(([*/_=+])([^ \t\r\n,*/_=+].*?(?:\n.*?){0,1}[^ \t\r\n,*/_=+])\3)([ \t.,?;'\")]|$)!;

my %org_emphasis_alist = qw!* b / i _ u = code + del!;

sub OrgModeRule {
  if (/$org_emph_re/cgo) {
    my $tag = $org_emphasis_alist{$3};
    return "$1<$tag>$4</$tag>$5";
  }
  return undef;
}
