#!/usr/bin/env perl
# ====================[ footnotes.pl                       ]====================

=head1 NAME

footnotes - An Oddmuse module for adding footnotes to Oddmuse Wiki pages.

=head1 INSTALLATION

footnotes is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: footnotes.pl,v 1.10 2009/05/11 02:28:45 leycec Exp $</p>';

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
$FootnotesPattern = '\&lt;footnotes\&gt;[ \t]*(\n|$)';

=head2 $FootnotesHeaderText

The string displayed as the header to the set of all page footnotes.

=cut
$FootnotesHeaderText = 'Footnotes:';

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&FootnotesInit);

sub FootnotesInit {
  @FootnoteList = ();

  if (not defined $FootnotePattern) {
    $FootnotePattern = defined &CreoleRule ? '\(\((.+?)\)\)' : '\{\{(.+?)\}\}';
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
of all footnotes for that page - usually, at the foot of the page. As example of
a citation for Jared Diamond's "Collapse: How Societies Choose to Fail or
Succeed" (2005), you might write:

  History suggests that societal decline does not result from a single cause,
  but rather the confluence of several interwoven causes.((Diamond, Jared. 2005.
  **Collapse: How Societies Choose to Fail or Succeed.** %%Viking, New York.%%))

Note that the example above embeds Wiki Creole syntax within the footnote
definition itself. This is perfectly legal and, in fact, encouraged.

=head3 CREATING MULTIPLE FOOTNOTES

footnotes also handles markup resembling:

  (($FirstFootnoteText))(($NextFootnoteText))

C<$FirstFootnoteText> and C<$NextFootnoteText> are the text for two adjacent
footnotes. These footnote definitions will be handled and displayed as above,
except that the numbered link for the first footnote will be visually delimited
from the numbered link for the footnote that follows it with a ", ". As example,
you might write:

  History suggests that societal decline does not result from a single cause,
  but rather the confluence of several interwoven causes.((Diamond, Jared. 2005.
  **Collapse: How Societies Choose to Fail or Succeed.** %%Viking, New York.%%))
  ((Tainter, Joseph. 1988. **The Collapse of Complex Societies.** %%Cambridge
  Univ Press, Cambridge, UK.%%))

=head3 REFERENCING ANOTHER FOOTNOTE

footnotes also handles marking resembling:

  (($FootnoteNumber))

C<$FootnoteNumber> is the number for another footnote. This module assigns each
footnote definition a unique number, beginning at "1". Thus, this markup allows
you to reference one footnote definition in multiple places throughout a page.
As example, you might write:
    
  History suggests that societal decline does not result from a single cause,
  but rather the confluence of several interwoven causes.((Diamond, Jared. 2005.
  **Collapse: How Societies Choose to Fail or Succeed.** %%Viking, New York.%%))

  Such causes include a human-dominated ecosystem moving to a brittle, non-
  resilient state due to climatological changes.((Weiss H, Bradley RS. 2001.
  **What drives societal collapse?** %%Science 291:609–610.%%))

  Societal decline only occurs, however, when socio-ecological systems become
  brittle and incapable of adaptation.((1))

The final footnote, above, is a reference to the first footnote definition
rather than a new footnote definition.
  
=head3 REFERENCING A RANGE OF OTHER FOOTNOTES

footnotes also handles marking resembling:

  (($FirstFootnoteNumber-$LastFootnoteNumber))

C<$FirstFootnoteNumber> and C<$LastFootnoteNumber> are the numbers for two
other footnotes. Thus, this markup allows you to reference a range of footnote
definitions in multiple places throughout a page. As example, you might write:

  History suggests that societal decline does not result from a single cause,
  but rather the confluence of several interwoven causes.((Diamond, Jared. 2005.
  **Collapse: How Societies Choose to Fail or Succeed.** %%Viking, New York.%%))

  Such causes include a human-dominated ecosystem moving to a brittle, non-
  resilient state due to climatological changes((Weiss H, Bradley RS. 2001.
  **What drives societal collapse?** %%Science 291:609–610.%%)), external
  forcings((Tainter, Jared. 2006. **Social complexity and sustainability.**
  %%Ecol Complex 3:91–103.%%)), or internal pressures((Cullen HM, et al. 2000.
  **Climate change and the collapse of the Akkadian empire: Evidence from the
  deep sea.** %%Geology 28:379–382.%%)).

  Societal decline only occurs, however, when socio-ecological systems become
  brittle and incapable of adaptation.((1-2))((4))

The final footnotes, above, are a reference to the first two footnote
definitions followed by a reference to the fourth footnote definition. This
module visually renders this disjoint list like: "1-2, 4".
  
=head3 CREATING THE SET OF FOOTNOTES

footnotes also handles markup resembling:

  <footnotes>

This extension replaces that markup with the set of all footnotes for that page.
Note that, if that page has no such markup, this extension automatically places
the set of all footnotes for that page between the content and footer for that
page. (This may or not be what you want, of course.)

=cut
sub FootnotesRule {
  # A "((...))" footnote anywhere in a page.
  #
  # Footnotes and the set of all footnotes must be marked so as to ensure their
  # reevaluation, as each of the footnotes might contain Wiki markup requiring
  # reevaluation (like, say, free links).
  if (m/\G($FootnotePattern)(?=([ \t]*$FootnotePattern)?)/gcos) {
    Dirty($1);  # do not cache the prefixing "\G"
    my $footnote_text = $2;
    my $is_adjacent_footnote = defined $3;

    # A number range (e.g., "2-5") of references to other footnotes.
    if ($footnote_text =~ m/^(\d+)-(\d+)$/co) {
      my ($footnote_number_first, $footnote_number_last) = ($1, $2);
      # '&#x2013;', below, is the HTML entity for a Unicode en-dash.
      print $q->a({-href=> '#footnotes' .$footnote_number_first,
                   -title=> 'Footnote #'.$footnote_number_first,
                   -class=> 'footnote'
                  }, $footnote_number_first.'&#x2013;')
           .$q->a({-href=> '#footnotes' .$footnote_number_last,
                   -title=> 'Footnote #'.$footnote_number_last,
                   -class=> 'footnote'
                  }, $footnote_number_last.($is_adjacent_footnote ? ', ' : ''));
    }
    # A number (e.g., "5") implying reference to another footnote.
    elsif ($footnote_text =~ m/^(\d+)$/co) {
      my $footnote_number = $1;
      print $q->a({-href=> '#footnotes' .$footnote_number,
                   -title=> 'Footnote #'.$footnote_number,
                   -class=> 'footnote'
                  }, $footnote_number.($is_adjacent_footnote ? ', ' : ''));
    }
    # Otherwise, a new footnote definition.
    else {
      push(@FootnoteList, $footnote_text);
      my $footnote_number = @FootnoteList;
      print $q->a({-href=> '#footnotes'.$footnote_number,
                   -name=>  'footnote' .$footnote_number,
                   -title=> 'Footnote: '.  # Truncate link titles to one line.
                     (  length($footnote_text) >  48
                      ? substr($footnote_text, 0, 44).'...'
                      :        $footnote_text),
                   -class=> 'footnote'
                  }, $footnote_number.($is_adjacent_footnote ? ', ' : ''));
    }

    return '';
  }
  # The "<footnotes>" list of all footnotes at the foot of a page.
  elsif ($bol && m/\G($FootnotesPattern)/gcios) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);  # do not cache the prefixing "\G"

    if (@FootnoteList) {
      my ($oldpos, $old_) = (pos, $_);
      PrintFootnotes();
      Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
      ($_, pos) = ($old_, $oldpos);   # restore \G (assignment order matters!)
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
  print
     $q->start_div({-class=> 'footnotes'})
    .$q->h2(T($FootnotesHeaderText));

  # Don't use <ol>, because we want to link from the number back to
  # its page location.
          my $footnote_number = 1;
  foreach my $footnote (@FootnoteList) {
    print
       $q->start_div({-class=> 'footnote'})
      .$q->a({-class=> 'footnote_backlink',
              -name=>  'footnotes'.$footnote_number,
              -href=> '#footnote' .$footnote_number}, $footnote_number.'.')
      .' ';
    ApplyRules($footnote, 1);
    print $q->end_div();

    $footnote_number++;
  }

  print $q->end_div();

  # Empty the footnotes, now; this prevents our calling the fallback, later.
  @FootnoteList = ();
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
