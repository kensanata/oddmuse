# Copyright (C) 2005       Flavio Poletti <flavio@polettix.it>
# Copyright (C) 2014-2015  Alex Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2014-2018  Alex Schroeder <alex@gnu.org>
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

# This module adds an action and a link in the UserGotoBar to build
# a Local Site Map starting from the current page. The map is a sort
# of Table Of Contents in which the current page is considered the
# root of the document.
#
# Basic idea got from MoinMoin.

use strict;
use v5.10;

our ($q, %Action, %IndexHash, $FS, $LinkPattern, $FreeLinks, $FreeLinkPattern, $WikiLinks, $BracketWiki, @MyInitVariables, $UserGotoBar);

##########################################################################
#
# End-user capabilities
#
##########################################################################
# Actions
$Action{'localmap'} = \&DoLocalMap;

# Variables
our ($LocalMapDefaultDepth);
$LocalMapDefaultDepth = 3 unless defined $LocalMapDefaultDepth;


##########################################################################
#
# Implementation
#
##########################################################################
AddModuleDescription('olocalmap.pl');

push(@MyInitVariables, \&InitLocalMap);

sub InitLocalMap {
   my $id = GetId();
   my $action = lc(GetParam('action', ''));
   AllPagesList();              # Build %IndexHash

   # Avoid putting stuff in non-pages (like RecentChanges) and in
   # the page result of the action
   return 0 unless (length($id)
                    && $IndexHash{$id}
                    && ($action cmp 'localmap'));

   # Add a link to the list of parents
   $UserGotoBar .= ScriptLink("action=localmap;id=$id", T('LocalMap')) . ' ';
}

sub DoLocalMap {
   my $id = GetParam('id', '');
   MyReportError(T('No page id for action localmap'), '400 BAD REQUEST',
                 undef, GetParam('raw', 0))
     unless length($id);

   AllPagesList();              # Build %IndexHash
   MyReportError(Ts('Requested page %s does not exist', $id),
                 '503 SERVICE UNAVAILABLE', undef, GetParam('raw', 0))
     unless ($IndexHash{FreeToNormal($id)});

   print GetHeader('', QuoteHtml(Ts('Local Map for %s', $id)), '');

   my $depth = GetParam('depth', $LocalMapDefaultDepth);
   $id = FreeToNormal($id);
   my %got;                     # Tracks already hit pages
   print($q->ul(LocalMapWorkHorse($id, $depth, \%got)));
   PrintFooter();
}

sub LocalMapWorkHorse {
   my ($id, $depth, $GotPagesRef) = @_;

   $GotPagesRef->{$id} = $depth;
   return '' unless exists($IndexHash{$id});
   my $name = $id;
   $name =~ s/_/ /g;

   my $retval_me .= ScriptLink("action=localmap;id=" . UrlEncode($id), $name);
   $retval_me .= ' (' . GetPageLink($id, T('view')) . ')';
   $retval_me = $q->li($retval_me);

   my $retval_children = '';
   if ($depth > 0) {
      my $data = ParseData(ReadFileOrDie(GetPageFile($id)));
      my @flags = split(/$FS/, $data->{'flags'});
      my @blocks = split(/$FS/, $data->{'blocks'});
      my @subpages;

      # Iterate over blocks, operate only on "dirty" ones
      for (my $i = 0; $i < @flags; ++$i) {
         next unless $flags[$i];
         my $sub_id;
         local $_ = $blocks[$i];

         if ($WikiLinks
             && ($BracketWiki && m/\G(\[$LinkPattern\s+([^\]]+?)\])/cg
                 or m/\G(\[$LinkPattern\])/cg or m/\G($LinkPattern)/cg)) {
            $sub_id = $1;
         } elsif ($FreeLinks
                  && (($BracketWiki
                       && m/\G(\[\[($FreeLinkPattern)\|([^\]]+)\]\])/cg)
                      or m/\G(\[\[\[($FreeLinkPattern)\]\]\])/cg
                      or m/\G(\[\[($FreeLinkPattern)\]\])/cg)) {
            $sub_id = $2;
         }

         if ($sub_id) {
            $sub_id = FreeToNormal($sub_id);
            if (exists $IndexHash{$sub_id}
                && ! exists $GotPagesRef->{$sub_id}) {
               push(@subpages, $sub_id);
               $GotPagesRef->{$sub_id} = $depth - 1;
            }
         }
      }

      # Recollect. We cannot do it inside the for loop because otherwise
      # we would spoil the hash pointed by $GotPagesRef
      foreach my $sub_id (@subpages) {
         $retval_children .=
           LocalMapWorkHorse($sub_id, $depth - 1, $GotPagesRef);
      }

      # Enclose all inside an unnumbered list
      $retval_children = $q->ul($retval_children) if length($retval_children);
   }

   # Return the two sections
   return $retval_me . $retval_children;
}
