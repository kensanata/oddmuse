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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/tables.pl">tables.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Table_Markup_Extension">Table Markup Extension</a></p>';

push(@MyRules, \&TablesRule);

my $RowCount;

sub TablesRule {
  # tables using || -- the first row of a table
  if ($bol && m/\G(\s*\n)*((\|\|)+)([ \t])*(?=.*\|\|[ \t]*(\n|$))/cg) {
    $RowCount = 1;
    return OpenHtmlEnvironment('table',1,'user')
      . AddHtmlEnvironment('tr', 'class="odd first"')
      . AddHtmlEnvironment('td', TableAttributes(length($2)/2, $4));
  }
  # tables using || -- end of the row and beginning of the next row
  elsif (InElement('td') && m/\G[ \t]*((\|\|)+)[ \t]*\n((\|\|)+)([ \t]*)/cg) {
    my $attr = TableAttributes(length($3)/2, $5);
    my $type = ++$RowCount % 2 ? 'odd' : 'even';
    $attr = " " . $attr if $attr;
    return qq{</td></tr><tr class="$type"><td$attr>};
  }
  # tables using || -- an ordinary table cell
  elsif (InElement('td') && m/\G[ \t]*((\|\|)+)([ \t]*)(?!(\n|$))/cg) {
    my $attr = TableAttributes(length($1)/2, $3);
    $attr = " " . $attr if $attr;
    return "</td><td$attr>";
  }
  # tables using || -- since "next row" was taken care of above, this must be the last row
  elsif (InElement('td') && m/\G[ \t]*((\|\|)+)[ \t]*/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  }
  return undef;
}

sub TableAttributes {
  my ($span, $left, $right) = @_;
  my $attr = '';
  $attr = "colspan=\"$span\"" if ($span != 1);
  m/\G(?=.*?([ \t]*)\|\|)/;
  $right = $1;
  $attr .= ' ' if ($attr and ($left or $right));
  if ($left and $right) { $attr .= 'align="center"' }
  elsif ($left) { $attr .= 'align="right"' }
  elsif ($right) { $attr .= 'align="left"' }
  return $attr;
}
