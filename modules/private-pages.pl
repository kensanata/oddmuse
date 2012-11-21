# Copyright (C) 2012  Alex Schroeder <alex@gnu.org>
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

=head1 Private Pages Extension

This module allows you to hide the content of particular pages in Oddmuse.
Unlike the I<Hidden Pages Extension>, this is not based on the user's role of
editor or administrator. Instead, every page can have a different password by
beginning it with #PASSWORD XYZZY where XYZZY is the password required to read
it. Multiple passwords can be supplied, separated by spaces.

Note that all the meta information of the private page remains public: The
I<name> of the page, the fact that is has been edited, the author, the
revision, the content of past revisions that have not been protected by a
password all remain visible to other users.

Notes:

=over

=item * This extension might not work in a mod_perl environment because it
        sets C<$NewText> without ever resetting it.

=item * If you're protecting a comment page, people can still leave comments
        -- they just can't read the resulting page.

=back

=cut

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/private-pages.pl">private-pages.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Private_Pages_Extension">Private Pages Extension</a></p>';

sub PrivatePageLocked {
  my $text = shift;
  my ($line) = split(/\n/, $text, 1);
  my @token = split(/\s+/, $line);
  my $lock = 0;
  if (shift(@token) eq '#PASSWORD') {
    my $pwd = GetParam('pwd', '');
    $lock = 1;
    foreach (@token) {
      if ($pwd eq $_) {
	$lock = 0;
	break;
      }
    }
  }
  return $lock;
}

*OldPrivatePagesUserCanEdit = *UserCanEdit;
*UserCanEdit = *NewPrivatePagesUserCanEdit;

sub NewPrivatePagesUserCanEdit {
  my ($id, $editing, @rest) = @_;
  my $result = OldPrivatePagesUserCanEdit($id, $editing, @rest);
  # bypass OpenPage and GetPageContent (these are redefined below)
  if ($result > 0 and $editing and $IndexHash{$id}) {
    my %data = ParseData(ReadFileOrDie(GetPageFile($id)));
    if (PrivatePageLocked($data{text})) {
      return 0;
    }
  }
  return $result;
}

sub PrivatePageMessage {
  return Ts('This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.',
	    '[' . ScriptUrl('action=password') . ' '
	    . T('supply the password now') . ']');
}

*OldPrivatePagesOpenPage = *OpenPage;
*OpenPage = *NewPrivatePagesOpenPage;

sub NewPrivatePagesOpenPage {
  OldPrivatePagesOpenPage(@_);
  if (PrivatePageLocked($Page{text})) {
    %Page = (); # reset everything
    $NewText = PrivatePageMessage();
  }
  return $OpenPageName;
}

*OldPrivatePagesGetPageContent = *GetPageContent;
*GetPageContent = *NewPrivatePagesGetPageContent;

sub NewPrivatePagesGetPageContent {
  my $text = OldPrivatePagesGetPageContent(@_);
  if (PrivatePageLocked($text)) {
    return PrivatePageMessage();
  }
  return $text;
}

*OldPrivatePagesGetTextRevision = *GetTextRevision;
*GetTextRevision = *NewPrivatePagesGetTextRevision;

sub NewPrivatePagesGetTextRevision {
  my ($text, $revision) = OldPrivatePagesGetTextRevision(@_);
  if (PrivatePageLocked($text)) {
    return (PrivatePageMessage(), $revision);
  }
  return ($text, $revision);
}

push(@MyRules, \&PrivatePageRule);

sub PrivatePageRule {
  if (pos == 0 && m/\G#PASSWORD.*\n/gc) {
    return '';
  }
  return undef;
}

*OldPrivatePagesGetSummary = *GetSummary;
*GetSummary = *NewPrivatePagesGetSummary;

sub NewPrivatePagesGetSummary {
  my $text = GetParam('text', '');
  if ($text and $text =~ /^#PASSWORD\b/
      # no text means aftertext is set (leaving a comment)
      or $Page{text} =~ /^#PASSWORD\b/) {
    # if no summary was set, set something in order to avoid the default
    return '';
  }
  return OldPrivatePagesGetSummary();
}
