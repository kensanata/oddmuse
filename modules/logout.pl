#!/usr/bin/env perl
# ====================[ logout.pl                          ]====================

=head1 NAME

logout - An Oddmuse module for logging out the current Oddmuse user.

=head1 SYNOPSIS

logout logs out the current Oddmuse user from the current Oddmuse Wiki by
clearing that user's client-side, Oddmuse-specific HTML cookie. As this cookie
persists that user's username and and (optional) password for this Oddmuse Wiki,
clearing this cookie effectively logs that user off this Oddmuse Wiki.

Viola!

=head1 INSTALLATION

logout is easily installable: move this file into the B<wiki/modules/>
directory of your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: logout.pl,v 1.3 2009/03/13 22:27:41 as Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

logout is easily configurable: set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($CommentsSuffix
            $LogoutIsDebugging
          );

=head2 $CommentsSuffix

A string that, unless blank, supplants that default
"${CommentsPrefix}${PageName}" link (e.g., "Comment on Logout_Extension")
in the edit bar with a new, page-agnostic
"${CommentsPrefix}${CommentsSuffix}" link (e.g., "Comment on this page"). Since
this string is blank, by default, it performs no such replacement. Enable it by
setting the string to some non-blank value in your B<wiki/config.pl> file; e.g.,

  $CommentsSuffix = 'this page';

If you do set this variable, please also ensure that you have set the
C<$CommentsPrefix> variable. (If that variable is not set, but this variable is,
this variable is rudely ignored. Such is life in the insensate code trenches!)

This variable's intent is to lend some minute uniformity to the edit bar. All
the edit bar's other links ("Edit this page," "View other revisions",
"Administration," and so on) are page-agnostic; these links do not reference
the current page's name. Why, then, should the comment link be any different?
While an admittedly minor point, it is a point... This variable addresses it.

Lastly. Although this variable has, clearly, little relation to the cookie-
clearing implementation of the rest of this module, this module's author
conspired no better place for it - and therefore placed it here. (Do with it
what thou wilt, museful wrangler!)

=cut
#$CommentsSuffix = 'this page';
$CommentsSuffix = '';

=head2 $LogoutIsDebugging

A boolean that, if true, prints all key-value pairs (composing the currently
requested URL query and current user's cookie) with each Oddmuse Wiki page; and,
if false, does nothing. This boolean defaults to false.

Key-value pairs are printed by appending their contents onto Oddmuse's
C<$Message> variable, which Oddmuse then tacks onto the header for each page.

=cut
$LogoutIsDebugging = '';

# ....................{ ACTIONS                            }....................
$Action{logout} = \&DoLogout;

=head1 ACTIONS

=head2 DoLogout

Logs the current user "out."

This erases every entry in that user's client-side, site-specific cookie, which
has several unnerving effects:

=over

=item The user's currently cached username is discarded. As the username, in
      the Oddmuse security model, is an aesthetic artifice having no relation
      to whether that user is an editor, administrator, or merely 'visitor',
      this doesn't do very much.

=item The user's currently cached password is discarded. If the user was logged
      in as editor or administrator, that user is now logged off and, hereafter,
      merely considered a 'visitor'.

=item All other key-value pairs are discarded. (This might serve as a decent
      mechanism for testing cookie-specific functionality in your own module,
      elsewhere.)

=back

=cut
sub DoLogout {
  foreach my $cookieKey (keys %CookieParameters) { SetParam($cookieKey, ''); }

  print
    GetHeader('', Ts('Logged out of %s', $SiteName), '').
    $q->div({-class=> 'content'}, T('You are now logged out.'));
  PrintFooter();
}

# ....................{ FUNCTIONS                          }....................
*GetFooterLinksLogoutOld = *GetFooterLinks;
*GetFooterLinks =          *GetFooterLinksLogout;

=head1 FUNCTIONS

=head2 GetFooterLinksLogout

Appends a "Logout" link onto the edit bar in the footer of each page.

=cut
sub GetFooterLinksLogout {
  my ($page_name, $page_rev) = @_;
  my  $footer_links = GetFooterLinksLogoutOld(@_);

  if ($CommentsPrefix and $CommentsSuffix) {
    $footer_links =~ s
      /(\Q<a class="comment\E.+?>).+?(<\/a>)
      /$1.NormalToFree($CommentsPrefix.$CommentsSuffix).$2
      /ex;
  }

  # Display the link to the "Logout" action iff the current user's already logged
  # in with some username or password.
  if (GetParam('username', '') ne '' or
      GetParam('pwd',      '') ne '') {
    $footer_links =~ s
      /(.+)(<\/.+?>)$
      /$1.ScriptLink('action=logout;id='.UrlEncode($id), T('Logout'), 'logout').$2
      /ex;
  }

  return $footer_links;
}

=head2 CookieUsernameFix

Corrects the C<CookieUsernameFix> function, which, in its original definition,
caused a festering heap of trouble.

We suspect a flaw in the innate coding of that function. But, whatever the
fickle case, it's supplanted here with a (somewhat) stabler version.

=cut
sub CookieUsernameFix {
  if ($LogoutIsDebugging) {
    $Message .= "<table>";

    $Message .= "<tr><td>QUERY::</td></tr>";
    my %query_parameters = $q->Vars;
    foreach my $query_parameter_name (keys %query_parameters) {
      $Message .= "<tr>"
        ."<td>${query_parameter_name}:</td>"
        ."<td>$query_parameters{$query_parameter_name}</td></tr>";
    }

    $Message .= "<tr><td>COOKIE::</td></tr>";
    my ($changed, $visible, %cookie_parameters) = CookieData();
    foreach my $cookie_parameter (keys %cookie_parameters) {
      $Message.="<tr>"
        ."<td>${cookie_parameter}:</td>"
        ."<td>$cookie_parameters{$cookie_parameter}</td></tr>";
    }

    $Message .= "</table>";
  }

  # Only valid usernames get stored in the new cookie.
  my   $name = GetParam('username', '');
  if (!$name) { }
  elsif (!$FreeLinks && !($name =~ /^$LinkPattern$/o)) {
    CookieUsernameFixDelete(Ts('Invalid UserName %s: not saved.', $name));
  }
  elsif ($FreeLinks && (!($name =~ /^$FreeLinkPattern$/o))) {
    CookieUsernameFixDelete(Ts('Invalid UserName %s: not saved.', $name));
  }
  elsif (length($name) > 50) {  # Too long
    CookieUsernameFixDelete(T('UserName must be 50 characters or less: not saved'));
  }
}

sub CookieUsernameDelete {
  $Message .= $q->p(shift);
  $q->delete('username');
}

=head1 INTERFACE

logout considers an Oddmuse user to be logged in if and only if that user has
entered either some username or one of two site-wide passwords. (See
L<SECURITY>, below.)

If the current Oddmuse Wiki user is logged in, this module appends a "Logout"
link to the edit bar; if not, this module does not. (That, perchance, ill-named
edit bar is the second line of navigational, administerial links in the footer
for each page.)

If the current Oddmuse Wiki user is logged in and does click on that "Logout"
link in the edit bar, this module logs out that user by clearing the user's
client-side, site-specific cookie of all key-value pair content.

Oddmuse should, arguably, bundle this easy functionality into the main
Oddmuse script. It doesn't; so, we do it here.

=head1 SECURITY

logout inherits its security model from Oddmuse, to which it makes no serious
change. Now, Oddmuse has no pre-defined mechanism for managing users; rather,
when editing any editable page or commenting on any commentable page, anyone
may enter any username in the "Username:" edit field. That username need not
be registered, approved, or otherwise managed (as in other content management
systems). That username, as such, has no user-defined password, passphrase, or
other identifying token. Any user may masquerade as any other user, with happy
impunity!

logout retains this (admittedly loose) concept of a "user."

=head1 SEE ALSO

logout is "little brother" to the login module - from which it was inspired and
for which it's partly named, in antiparallel.

logout only implements a slim subset of functionality implemented by the logout
module. For a full-bodied, fully configurable alternative to Oddmuse security,
please use that module instead.

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
