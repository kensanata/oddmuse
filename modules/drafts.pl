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

use vars qw($DraftDir);

$DraftDir = $DataDir."/draft"; # directory for drafts

push(@MyInitVariables, \&DraftInit);

sub DraftInit {
  if (GetParam('Draft', '')) {
    SetParam('action', 'draft') ; # Draft button used
  } elsif (-f "$DraftDir/" . GetParam('username', GetRemoteHost()) # draft exists
	   and $FooterNote !~ /action=draft/) {                    # take care of mod_perl persistence
    $FooterNote = $q->p(ScriptLink('action=draft', T('Recover Draft'))) . $FooterNote;
  }
}

$Action{draft} = \&DoDraft;

sub DoDraft {
  my $id = shift;
  my $draft = $DraftDir . '/' . GetParam('username', GetRemoteHost());
  if ($id) {
    my $text = GetParam('text', '');
    ReportError(T('No text to save'), '400 BAD REQUEST') unless $text;
    CreateDir($DraftDir);
    WriteStringToFile($draft, EncodePage(text=>$text, id=>$id));
    SetParam('msg', T('Draft saved')); # invalidate cache
    print GetHttpHeader('', T('Draft saved'), '204 NO CONTENT');
  } elsif (-f $draft) {
    my %data = ParseData(ReadFileOrDie($draft));
    unlink ($draft);
    $Message .= $q->p(T('Draft recovered'));
    DoEdit($data{id}, $data{text}, 1);
  } else {
    ReportError(T('No draft available to recover'), '404 NOT FOUND');
  }
}

# add preview button to edit page (but not to GetCommentForm!)

*DraftOldGetEditForm = *GetEditForm;
*GetEditForm = *DraftNewGetEditForm;

sub DraftNewGetEditForm {
  my $html = DraftOldGetEditForm(@_);
  # assume that the preview button html is the same for two calls
  my $draft_button = $q->submit(-name=>'Draft', -value=>T('Save Draft'));
  $html =~ s!(<input[^>]*name="Cancel"[^>]*>)!$1 $draft_button!;
  return $html;
}

# cleanup

push(@MyMaintenance, \&DraftCleanup);

sub DraftCleanup {
  print '<p>' . T('Draft Cleanup');
  foreach my $draft (glob("$DraftDir/* $DraftDir/.*")) {
    next if $draft =~ m!/\.\.?$!;
    my $ts = (stat($draft))[9];
    if ($Now - $ts < 1209600) { # 14*24*60*60
      print $q->br(), Tss("%1 was last modified %2 and was kept",
		$draft, CalcTimeSince($Now - $ts));
    } elsif (unlink($draft)) {
      print $q->br(), Tss("%1 was last modified %2 and was deleted",
		$draft, CalcTimeSince($Now - $ts));
    } else {
      print $q->br(), Ts('Unable to delete draft %s', $draft);
    }
  }
  print '</p>';
}
