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

$ModulesDescription .= '<p>$Id: footnotes.pl,v 1.3 2004/03/12 19:31:53 as Exp $</p>';

my $MyFootnoteCounter = 0;
my @MyFootnotes = ();

push(@MyRules, \&FootnoteRule);

sub FootnoteRule {
  if (m/\G(\{\{(.*?)\}\})/gcs) {
    Dirty($1);
    push(@MyFootnotes,$2);
    $MyFootnoteCounter++;
    print $q->a({-href=>'#'.$MyFootnoteCounter,
		 -name=>'f'.$MyFootnoteCounter,
		 -title=>$2,
		 -class=>'footnote'},
		$MyFootnoteCounter);
  }
  return '';
}

*OldFootnotePrintFooter = *PrintFooter;
*PrintFooter = *NewFootnotePrintFooter;

sub NewFootnotePrintFooter {
  my @params = @_;
  if ($MyFootnoteCounter) {
    print '<div class="footnotes">' . $q->hr(), $q->p(T('Footnotes:')) . '<p>';
    for (my $i = 1; $i <= $MyFootnoteCounter; $i++) {
      print "<br />" if $i > 1;
      print $q->a({-name=>$i, -href=>'#f'.$i}, $i . '.' ) . ' ';
      ApplyRules(shift(@MyFootnotes), 1);
    }
    print '</p></div>';
  }
  OldFootnotePrintFooter(@params);
}
