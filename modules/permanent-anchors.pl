# Copyright (C) 2003, 2004, 2005, 2006, 2007  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: permanent-anchors.pl,v 1.7 2007/12/09 22:08:50 as Exp $</p>';

=head1 Permanent Anchors

This module allows you to create link targets within a page. These
link targets are called named anchors in HTML. The anchors provided by
this module are permanent, because moving the anchor from one page to
another does not affect the links pointing to it. You link to these
named anchors as if they were pagenames. For users, it makes no
difference.

=cut

use vars qw(%PermanentAnchors %PagePermanentAnchors $PermanentAnchorsFile);

$PermanentAnchorsFile = "$DataDir/permanentanchors";

=head2 Definition

Permanent anchors are defined by using square brackets and a double
colon, like this: C<[::Example]>.

If you define a permanent anchor that already exists, the new
definition will have no effect. Instead you will be shown a link to
the existing permanent anchor so that you can easily resolve the
conflict.

If you define a permanent anchor and a page of the same name already
exists, the definition will work, and all links will point to the
permanent anchor. You will also be given a link to the existing page
so that you can easily resolve the conflict (eg. by deleting the
page). Note that if you mark the page for deletion, you will still
have to wait for page expiry to kick in and actually delete the page
before the message disappears.

During anchor definition a lock is created in the temporary directory.
If Oddmuse encounters a lock while defining a permanent anchor, it
will wait a few seconds and try again. If the lock cannot be obtained,
the definition fails. The unlock action available from the
administration page allows you to remove any stale locks once you're
sure the locks have been left behind by a crash. After having removed
the stale lock, edit the page with the permanent anchor definition
again.

When linking to a permanent anchor on the same page, you'll notice
that this only works flawlessly if the definition comes first. When
rendering a page, permanent anchor definitions and links are parsed in
order. Thus, if the link comes first, the permanent anchor definition
is not yet available. Once you invalidate the HTML cache (by editing
another page or by removing the C<pageidx> file from the data
directory), this situation will have fixed itself.

=cut

push(@MyRules, \&PermanentAnchorsRule);

sub PermanentAnchorsRule {
  my ($locallinks, $withanchors) = @_;
  if (m/\G(\[::$FreeLinkPattern\])/cog) {
    #[::Free Link] permanent anchor create only $withanchors
    Dirty($1);
    if ($withanchors) {
      print GetPermanentAnchor($2);
    } else {
      print $q->span({-class=>'permanentanchor'}, $2);
    }
  }
  return undef;
}

sub GetPermanentAnchor {
  my $id = FreeToNormal(shift);
  my $text = NormalToFree($id);
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if ($class eq 'alias' and $title ne $OpenPageName) {
    return '[' . Ts('anchor first defined here: %s',
		    ScriptLink(UrlEncode($resolved), $text, 'alias')) . ']';
  } elsif ($PermanentAnchors{$id} ne $OpenPageName
	   # 10 tries, 3 second wait, die on error
	   and RequestLockDir('permanentanchors', 10, 3, 1)) {
    # Somebody may have added a permanent anchor in the mean time.
    # Comparing $LastUpdate to the $IndexFile mtime does not work for
    # subsecond changes and updates are rare, so just reread the file!
    PermanentAnchorsInit();
    $PermanentAnchors{$id} = $OpenPageName;
    WritePermanentAnchors();
    ReleaseLockDir('permanentanchors');
  }
  $PagePermanentAnchors{$id} = 1; # add to the list of anchors in page
  my $html = GetSearchLink($id, 'definition', $id,
    T('Click to search for references to this permanent anchor'));
  $html .= ' [' . Ts('the page %s also exists',
		     ScriptLink("action=browse;anchor=0;id="
				. UrlEncode($id), NormalToFree($id), 'local'))
    . ']' if $exists;
  return $html;
}

=head2 Storage

Permanent anchor definitions need to be stored in a separate file.
Otherwise linking to a permanent anchor would require a search of the
entire page database. The permanent anchors are stored in a file
called C<permanentanchors> in the data directory. The location can be
changed by setting C<$PermanentAnchorsFile>.

The format of the file is simple: permanent anchor names and the name
of the page they are defined on follow each other, separated by
whitespace. Spaces within permanent anchor names and page names are
replaced with underlines, as always. Thus, the keys of
C<%PermanentAnchors> is the name of the permanent anchor, and
C<$PermanentAnchors{$name}> is the name of the page it is defined on.

=cut

push(@MyInitVariables, \&PermanentAnchorsInit);

sub PermanentAnchorsInit {
  %PagePermanentAnchors = %PermanentAnchors = ();
  my ($status, $data) = ReadFile($PermanentAnchorsFile);
  return unless $status; # not fatal
  # $FS was used in 1.417 and earlier!
  %PermanentAnchors = split(/\n| |$FS/,$data);
}

sub WritePermanentAnchors {
  my $data = '';
  foreach my $name (keys %PermanentAnchors) {
    $data .= $name . ' ' . $PermanentAnchors{$name} ."\n";
  }
  WriteStringToFile($PermanentAnchorsFile, $data);
}

=head2 Deleting Anchors

When deleting a page Oddmuse needs to delete the corresponding
permanent anchors from its file. This is why the
C<DeletePermanentAnchors> function is called from C<DeletePage>.

When a page is edited, we want to make sure that Oddmuse deletes the
permanent anchors no longer needed from its file. The safest way to do
this is to delete all permanent anchors defined on the page being
edited and redefine them when it is rendered for the first time. This
is achieved by calling C<DeletePermanentAnchors> from C<Save>. After
hitting the save button, the user is automatically redirected to the
new page. This will render the page, and redefine all permanent
anchors.

=cut

*OldPermanentAnchorsDeletePage = *DeletePage;
*DeletePage = *NewPermanentAnchorsDeletePage;

sub NewPermanentAnchorsDeletePage {
  OldPermanentAnchorsDeletePage(@_);
  DeletePermanentAnchors(@_); # the only parameter is $id
}

*OldPermanentAnchorsSave = *Save;
*Save = *NewPermanentAnchorsSave;

sub NewPermanentAnchorsSave {
  OldPermanentAnchorsSave(@_);
  DeletePermanentAnchors(@_); # the first parameter is $id
}

sub DeletePermanentAnchors {
  my $id = shift;
  # 10 tries, 3 second wait, die on error
  RequestLockDir('permanentanchors', 10, 3, 1);
  foreach (keys %PermanentAnchors) {
    if ($PermanentAnchors{$_} eq $id and !$PagePermanentAnchors{$_}) {
      delete($PermanentAnchors{$_}) ;
    }
  }
  WritePermanentAnchors();
  ReleaseLockDir('permanentanchors');
}

=head2 Name Resolution

Name resolution is done by C<ResolveId>. This function returns a list
of several items: The CSS class to use, the resolved id, the title
(eg. for popups), and a boolean saying whether the page actually
exists or not. When resolving a permanent anchor, the CSS class used
will be “alias”, the resolved id will be the C<pagename#anchorname>,
the title will be the page name.

You can override this behaviour by providing the parameter
C<anchor=0>. This is used for the link in the warning message “the
page foo also exists.”

=cut

*OldPermanentAnchorsResolveId = *ResolveId;
*ResolveId = *NewPermanentAnchorsResolveId;

sub NewPermanentAnchorsResolveId {
  my $id = shift;
  my $page = $PermanentAnchors{$id};
  if (GetParam('anchor', 1) and $page and $page ne $id) {
    return ('alias', $page . '#' . $id, $page, $IndexHash{$id})
  } else {
    return OldPermanentAnchorsResolveId($id, @_);
  }
}

=head2 Anchor Objects

An anchor object is the text that starts after the anchor definition
and goes up to the next heading, horizontal line, or the end of the
page. By redefining C<GetPageContent> to work on anchor objects we
automatically allow internal transclusion.

=cut

*OldPermanentAnchorsGetPageContent = *GetPageContent;
*GetPageContent = *NewPermanentAnchorsGetPageContent;

sub NewPermanentAnchorsGetPageContent {
  my $id = shift;
  my $result = OldPermanentAnchorsGetPageContent($id);
  if (not $result and $PermanentAnchors{$id}) {
    $result = OldPermanentAnchorsGetPageContent($PermanentAnchors{$id});
    $result =~ s/^(.*\n)*.*\[::$id\]// or return '';
    $result =~ s/(\n=|\n----|\[::$FreeLinkPattern\])(.*\n)*.*$//o;
  }
  return $result;
}

=head2 User Interface Changes

Some user interface changes are required as well.

=over

=item *

Allow the page index to list permanent anchors or not by setting
C<@IndexOptions>.

=cut

push(@IndexOptions, ['permanentanchors', T('Include permanent anchors'),
		     1, sub { keys %PermanentAnchors }]);

=item *

Make sure that you can view old revisions of pages that have a
permanent anchor of the same name. This requires link munging for all
browse links from C<GetHistoryLine>.

=back

=cut

*OldPermanentAnchorsGetHistoryLine = *GetHistoryLine;
*GetHistoryLine = *NewPermanentAnchorsGetHistoryLine;

sub NewPermanentAnchorsGetHistoryLine {
  my $id = shift;
  my $html = OldPermanentAnchorsGetHistoryLine($id, @_);
  if ($PermanentAnchors{$id}) {
    my $encoded_id = UrlEncode($id);
    # link to the current revision; ignore dependence on $UsePathInfo
    $html =~ s!$ScriptName[/?]$encoded_id!$ScriptName?action=browse;anchor=0;id=$encoded_id!;
    # link to old revisions
    $html =~ s!action=browse;id=$encoded_id!action=browse;anchor=0;id=$encoded_id!g;
  }
  return $html;
}
