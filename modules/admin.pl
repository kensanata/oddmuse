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

$ModulesDescription .= '<p>$Id: admin.pl,v 1.11 2006/08/06 11:44:55 as Exp $</p>';

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
    print $q->p(GetPageLink($id) . ' ' . T('not deleted: ')) . $status;
  } else {
    print $q->p(GetPageLink($id) . ' ' . T('deleted'));
    WriteRcLog($id, Ts('Deleted %s', $id), 0, $Page{revision},
	       GetParam('username', ''), GetRemoteHost(), $Page{languages},
	       GetCluster($Page{text}));
  }
  # Regenerate index on next request
  unlink($IndexFile);
  ReleaseLock();
  print $q->p(T('Main lock released.'));
  PrintFooter();
}

sub AdminPowerRename {
  my $id = FreeToNormal(GetParam('id', ''));
  ValidIdOrDie($id);
  my $new = FreeToNormal(GetParam('new', ''));
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
  # Regenerate index on next request -- remove this before errors can occur!
  unlink($IndexFile);
  # page file
  CreatePageDir($PageDir, $new); # It might not exist yet
  rename($fname, $newfname)
    or ReportError(Tss('Cannot rename %1 to %2', $fname, $newfname) . ": $!", '500 INTERNAL SERVER ERROR');
  # keep directory
  my $kdir = GetKeepDir($id);
  my $newkdir = GetKeepDir($new);
  CreatePageDir($KeepDir, $new); # It might not exist yet (only the parent directory!)
  rename($kdir, $newkdir)
    or ReportError(Tss('Cannot rename %1 to %2', $kdir, $newkdir) . ": $!", '500 INTERNAL SERVER ERROR')
      if -d $kdir;
  # refer file
  if (defined(&GetRefererFile)) {
    my $rdir = GetRefererFile($id);
    my $newrdir = GetRefererFile($new);
    CreatePageDir($RefererDir, $new); # It might not exist yet
    rename($rdir, $newrdir)
      or ReportError(Tss('Cannot rename %1 to %2', $rdir, $newrdir) . ": $!", '500 INTERNAL SERVER ERROR')
	if -d $rdir;
  }
  # RecentChanges
  OpenPage($new);
  WriteRcLog($id, Ts('Renamed to %s', $new), 0, $Page{revision},
	     GetParam('username', ''), GetRemoteHost(), $Page{languages},
	     GetCluster($Page{text}));
  WriteRcLog($new, Ts('Renamed from %s', $id), 0, $Page{revision},
	     GetParam('username', ''), GetRemoteHost(), $Page{languages},
	     GetCluster($Page{text}));
  print $q->p(Tss('Renamed %1 to %2.', GetPageLink($id), GetPageLink($new)));
  ReleaseLock();
  print $q->p(T('Main lock released.'));
  PrintFooter();
}

push(@MyAdminCode, \&AdminPower);

sub AdminPower {
  return unless UserIsAdmin();
  my ($id, $menuref, $restref) = @_;
  my $name = $id;
  $name =~ s/_/ /g;
  if ($id) {
    push(@$menuref, ScriptLink('action=delete;id=' . $id, Ts('Immediately delete %s', $name), 'delete'));
    push(@$menuref, GetFormStart()
	 . $q->label({-for=>'new'}, Ts('Rename %s to:', $name) . ' ')
	 . GetHiddenValue('action', 'rename')
	 . GetHiddenValue('id', $id)
	 . $q->textfield(-name=>'new', -size=>20)
	 . $q->submit('Do it'));
  }
}
