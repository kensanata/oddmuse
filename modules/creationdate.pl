# Copyright (C) 2005  Fletcher T. Penney <fletcher@freeshell.org>
# Copyright (C) 2016  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.


=head1 Creation Date Extension

This module stores additional information about a page when it is first created:

=over
=item C<created> is the date the page is first saved
=item C<originalAuthor> is the username that first created a page
=back
=cut

use strict;
use v5.10;

AddModuleDescription('creationdate.pl', 'CreationDate Module');

our (%Page, $Now, @MyAdminCode, %Action, $q, $FS, $RcOldFile, $RcFile);

*CreationDateOldOpenPage = \&OpenPage;
*OpenPage = \&CreationDateOpenPage;

sub CreationDateOpenPage{
	CreationDateOldOpenPage(@_);
	$Page{created} = $Now unless $Page{created} or $Page{revision};
	$Page{originalAuthor} = GetParam('username','') unless $Page{originalAuthor}
		or $Page{revision};
}

# Allow administrators to add the 'created' item to page files, based on rc log
# files.

push(@MyAdminCode, \&CreationDateMenu);

sub CreationDateMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=add-creation-date',
		  T('Add creation date to page files'),
		  'creationdate')) if UserIsAdmin();
}

$Action{'add-creation-date'} = \&AddCreationDate;

sub AddCreationDate {
  print GetHeader('', T('Add creation date to page files'));
  print $q->start_div({-class=>'creationdate'});
  print '<ul>';
  RequestLockOrError();
  for my $file ($RcOldFile, $RcFile) {
    open(my $F, '<:encoding(UTF-8)', encode_utf8($file)) or next;
    while (my $line = <$F>) {
      chomp($line);
      my ($ts, $id, $minor, $summary, $host, $username, $revision)
	  = split(/$FS/, $line);
      next unless $revision == 1;
      print $q->li(NormalToFree($id));
      OpenPage($id);
      next unless $Page{revision}; # skip if page no longer exists
      next if $Page{created} and $Page{originalAuthor};
      $Page{created} = $ts unless $Page{created};
      $Page{originalAuthor} = $username unless $Page{originalAuthor};
      SavePage();
    }
  }
  ReleaseLock();
  print '</ul>';
  print $q->end_div();
  PrintFooter();
}
