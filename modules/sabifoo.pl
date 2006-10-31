# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: sabifoo.pl,v 1.3 2006/10/31 15:07:26 as Exp $</p>';

push(@MyInitVariables, \&SabiFooInit);

sub SabiFooInit {
  my $text = UnquoteHtml(GetParam('sabifoo_message', ''));
  if ($text) {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime();
    my $today = sprintf("%02d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    my $title = '';
    if ($text =~ m/^\s*==\s*(.*?)\s*==\s*(.*)/) {
      $title = $1;
      $text = $2;
    }
    $title = FreeToNormal($today . ' ' . $title);
    if ($IndexHash{$title}) {
      $text = GetPageContent($title) . "\n\n" . $text;
    }
    my $summary = $text;
    $summary = substr($summary, 0, $SummaryDefaultLength);
    $summary =~ s/\s*\S*$/ . . ./;
    my $username = GetParam('sabifoo_author');
    $username =~ s/@.*//;
    SetParam('title', $title);
    SetParam('text', $text);
    SetParam('username', $username);
    SetParam('summary', $summary);
  }
}
