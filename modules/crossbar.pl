#!/usr/bin/env perl
# ====================[ crossbar.pl                         ]====================

=head1 NAME

crossbar - An Oddmuse module for adding a site-wide footer, header, or other
           summary markup to all Oddmuse Wiki pages.

=head1 SYNOPSIS

crossbar is a drop-in substitute for the Sidebar module, which, as it is not
entirely "backwards compatible" with the Sidebar module, is provided as a
separate module and not revision of that module.

crossbar provides additional functionality, including:

=over

=item Support for the Table of Contents and Footnotes modules. (The Sidebar
      module does not support these modules.)

=item Support for displaying the crossbar anywhere in a page. (The Sidebar
      module does not permit the sidebar to be displayed anywhere except
      immediately after the header div and before the content div.)

=back

And so on.

=head1 INSTALLATION

crossbar is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
$ModulesDescription .= '<p>$Id: crossbar.pl,v 1.7 2008/12/12 22:44:39 as Exp $</p>';

# ....................{ CONFIGURATION                      }....................
use vars qw($CrossbarPageName
            $CrossbarDivIsOutsideContentDiv
            $CrossbarSubstitutionPattern);

=head1 CONFIGURATION

crossbar is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut

=head2 $CrossbarPageName

The name of the page having crossbar markup. This markup will be added,
automatically, to every Wiki page at the position matched by the
C<$CrossbarSubstitutionPattern>, below.

=cut
$CrossbarPageName = 'Crossbar';

=head2 $CrossbarDivIsOutsideContentDiv

A boolean that, if true, places the <div class="crossbar">...</div> block
"outside" the <div class="content browse">...</div> block; otherwise, this
places it inside the <div class="content browse">...</div> block. Generally,
placing the crossbar div outside the content div gives a cleaner, sensibler
aesthetic. (Your mileage may vary!)

By default, this boolean is true.

=cut
$CrossbarDivIsOutsideContentDiv = 1;

=head2 $CrossbarSubstitutionPattern

The regular expression matching the position in each page to place the crossbar
for that page. While, theoretically, this can be any pattern, it tends to be one
the following two:

=over

=item '^'. This places the sidebar for each page immediately after that page's
      header and before that page's content.

=item '$'. This places the sidebar for each page immediately after that page's
      content and before that page's footer.

=back

This module uses the first regular expression, by default.

=cut
$CrossbarSubstitutionPattern = '^';

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&CrossbarInit);

# A boolean that, if true, indicates that a crossbar has already been applied to
# this page. This prevents application of a crossbar onto pages included by this
# current page -- and, in general, protects against "reentrant recursion."
my $CrossbarIsApplied;

sub CrossbarInit {
  $CrossbarIsApplied = '';
  $CrossbarPageName = FreeToNormal($CrossbarPageName); # spaces to underscores

  # Add a link to the crossbar page to the "Administration" page.
  $AdminPages{$CrossbarPageName} = 1;

  # If pulling the crossbar div outside the content div, we redefine the
  # default PrintPageContent() function to do this.
  if ($CrossbarDivIsOutsideContentDiv) {
    *PrintPageContentCrossbarOld = *PrintPageContent;
    *PrintPageContent            = *PrintPageContentCrossbar;
  }

  # If this user is an authenticated administrator, forcefully clear the page
  # cache whenever saving the crossbar page.
  if (UserIsAdmin()) {
    *SaveCrossbarOld = *Save;
    *Save            = *SaveCrossbar;
  }

  # If the Table of Contents module is also installed, we must prevent handling
  # of any Table of Contents-specific code when in the
  # '<div class="crossbar">...</div>' block. Why? Because: Table of Contents-
  # specific code adds unique identifiers to HTML headers, Crossbar pages may
  # contain HTML headers, and those HTML headers should not have unique
  # identifiers added to them, since adding unique identifiers to Crossbar page
  # headers would add those headers to the Table of Contents for //every// page.
  # (Trust us on this one...)
  if (defined &RunMyRulesToc) {
    *RunMyRulesCrossbarOld = *RunMyRules;
    *RunMyRules            = *RunMyRulesCrossbar;
  }
}

# ....................{ MARKUP =before                     }....................
*OldCrossbarApplyRules = *ApplyRules;
*ApplyRules = *NewCrossbarApplyRules;

sub NewCrossbarApplyRules {
  my $text = shift;
  if (not $CrossbarIsApplied
      and not TextIsFile($text)
      and (not $SidebarName or $OpenPageName ne $SidebarName)) {
    my  $crossbar_markup = GetPageContent($CrossbarPageName);
    if ($crossbar_markup and $crossbar_markup !~ m~^(\s*$|$DeletedPage)~) {
      $CrossbarIsApplied = 1;
      $text =~ s~$CrossbarSubstitutionPattern~
	"\n\n&lt;crossbar&gt;\n\n".QuoteHtml($crossbar_markup).
	"\n\n&lt;/crossbar&gt;\n\n"~e;
    }
  }
  return OldCrossbarApplyRules($text, @_);
}

# ....................{ MARKUP                             }....................
push(@MyRules, \&CrossbarRule);
SetHtmlEnvironmentContainer('div', '^class="crossbar"$');

sub CrossbarRule {
  if ($bol) {
    if    ( m~\G\&lt;crossbar\&gt;~cg) {
      return ($HtmlStack[0] eq 'p' ? CloseHtmlEnvironment() : '')
        .AddHtmlEnvironment  ('div',  'class="crossbar"');
    }
    elsif (m~\G\&lt;/crossbar\&gt;~cg) {
      return
         CloseHtmlEnvironment('div', '^class="crossbar"$')
        # If pulling the crossbar div outside the content div, we mark the point
        # immediately after the close of the crossbar div with an HTML comment;
        # this allows us to match the contents of the div with a clean regular
        # expression. (A bit complicated, that one...)
        .($CrossbarDivIsOutsideContentDiv ? '<!-- crossbar/-->' : '');
    }
  }

  return undef;
}

=head2 RunMyRulesCrossbar

Redefines the Table of Contents module's C<RunMyRulesToc> function, when that
module is installed, so as to apply a hacky, Crossbar-specific fix.

=cut
sub RunMyRulesCrossbar {
  my $TocIsApplyingAutomaticRulesOld = $TocIsApplyingAutomaticRules;
     $TocIsApplyingAutomaticRules = '' if InElement('div', '^class="crossbar"$');

  my $html = RunMyRulesCrossbarOld(@_);

  $TocIsApplyingAutomaticRules = $TocIsApplyingAutomaticRulesOld;
  return $html;
}

# ....................{ BROWSING                           }....................

=head2 PrintPageContentCrossbar

Redefines the default C<PrintPageContent> function so as to extract the
crossbar "<div...>" outside the content "<div...>", when so desired.

=cut
sub PrintPageContentCrossbar {
  my $html = '';
  my $crossbar_pattern = '(<div class="crossbar">.*?</div>)<!-- crossbar/-->';

  { local *STDOUT;
    open(  STDOUT, '>', \$html) or die "Can't open memory file: $!";
    PrintPageContentCrossbarOld(@_);
    close  STDOUT; }

  # If the crossbar div is placed immediately after the content div, place it
  # immediately before the content div.
  if (not ($html =~ s~(<div class="content browse">)$crossbar_pattern~$2$1~)) {
    # Otherwise, if the crossbar div is placed immediately before the end of the
    # content div, place it immediately after the end of the content div.
    $html =~
      s~$crossbar_pattern(.*?<div class="wrapper close"></div></div>)~$2$1~;
  }

  print $html;
}

# ....................{ EDITING                            }....................
*GetEditFormCrossbarOld = *GetEditForm;
*GetEditForm            = *GetEditFormCrossbar;

sub GetEditFormCrossbar {
  my ($page_name) = @_;
  return
    ($page_name eq $CrossbarPageName ?
     $q->p({-class=> 'crossbar_edit_message'},
           T(UserIsAdmin()
             ? '<strong>You are currently logged in as an administrator.</strong> '
             .'Saving this page propagates your crossbar changes to '
             .'<em>all</em> other pages by forcefully clearing this Wiki\'s page cache.'
             : '<strong>You are not currently logged in as an administrator.</strong> '
             .'Saving this page only propagates your crossbar changes to <em>newly '
             .'created </em> or <em>edited</em> pages &#x2014; but don\'t let that deter you!')) : '')
    .GetEditFormCrossbarOld(@_);
}

# ....................{ SAVING                             }....................

=head2 SaveCrossbar

Clears the page cache whenever a user saves the crossbar page. Why?
Because the the contents of the crossbar page is injected into every
other page. Consequently, when the crossbar page changes, the contents
of other pages are also changed; and must have their caches forcefully
cleared, to ensure they are changed.

=cut
sub SaveCrossbar {
  my ($page_name) = @_;
  SaveCrossbarOld(@_);
  if ($page_name eq $CrossbarPageName) {
    # Prevent the RequestLockOrError() and ReleaseLock() functions from doing
    # anything while in the DoClearCache() method, since the default Save()
    # function already obtains the lock. (We can't obtain it twice!)
    *RequestLockOrErrorCrossbarOld = *RequestLockOrError;
    *RequestLockOrError            = *RequestLockOrErrorCrossbarNoop;
    *ReleaseLockCrossbarOld = *ReleaseLock;
    *ReleaseLock            = *ReleaseLockCrossbarNoop;

    # Clear the page cache, now. Go! (Note: this prints a heap of HTML.)
    DoClearCache();

    # Restore locking functionality.
    *RequestLockOrError = *RequestLockOrErrorCrossbarOld;
    *ReleaseLock =        *ReleaseLockCrossbarOld;
  }
}

sub RequestLockOrErrorCrossbarNoop { }
sub ReleaseLockCrossbarNoop { }

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft 2008 by B.w.Curry <http://www.raiazome.com>.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see L<http://www.gnu.org/licenses/>.

=cut
