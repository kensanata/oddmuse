# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: anchors.pl,v 1.2 2004/02/09 21:02:46 as Exp $</p>';

push(@MyRules, \&AnchorsRule);

sub AnchorsRule {
  if (m/\G\[\#([^ ]*)\]/gc) {
    return $q->a({-name=>$1});
  } elsif (m/\G\#([^ ]*)/gc) {
    return $q->a({-href=>"#$1", -class=>'anchor'}, $1);
  }
  return '';
}
