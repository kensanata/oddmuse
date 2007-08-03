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

$ModulesDescription .= '<p>$Id: today.pl,v 1.7 2007/08/03 23:08:43 as Exp $</p>';

# New Action

push(@MyAdminCode, \&TodayMenu);

sub TodayMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=new',
		  T('Create a new page for today'),
		  'today'));
}

$Action{new} = \&DoNew;

sub DoNew {
  my $id = shift;
  # GetId() returns "SandWiki" for the following URL:
  # http://www.communitywiki.org/odd/SandWiki?action=new.
  if ($UsePathInfo and $NamespaceCurrent
      and $id eq $NamespaceCurrent
      and GetParam($NamespaceCurrent, 0) == 0
      and not GetParam('id', '')) {
    # Undo this unless we're getting
    # http://www.communitywiki.org/odd/SandWiki/SandWiki?action=new or
    # http://www.communitywiki.org/odd/SandWiki?action=new;id=SandWiki.
    $id = '';
  }
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime($Now);
  $today = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
  $today .= sprintf("_%02dh%02d", $hour, $min) if GetParam('hour', 0);
  $today .= "_$id" if $id;
  return DoEdit($today);
}
