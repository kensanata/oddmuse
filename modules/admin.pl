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

$ModulesDescription .= '<p>$Id: admin.pl,v 1.4 2004/06/12 11:24:57 as Exp $</p>';

$Action{delete} = \&AdminPowerDelete;
$Action{rename} = \&AdminPowerRename;

sub AdminPowerDelete {
  my $id = GetParam('id', '');
  ValidIdOrDie($id);
  print GetHeader('', Ts('Deleting %s', $id), '');
  return unless UserIsAdminOrError();
  RequestLockOrError();
  print $q->p(T('Main lock obtained.'));
  OpenPage($id);
  my $status = DeletePage($id);
  if ($status) {
    print $q->p(GetPageLink($id) . ' ' . T('not deleted: ') . $status;
  } else {
    print $q->p(GetPageLink($id) . ' ' . T('deleted'));
    WriteRcLog($id, Ts('Deleted %s', $new), 0, $Page{revision},
	       GetParam('username', ''), GetRemoteHost(), $Page{languages},
	       GetCluster($Page{text}));
  }
  ReleaseLock();
  print $q->p(T('Main lock released.'));
  PrintFooter();
}

sub AdminPowerRename {
  my $id = GetParam('id', '');
  ValidIdOrDie($id);
  my $new = GetParam('new', '');
  ValidIdOrDie($new);
  print GetHeader('', Tss('Renaming %1 to %2.', $id, $new), '');
  return unless UserIsAdminOrError();
  RequestLockOrError();
  print $q->p(T('Main lock obtained.'));
  # page file -- only check for existing or missing pages here
  my $fname = GetPageFile($id);
  ReportError(Ts('The page %s does not exist', $id), '400 BAD REQUEST') unless -f $fname;
  my $newfname = GetPageFile($new);
  ReportError(Ts('The page %s already exists', $new), '400 BAD REQUEST') if -f $newfname;
  CreatePageDir($PageDir, $new); # It might not exist yet
  rename($fname, $newfname);
  # keep directory
  CreatePageDir($KeepDir, $new); # It might not exist yet
  rename(GetKeepDir($id), GetKeepDir($new));
  # refer file
  CreatePageDir($RefererDir, $new); # It might not exist yet
  rename(GetRefererFile($id), GetRefererFile($new));
  # RecentChanges
  OpenPage($new);
  WriteRcLog($id, Ts('Renamed to %s', $new), 0, $Page{revision},
	     GetParam('username', ''), GetRemoteHost(), $Page{languages},
	     GetCluster($Page{text}));
  WriteRcLog($new, Ts('Renamed from %s', $id), 0, $Page{revision},
	     GetParam('username', ''), GetRemoteHost(), $Page{languages},
	     GetCluster($Page{text}));
  print $q->p(Tss('Renamed %1 to %2.', GetPageLink($id), GetPageLink($new)));
  # Regenerate index on next request -- remove this before errors can occur!
  unlink($IndexFile);
  ReleaseLock();
  print $q->p(T('Main lock released.'));
  PrintFooter();
}

*OldAdminPowerGetAdminBar = *GetAdminBar;
*GetAdminBar = *NewAdminPowerGetAdminBar;

sub NewAdminPowerGetAdminBar {
  my ($id, $rev) = @_;
  my $html = OldAdminPowerGetAdminBar(@_);
  if ($id) {
    $html .= ' | ' . ScriptLink('action=delete;id=' . $id, T('Delete page'));
    $html .= GetFormStart()
      . T('Rename this page to:') . ' '
	. GetHiddenValue('action', 'rename')
	  . GetHiddenValue('id', $id)
	    . $q->textfield(-name=>'new', -size=>20)
	      . $q->submit('Do it');
  }
  return $html;
}
