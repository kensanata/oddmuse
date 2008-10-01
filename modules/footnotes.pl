#!/usr/bin/env perl
# ====================[ footnotes.pl                       ]====================

=head1 NAME

footnotes - An Oddmuse module for adding footnotes to Oddmuse Wiki pages.

=head1 INSTALLATION

footnotes is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: footnotes.pl,v 1.9 2008/10/01 06:21:46 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

footnotes is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($FootnotePattern
            $FootnotesPattern
            $FootnotesHeaderText

            @FootnoteList);

=head2 $FootnotePattern

A regular expression matching text within an Oddmuse Wiki page, which, when
matched, replaces that text with a footnote reference. In other words, text
matching this regular expression becomes a "footnote."

If left unset, this regular expression takes one of two defaults - depending on
which other Oddmuse markup modules are installed (so as not to conflict with
those other Oddmuse markup modules' markup rules).

=over

=item (($FootnoteText))

=over

=item If the Creole Markup module (B<creole.pl>) is also installed, then this
      is the default regular expression for marking a footnote (where
      C<$FootnoteText> is the displayed text for that footnote).

=back

=item {{$FootnoteText}}

=over

=item If the Creole Markup module (B<creole.pl>) is not installed, then this
      is the default regular expression for marking a footnote (where
      C<$FootnoteText> is the displayed text for that footnote). This is, also,
      the old default for this module.

=back

=back

=cut
$FootnotePattern = undef;

=head2 $FootnotesPattern

A regular expression matching text within an Oddmuse Wiki page, which, when
matched, replaces that text with the set of all page footnotes.

Any page with footnotes (i.e., any page with at least one string matching the
C<$FootnotePattern>) should collect and show those footnotes somewhere in that
page. Luckily, there are two mechanisms for effecting this - the first via
explicit markup, and the second via implicit fallback; these are:

=over

=item <footnotes>

=over

=item If a page has markup explicitly matched by this regular expression, that
      markup is replaced by the set of footnotes for the page.

=back

=item N/A

=over

=item Otherwise, if a page has no such markup but does have at least one
      footnote, the set of footnotes for the page is automatically situated
      between the content and footer for that page. As this may, or may not, be
      the proper place for page footnotes, you're encouraged to explicitly
      provide page markup matched by this regular expression.

=back

=back

=cut
$FootnotesPattern = '\&lt;footnotes\&gt;[ \t]*\n?';

=head2 $FootnotesHeaderText

The string displayed as the header to the set of all page footnotes.

=cut
$FootnotesHeaderText = 'Footnotes:';

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&FootnotesInit);

sub FootnotesInit {
  @FootnoteList = ();

  if (not defined $FootnotePattern) {
    $FootnotePattern = defined &CreoleRule ? '\(\((.*?)\)\)' : '\{\{(.*?)\}\}';
  }
}

# ....................{ MARKUP                             }....................
push(@MyRules, \&FootnotesRule);

=head2 MARKUP

=head3 CREATING FOOTNOTES

footnotes handles markup resembling (assuming the Creole Markup module is also
installed):

  (($FootnoteText))

C<$FootnoteText> is the text for that footnote. This extension replaces that
text (and enclosing parentheses) with a numbered link to the footnote in the set
of all footnotes for that page - usually, at the foot of the page.

=head3 CREATING THE SET OF FOOTNOTES

footnotes also handles markup resembling:

  <footnotes>

This extension replaces that markup with the set of all footnotes for that page.
Note that, if that page has no such markup, this extension automatically places
the set of all footnotes for that page between the content and footer for that
page. This may or not be what you want, however.

=cut
sub FootnotesRule {
  if (m/\G($FootnotePattern)(?=($FootnotePattern)?)/gcos) {
    Dirty($1);  # do not cache the prefixing "\G"
                 push(@FootnoteList, $2);
    my $footnote_number = @FootnoteList;
    my $is_adjacent_footnote = defined $3;

    print $q->a({-href=> '#footnotes'.$footnote_number,
                 -name=>  'footnote' .$footnote_number,
                 -title=> $2,
                 -class=> 'footnote'
                }, $footnote_number.($is_adjacent_footnote ? ', ' : ''));

    return '';
  }
  elsif ($bol && m/\G($FootnotesPattern)/gcios) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);  # do not cache the prefixing "\G"

    if (@FootnoteList) {
      my ($oldpos, $old_) = (pos, $_);
      PrintFootnotes();
      Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
      ($_, pos) = ($old_, $oldpos);   # restore \G (assignment order matters!)

      # Empty the footnotes array; this prevents the fallback.
      @FootnoteList = ();
    }

    return '';
  }

  return undef;
}

# ....................{ HTML OUTPUT                        }....................
*PrintFooterFootnotesOld = *PrintFooter;
*PrintFooter =             *PrintFooterFootnotes;

=head2 PrintFooterFootnotes

Appends the list of footnotes to the footer of the page, if and only if the
user-provided content for that page had no content matching C<$FootersPattern>.
Thus, this function is an eleventh-hour fallback; ideally, pages providing
footnotes also provide an explicit place to list those footnotes.

=cut
sub PrintFooterFootnotes {
  my @params = @_;
  if (@FootnoteList) { PrintFootnotes(); }
  PrintFooterFootnotesOld(@params);
}

=head2 PrintFootnotes

Prints the list of footnotes.

=cut
sub PrintFootnotes() {
  print '<div class="footnotes">'.$q->h2(T($FootnotesHeaderText));

  # Don't use <ol>, because we want to link from the number back to
  # its page location.
          my $footnote_number = 1;
  foreach my $footnote (@FootnoteList) {
    print '<div class="footnote">'
      .$q->a({-class=> 'backlink',
               -name=>  'footnotes'.$footnote_number,
               -href=> '#footnote' .$footnote_number}, $footnote_number.'.')
      .' ';
    ApplyRules($footnote, 1);
    print '</div>';

    $footnote_number++;
  }

  print '</div>';
}

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008 by B.w.Curry <http://www.raiazome.com>.
Copyright 2004 by Alex Schroeder <alex@emacswiki.org>.

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
