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

$ModulesDescription .= '<p>$Id: tables-in-lists.pl,v 1.1 2008/06/19 06:03:59 ingob Exp $</p>';

push(@MyRules, \&TablesInListsRule);

sub TablesInListsRule {
# tables using || -- the first row of a table inside a list
    if ($bol && m/\G((\|\|)+)([ \t])*(?=.*\|\|[ \t]*(\n|$))/cg) {
        $rowcount = 1;
        if (InElement('li')) {  
        return CloseHtmlEnvironmentUntil('li')
            . AddHtmlEnvironment('table', 'class="user"')
            . AddHtmlEnvironment('tr', 'class="odd first"')
            . AddHtmlEnvironment('td', UsemodTableAttributes(length($1)/2, $3));
        } else {
        return OpenHtmlEnvironment('table',1,'user')
            . AddHtmlEnvironment('tr', 'class="odd first"')
            . AddHtmlEnvironment('td', UsemodTableAttributes(length($2)/2, $4));
        }
    }
    # tables using || -- end of the row and beginning of the next row
    elsif (InElement('td') && m/\G[ \t]*((\|\|)+)[ \t]*\n((\|\|)+)([ \t]*)/cg) {
        my $attr = UsemodTableAttributes(length($3)/2, $5);
        my $type = ++$rowcount % 2 ? 'odd' : 'even';
        $attr = " " . $attr if $attr;
        return qq{</td></tr><tr class="$type"><td$attr>};
        }
    # tables using || -- an ordinary table cell
    elsif (InElement('td') && m/\G[ \t]*((\|\|)+)([ \t]*)(?!(\n|$))/cg) {
        my $attr = UsemodTableAttributes(length($1)/2, $3);
        $attr = " " . $attr if $attr;
        return "</td><td$attr>";
    }
    # tables using || -- since "next row" was taken care of above, this must be the last row
        elsif (InElement('td') && m/\G[ \t]*((\|\|)+)[ \t]*/cg) {
            if (InElement('li')) {
                return CloseHtmlEnvironmentUntil('li');
            } else {
                return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
            }
    }
    return undef; # sonst geht Oddmuse in eine Endlosschleife
}
