# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#                     Sebastian Blatt <sblatt@havens.de>
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

# Includes comment pages in journal collections.

$ModulesDescription .= '<p>$Id: show-comments.pl,v 1.1 2004/09/27 23:01:29 sblatt Exp $</p>';

*OldPrintJournal = *PrintJournal;
*PrintJournal = *NewPrintJournal;

sub NewPrintJournal {
  my ($num, $regexp, $mode) = @_;
  if (!$CollectingJournal) {
    $CollectingJournal = 1;
    $regexp = "^\d\d\d\d-\d\d-\d\d" unless $regexp;
    $num = 10 unless $num;
    my @pages = (grep(/$regexp/, AllPagesList()));
    if (defined &JournalSort) {
      @pages = sort JournalSort @pages;
    } else {

      # Begin modifications to PrintJournal
      if ($mode eq 'reverse') {
        @pages = sort {
          my ($A,$B) = ($a,$b);
          map {s/^$CommentsPrefix// and $_.='z'} ($A,$B);
          $B cmp $A;
        } @pages;
      } else {
        @pages = sort {
          my ($A,$B) = ($a,$b);
          map {s/^$CommentsPrefix// or $_.='z'} ($A,$B);
          $B cmp $A;
        } @pages;
      }
      # End modifications to PrintJournal

    }
    if ($mode eq 'reverse') {
      @pages = reverse @pages;
    }
    @pages = @pages[0 .. $num - 1] if $#pages >= $num;
    if (@pages) {
      # Now save information required for saving the cache of the current page.
      local %Page;
      local $OpenPageName='';
      print '<div class="journal">';
      PrintAllPages(1, 1, @pages);
      print '</div>';
    }
    $CollectingJournal = 0;
  }
}
