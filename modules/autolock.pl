#!/usr/bin/env perl
# ====================[ autolock.pl                        ]====================

=head1 NAME

autolock - An Oddmuse module for locking pages via regular expression matching
           on page names.

=head1 SYNOPSIS

autolock automatically locks pages whose page name matches some regular
expression from edits, creation, and deletion by non-privileged visitors (but
not by password-verified editors or administrators).

autolock thus "augments" the built-in, manual method for locking existing pages
against page edits and page deletions, by providing an automated alternative;
and provides a new method - which has no built-in, manual analogue - for locking
against page creations.

=head1 INSTALLATION

autolock is easily installable: move this file into the B<wiki/modules/>
directory of your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: autolock.pl,v 1.3 2008/09/06 11:37:33 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

autolock is easily configurable: set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($AutoLockPagesMatching
            $AutoLockCommentsPagesMatching
            $AutoLockSeverity
            $AutoLockUserCanEditEditorFix);

=head2 $AutoLockPagesMatching

A regular expression matching page names to be automatically locked against
page edits, creations, and deletions; e.g., this regular expression prevents
page edits, creations, and deletions for page names resembling
"Red Apple Falls--1997-02-16":

  $AutoLockPagesMatching = '^Red_Apple_Falls--\d\d\d\d-\d\d-\d\d';

This regular expression is left undefined, by default. (Thus, this module does
nothing, by default.) When redefined, this regular expression:

=over

=item ...should not be a quoted regular expression (i.e., "qr/.../"); and

=item ...should not be prefixed with the contents of the C<$CommentsPrefix>
      regular expression. (This module does that for you, as need be.)

=back

That aside, the limitless sky is yours.

=cut
$AutoLockPagesMatching = undef;

=head2 $AutoLockSeverity

A quadstate boolean specifying "how much" automatic locking to apply to pages
whose names match the regular expression, above. This boolean, being
"quadstate," may take any of four values, mirroring the C<$EditAllowed> site-
wide setting as follows (where "visitors" are users who are neither password-
verified administrators or password-verified editors):

=over

=item 0. B<Highest severity.> Do not allow visitors to edit, create, or delete any
         autolock-matched pages or page comments.

=item 1. B<No severity.> Permissively allow visitors to edit, create, or delete any
         autolock-matched pages or page comments, so long as the C<UserCanEdit>
         function also allows that. (This disables autolock, effectively.)

=item 2. B<Low severity.> Do not allow visitors to edit, create, or delete any
         autolock-matched pages but do allow visitors to edit, create, or delete
         autolock-matched page comments. (This is the default.)

=item 3. B<Medium severity.> Do not allow visitors to edit, create, or delete any
         autolock-matched pages or edit or delete autolock-matched page comments,
         but do allow visitors to create new page comments.

=back

=cut
$AutoLockSeverity = 2;

=head2 $AutoLockUserCanEditEditorFix

A boolean that, if true, prompts this module to overwrite the C<UserCanEdit>
Oddmuse function with a "fix" to Oddmuse's page-locking logic. By default, the
Oddmuse script (v1.865, as of this writing) allows administrators but not
editors to edit locked pages; however, this contravenes explicit Oddmuse
documentation to the contrary.

  "If you have the admin or the edit password, you may edit locked pages."
  http://www.oddmuse.org/cgi-bin/oddmuse/Page_Locking

This minor "fix" amends that, by allowing both administrators and editors to
edit locked pages.

By default, this boolean is true; and therefore implements this fix.

=cut
$AutoLockUserCanEditEditorFix = 1;

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&AutoLockInit);

sub AutoLockInit {
  # Set "$AutoLockCommentsPagesMatching", if not already set (and relevant).
  if ( defined($AutoLockPagesMatching) &&
      !defined($AutoLockCommentsPagesMatching) && $CommentsPrefix) {
    if ($AutoLockPagesMatching =~ m/^\^/) {
      $AutoLockCommentsPagesMatching = $AutoLockPagesMatching;
      $AutoLockCommentsPagesMatching =~ s/^\^/^${CommentsPrefix}/;
    }
    else {
      $AutoLockCommentsPagesMatching =
        "^${CommentsPrefix}.*${AutoLockPagesMatching}";
    }
  }

  if ($AutoLockUserCanEditEditorFix) {
    *UserCanEditAutoLockOld = *UserCanEditAutoLockFix;
  }
}

# ....................{ REDEFINITIONS                      }....................
*UserCanEditAutoLockOld = *UserCanEdit;
*UserCanEdit =            *UserCanEditAutoLock;

sub UserCanEditAutoLock {
  my ($page_name, $is_editing, $is_comment) = @_;
  my  $user_can_edit = UserCanEditAutoLockOld(@_);

  if ($user_can_edit && $AutoLockSeverity != 1 && !(UserIsAdmin() || UserIsEditor())) {
    my $is_page_locked = defined($AutoLockPagesMatching) &&
      $page_name =~            m/$AutoLockPagesMatching/;
    my $is_comments_page_locked = defined($AutoLockCommentsPagesMatching) &&
      $page_name =~                     m/$AutoLockCommentsPagesMatching/;

    if (
      ($AutoLockSeverity == 0 && ($is_page_locked ||   $is_comments_page_locked)) ||
      ($AutoLockSeverity == 2 &&  $is_page_locked && ! $is_comments_page_locked)  ||
      ($AutoLockSeverity == 3 &&  $is_page_locked && !($is_comments_page_locked &&
        ($is_comment || (GetParam('aftertext', '') && !GetParam('text', '')))))) {
      return 0;
    }
  }

  return $user_can_edit;
}

sub UserCanEditAutoLockFix {
  my ($id, $editing, $comment) = @_;
  return 0 if $id eq 'SampleUndefinedPage' or $id eq T('SampleUndefinedPage')
    or $id eq 'Sample_Undefined_Page' or $id eq T('Sample_Undefined_Page');
  return 1 if UserIsAdmin() || UserIsEditor();
  return 0 if $id ne '' and -f GetLockedPageFile($id);
  return 0 if $LockOnCreation{$id} and not -f GetPageFile($id); # new page
  return 0 if !$EditAllowed or -f $NoEditFile;
  return 0 if $editing and UserIsBanned(); # this call is more expensive
  return 0 if $EditAllowed >= 2 and (not $CommentsPrefix or $id !~ /^$CommentsPrefix/o);
  return 1 if $EditAllowed >= 3 and ($comment or (GetParam('aftertext', '') and not GetParam('text', '')));
  return 0 if $EditAllowed >= 3;
  return 1;
}

=head1 MOTIVATION

Oddmuse does provide a built-in, manual method for locking existing pages
against page edits and page deletions: for each such page, manually browse to
the "Administration" page and then "Lock ${PAGE_NAME}" page for that page. (This
is, needless to say, a clumsy means of bulk-locking some series of similarly
named pages.)

Oddmuse does not, however, provide a built-in method for preventatively locking
against page creations.

Ergo, autolock.

=head1 SEE ALSO

Jorge Arroyo's B<lock-expression.pl> module, from which this module was
(marginally) inspired and which this module (largely) replaces.

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft 2008 by B.w.Curry <http://www.raiazome.com>.

This file is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

=cut
