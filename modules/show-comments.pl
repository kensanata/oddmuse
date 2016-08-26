# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#                     Sebastian Blatt <sblatt@havens.de>
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

# Includes comment pages in journal collections.

use strict;
use v5.10;

AddModuleDescription('show-comments.pl', 'Comment Pages');

our (%Page, $OpenPageName, $CommentsPrefix, $CollectingJournal);

*OldPrintJournal = \&PrintJournal;
*PrintJournal = \&NewPrintJournal;

sub NewPrintJournal {
  my ($num, $regexp, $mode) = @_;
  if (!$CollectingJournal) {
    $CollectingJournal = 1;
    $regexp = '^\d\d\d\d-\d\d-\d\d' unless $regexp;
    $num = 10 unless $num;
    my @pages = (grep(/$regexp/, AllPagesList()));
    if (defined &JournalSort) {
      @pages = sort JournalSort @pages;
    } else {

      # Begin modifications to PrintJournal
      if ($mode eq 'reverse') {
        @pages = sort {
          my ($A, $B) = ($a, $b);
          $A .= 'z' unless $A =~ s/^$CommentsPrefix//;
          $B .= 'z' unless $B =~ s/^$CommentsPrefix//;
          $B cmp $A;
        } @pages;
      } else {
        @pages = sort {
          my ($A, $B) = ($a, $b);
          $A .= 'z' unless $A =~ s/^$CommentsPrefix//;
          $B .= 'z' unless $B =~ s/^$CommentsPrefix//;
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
      PrintAllPages(1, 1, undef, undef, @pages);
      print '</div>';
    }
    $CollectingJournal = 0;
  }
}
