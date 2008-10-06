#!/usr/bin/env perl
# ====================[ creole.pl                          ]====================

=head1 NAME

creole - An Oddmuse module for marking up Oddmuse Wiki pages according to the
         Wiki Creole standard, a Wiki-agnostic syntax scheme.

=head1 INSTALLATION

creole is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: creole.pl,v 1.48 2008/10/06 22:21:18 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

creole is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($CreoleLineBreaks
            $CreoleTildeAlternative
            $CreoleTableCellsAllowBlockLevelElements);

=head2 $CreoleLineBreaks

A boolean that, if true, causes this extension to convert single newlines in
page text to genuine linebreaks (i.e., the <br> tag) in the HTML for that
page. (If false, this extension consumes single newlines without actually
converting them into anything; they will be ignored, wherever found.)

Irregardless of this booleans setting, this extension always converts two
newlines to a paragraph break (i.e., the <p> tag).

=cut
$CreoleLineBreaks = 0;

=head2 $CreoleTildeAlternative

A boolean that, if true, prevents this extension from consuming the tilde ~
character, when that character appears in front of an a-z, A-Z, or 0-9
character. (If false, this extension consumes such tilde ~ characters.)

=cut
$CreoleTildeAlternative = 0;

=head2 $CreoleTableCellsAllowBlockLevelElements

A boolean that, if true, permits table cell markup to embed block level
elements in table cells. By default, this boolean is false.

Block level elements include such "high-level" entities as paragraphs,
blockquotes, list items, and so on. Thus, enabling this boolean permits you to
embed multiple paragraphs, blockquotes, and so on in individual table cells.

Please note: enabling this boolean permits non-conformant syntax -- that is,
syntax which no longer conforms to the Wiki Creole standard. (In general,
unless you have significant amounts of Wiki Creole table markup strictly
conforming to the Wiki Creole standard, this shouldn't be an issue.)

Please note: enabling this boolean also requires you explicitly close the last
table cell of a cell with a "|" character. (This character is optional under
the Wiki Creole standard, but not under this non-conformant alteration.)

=cut
$CreoleTableCellsAllowBlockLevelElements = 0;

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&CreoleInit);

my $is_creoleaddition_installed;
sub CreoleInit {
   $is_creoleaddition_installed = defined &CreoleAdditionRule;
}

*InitLinkPatternsCreoleOld = *InitLinkPatterns;
*InitLinkPatterns =          *InitLinkPatternsCreole;

=head2 InitLinkPatternsCreole

This permits users to add URLs resembling:
  "See [[/?action=index|the site map]]."

Which Oddmuse converts to HTML resembling:
  "See <a href="/?action=index">the site map</a>."

When not using this extension, users must explicitly add the site's base URL:
  "See [[http://www.oddmuse.com/cgi-bin/oddmuse?action=index|the site map]]."

=cut
sub InitLinkPatternsCreole {
    InitLinkPatternsCreoleOld();

  my $UrlChars = '[-a-zA-Z0-9/@=+$_~*.,;:?!\'"()&#%]';    # see RFC 2396
  $FullUrlPattern = "((?:$UrlProtocols)?[:/]$UrlChars+)"; # when used in square brackets
}

# ....................{ MARKUP                             }....................
push(@MyRules,
     \&CreoleRule,
     \&CreoleHeadingRule,
     \&CreoleListAndNewLineRule,
    );

# Creole link rules conflict with Oddmuse's default LinkRule.
$RuleOrder{\&CreoleRule} = -10;
# Creole heading rules must come after the TocRule.
$RuleOrder{\&CreoleHeadingRule} = 100;
# List items must come later than MarkupRule because *foo* at the
# beginning of a line should be bold, not the list item foo*. Also,
# newlines must come after list items, otherwise this will add a lot
# of useless "</br>" tags.
$RuleOrder{\&CreoleListAndNewLineRule} = 180;

=head2 ListRule

Nullifies Oddmuse's default C<ListRule> function. That function conflicts with
this extension's C<CreoleListAndNewLineRule> function; thus, we redefine that
function to return nothing.

=cut
sub ListRule { return undef; }

# A regular expression matching Wiki Creole-style table cells, locally accessed
# by CreoleRule, below.
my $CreoleTableCellPattern = '[ \t]*(\|+)(=)?\n?([ \t]*)';

=head2 CreoleRule

Handles the large part of Wiki Creole syntax.

Technically, as Oddmuse's default C<LinkRules> function also conflicts with
this extension's link rules and does not comply, in any case, with the Wiki
Creole rules for links, we should also nullify Oddmuse's default C<LinkRules>
function. Sadly, we don't. Why? Since existing Oddmuse Wikis using this
extension depend on Oddmuse's default C<LinkRules> function, and as it's no
terrible harm to let that function be, we have to let it be. Bah!

=cut
sub CreoleRule {
  # "$is_interlinking" is a boolean that, if true, indicates this rule should
  # make interlinks (i.e., links to Wiki pages on other, external Wikis) and,
  # and, if false, should not. (Typically, Oddmuse sets this to false when
  # including external HTML pages into local Wiki pages.)
  my ($is_intralinking, $is_intraanchoring) = @_;

  # Block level elements.
  if ($bol) {
    # horizontal line
    # ----
    if (m/\G(\s*\n)*[ \t]*----+[ \t]*\n?/cg or m/\G\s*\n----+[ \t]*\n?/cg) {
      return CloseHtmlEnvironments().$q->hr().AddHtmlEnvironment('p');
    }
    # {{{
    # preformatted
    # }}}
    elsif (m/\G\{\{\{[ \t]*\n(.*?\n)\}\}\}[ \t]*(\n|\z)/cgs) {
      my $str = $1;
      $str =~ s/\n }}}/\n}}}/g;
      return CloseHtmlEnvironments()
        .$q->pre({-class=> 'real'}, $str)
        .AddHtmlEnvironment('p');
    }
  }

  # escape next char (and prevent // in URLs from enabling italics)
  # ~
  if (m/\G(~($FullUrlPattern|\S))/cgo) {
    return
      ($CreoleTildeAlternative and
       index( 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
             .'abcdefghijklmnopqrstuvwxyz'
             .'0123456789', $2) != -1)
        ? $1  # tilde stays
        : $2; # tilde disappears
  }
  # **bold**
  elsif (m/\G\*\*/cg) { return AddOrCloseCreoleEnvironment('strong'); }
  # //italic//
  elsif (m/\G\/\//cg) { return AddOrCloseCreoleEnvironment('em'); }
  # {{{unformatted}}}
  elsif (m/\G\{\{\{(.*?}*)\}\}\}/cgs) {
    return $q->code($1);
  }
  # {{pic}}
  elsif (m/\G(\{\{$FreeLinkPattern(\|.+?)?\}\})/cgos) {
    Dirty($1);
    # FIXME: inlining this gives "substr outside of string" error
    my $alt = substr($3, 1);
    print GetDownloadLink($2, 1, undef, $alt);
    return '';
  }
  # {{url}}
  elsif (m/\G\{\{$FullUrlPattern\s*(\|.+?)?\}\}/cgos) {
    return GetCreoleImageHtml(
      $q->a({-href=> $1,
             -class=> 'image outside'},
            $q->img({-src=> $1,
                     -alt=> substr($2, 1),
                     -class=> 'url outside'})));
  }
  # link: [[link|{{pic}}]]
  elsif (m/\G\[\[$FreeLinkPattern\|\{\{$FreeLinkPattern(\|.+?)?\}\}\]\]/cgos) {
    return GetCreoleImageHtml(
      ScriptLink($1,
                 $q->img({-src=> GetDownloadLink($2, 2),
                          -alt=> substr($3,1)||NormalToFree($1),
                          -class=> 'upload'}), 'image'));
  }
  # link: [[link|{{url}}]]
  elsif (m/\G\[\[$FreeLinkPattern\|\{\{$FullUrlPattern\s*(\|.+?)?\}\}\]\]/cgos) {
    return GetCreoleImageHtml(
      ScriptLink($1,
                 $q->img({-src=> $2,
                          -class=> 'url outside',
                          -alt=> substr($3,1)||$1}), 'image'));
  }
  # link: [[url|{{pic}}]]
  elsif (m/\G\[\[$FullUrlPattern\s*\|\{\{$FreeLinkPattern(\|.+?)?\}\}\]\]/cgos) {
    return GetCreoleImageHtml(
      $q->a({-href=> $1, -class=> 'image outside'},
            $q->img({-src=> GetDownloadLink($2, 2),
                     -class=> 'upload',
                     -alt=> substr($3,1)||$2})));
  }
  # link: [[url|{{url}}]]
  elsif (m/\G\[\[$FullUrlPattern\s*\|\{\{$FullUrlPattern\s*(\|.+?)?\}\}\]\]/cgos) {
    return GetCreoleImageHtml(
      $q->a({-href=> $1, -class=> 'image outside'},
      $q->img({-src=> $2,
         -class=> 'url outside',
         -alt=> substr($3,1)})));
  }
  # link: [[url]] and [[url|text]]
  elsif (m/\G\[\[$FullUrlPattern(\s*\|\s*([^\]]+?))?\]\]/cgos) {
    # Permit embedding of Creole syntax within link text. (Rather complicated,
    # but it does the job remarkably.)
    my $link_url  = $1;
    my $link_text = $3 ? CreoleRuleRecursive($3, @_) : $link_url;

    # GetUrl() takes parameters resembling:
    # ~ the link's URL.
    # ~ the link's text (to be displayed for that URL).
    # ~ a boolean (to be used Gods' know how).
    return GetUrl($link_url, $link_text, 1);
  }
  # link: [[page]] and [[page|text]]
  elsif (m/\G(\[\[$FreeLinkPattern(\s*\|\s*([^\]]+?))?\]\])/cgos) {
    Dirty($1);

    # Permit embedding of Creole syntax within link text. (Rather complicated,
    # but it does the job remarkably.)
    my $page_name = $2;
    my $link_text = $4 ? CreoleRuleRecursive($4, @_) : '';

    return GetPageOrEditLink($page_name, $link_text, 0, 1);
  }
  #TODO: Handle interwiki links, here, as well, so as to permit embedding of
  #Creole syntax within interwiki link text. That's a bit more work, though; so
  #we'll leave it for a slower day.
  #
  # Table syntax is matched last (or nearly last), so as to allow other Creole-
  # specific syntax within tables.
  #
  # tables using | -- end of the table (two newlines) or row (one newline)
  elsif (InElement('table')) {
    # We know that this is the end of this table row, if we match:
    #  * an explicit "|" character followed by: a newline character and
    #    another "|" character; or
    #  * an explicit newline character followed by: a "|" character.
    #
    # That is to say, the "|" character terminating a table row is optional.
    #
    # In either case, the newline character signifies the end of this table
    # row and the "|" character that follows it signifies the start of a new
    # row. We avoid consuming the "|" character by matching it with a lookahead.
    if (m/\G([ \t]*\|)?[ \t]*\n(?=$CreoleTableCellPattern)/cg) {
      return CloseHtmlEnvironmentUntil('table').AddHtmlEnvironment('tr');
    }
    # If block level elements are allowed in table cells, we know that this is
    # the end of the table, if we match:
    #  * an explicit "|" character followed by: a newline character not
    #    followed by another "|" character, or an implicit end-of-page.
    #
    # Otherwise, we know that this is the end of the table, if we match:
    #  * an explicit "|" character followed by: a newline character not
    #    followed by another "|" character, or an implicit end-of-page; or
    #  * two newline characters.
    #
    # This condition should appear after the end-of-row test, above.
    elsif (m/\G[ \t]*\|[ \t]*(\n|$)/cg or
           (!$CreoleTableCellsAllowBlockLevelElements and m/\G[ \t]*\n\n/cg)) {
      return CloseHtmlEnvironmentsCreoleOld().AddHtmlEnvironment('p');
    }
    # Lastly, we know this this is start of a new table cell (and possibly also
    # the end of the last table cell), if we match:
    #  * an explicit "|" character.
    #
    # This condition should appear after the end-of-table test, above.
    elsif (m/\G$CreoleTableCellPattern/cg) {
      my $tag = $2 ? 'th' : 'td';
      my $column_span = length($1);
      my $is_right_justified = $3;

      # Now that we've retrieved all numbered matches, match another lookahead.
      my $is_left_justified = m/\G(?=.*?[ \t]+\|)/;
      my $attributes = $column_span == 1 ? '' : qq{colspan="$column_span"};

         if ($is_left_justified and
             $is_right_justified) { $attributes .= 'align="center"' }
      elsif ($is_right_justified) { $attributes .= 'align="right"' }
      # this is the default:
      # elsif ($is_left_justified) { $attributes .= 'align="left"' }

      return
         (InElement('td') || InElement('th') ? CloseHtmlEnvironmentUntil('tr') : '')
        .AddHtmlEnvironment($tag, $attributes);
    }
  }
  # tables using | -- an ordinary table cell
  #
  # Please note that order is important, here; this should appear after all
  # markup dependent on being in a current table.
  #
  # Also, the "|" character also signifies the start of a new table cell. Thus,
  # we avoid consuming that character by matching it with a lookahead.
  elsif ($bol and m/\G(?=$CreoleTableCellPattern)/cg) {
    return OpenHtmlEnvironment('table', 1, 'user').AddHtmlEnvironment('tr');
  }

  return undef;
}

sub CreoleHeadingRule {
  # = to ====== for h1 to h6
  if ($bol && m/\G(\s*\n)*(=+)[ \t]*(.*?)[ \t]*=*[ \t]*(\n|\Z)/cg) {
    my $depth = length($2);
    my $text = $3;

    return CloseHtmlEnvironments()
      .($depth > 6
        ? qq{<h6 class="h${depth}">${text}</h6>}
        : qq{<h${depth}>${text}</h${depth}>})
      .AddHtmlEnvironment('p');
  }

  return undef;
}

sub CreoleListAndNewLineRule {
  my $is_in_list_item = InElement('li');

  # * bullet list (nestable; needs space when nested to disambiguate from bold)
  # - bullet list (not nestable; always needs space)
  if (($bol and (m/\G\s*(\*)[ \t]*/cg or m/\G\s*(-)[ \t]+/cg)) or
      ($is_in_list_item and
       (m/\G\s*\n[ \t]*(\*+)[ \t]+/cg or m/\G\s*\n[ \t]*(-)[ \t]+/cg))) {
    return
      ($is_in_list_item ? CloseHtmlEnvironmentUntil('li') : CloseHtmlEnvironments())
      .OpenHtmlEnvironment('ul', length($1))
      .AddHtmlEnvironment('li');
  }
  # # number list
  elsif (($bol             and m/\G\s*(#)[ \t]*/cg) or
         ($is_in_list_item and m/\G\s*\n[ \t]*(#+)[ \t]*/cg)) {
    return
      ($is_in_list_item ? CloseHtmlEnvironmentUntil('li') : CloseHtmlEnvironments())
      .OpenHtmlEnvironment('ol', length($1))
      .AddHtmlEnvironment('li');
  }
  # paragraphs: at least two newlines
  elsif (m/\G\s*\n(\s*\n)+/cg) {
    return CloseHtmlEnvironments().AddHtmlEnvironment('p');
  }
  # line break: one newline or explicit "\\"
  #
  # Note, single newlines not matched by this conditional will be converted into
  # a single space. (In general, this is what you want.)
  elsif (($CreoleLineBreaks and m/\G\s*\n/cg) or m/\G\\\\(\s*\n?)/cg) {
    return $q->br();
  }
  return undef;
}

# ....................{ FUNCTIONS                          }....................
*CloseHtmlEnvironmentsCreoleOld = *CloseHtmlEnvironments;
*CloseHtmlEnvironments =          *CloseHtmlEnvironmentsCreole;

=head2 CloseHtmlEnvironmentsCreole

Closes HTML environments for the current block level element, up to but not
including the "</table>" for the current block level element, if this block is
embedded within a blockquote or table. This, though kludgy, is the "code magic"
permitting block level elements in multi-line table cells.

=cut
sub CloseHtmlEnvironmentsCreole {
  # O.K.; this is a bit complex. If we're not currently in a table cell, simply
  # close HTML environments as expected. If we are in such a table cell, we must
  # close it if and only if we're currently at the end-of-page. (Table cells are
  # closed explicitly by embedding the closing "|" in the page.)
  #
  # How do we know when we're at the end-of-page? When "pos()", a Perl built-in
  # returning the string position of the current "\G" match, returns the length
  # of that string.
  if ($CreoleTableCellsAllowBlockLevelElements and pos() < length($_)) {
       if (InElement('td')) { return CloseHtmlEnvironmentUntil('td'); }
    elsif (InElement('th')) { return CloseHtmlEnvironmentUntil('th'); }
  }

  return CloseHtmlEnvironmentsCreoleOld();
}

=head2 AddOrCloseCreoleEnvironment

Adds or closes the HTML environment corresponding to the passed HTML tag, as
needed. Specifically, if that environment is already opened, this function
closes it; otherwise, this function adds it.

=cut
sub AddOrCloseCreoleEnvironment {
  my $html_tag = shift;
  return InElement($html_tag)
    ? CloseHtmlEnvironmentUntil($html_tag).CloseHtmlEnvironment()
    : AddHtmlEnvironment       ($html_tag);
}

=head2 CreoleRuleRecursive

Calls C<CreoleRule> on the passed string, from within some existing call to
C<CreoleRule>. This function ensures, among other safeties, that the
C<CreoleRule> function is not recursed into more than once.

=cut
sub CreoleRuleRecursive {
  my     $markup = shift;
  return $markup if $CreoleRuleRecursing;  # avoid infinite loops
              local $CreoleRuleRecursing = 1;
              local $bol = 0;  # prevent block level element handling

  my ($oldpos, $old_) = (pos, $_);
  my ($html, $html_creole) = ('', '');

  $_ = $markup;

  # The contents of this loop are, in part, hacked from the guts of Oddmuse's
  # ApplyRules() function.
  while (1) {
    if ($html_creole = CreoleRule(@_) or
       ($is_creoleaddition_installed and  # try "creoleaddition.pl", too.
        $html_creole = CreoleAdditionRule(@_))) {
      $html .= $html_creole;
    }
    elsif (m/\G&amp;([a-z]+|#[0-9]+|#x[a-fA-F0-9]+);/cg) { # entity references
      $html .= "&$1;";
    }
    elsif (m/\G\s+/cg) {
      $html .= ' ';
    }
    elsif (   m/\G([A-Za-z\x80-\xff]+([ \t]+[a-z\x80-\xff]+)*[ \t]+)/cg
           or m/\G([A-Za-z\x80-\xff]+)/cg
           or m/\G(\S)/cg) {
      $html .= $1;    # multiple words but do not match http://foo}
    }
    else { last; }
  }

  ($_, pos) = ($old_, $oldpos);   # restore \G (assignment order matters!)

  $CreoleRuleRecursing = 0;
  return $html;
}

sub GetCreoleImageHtml {
  my $image_html = shift;
  return
    ($bol ? CloseHtmlEnvironments().AddHtmlEnvironment('p', 'class="image"') : '')
    .$image_html;
}

# sub GetCreoleTableCellHtml {
#   my ($span, $left, $right) = @_;
#   my  $table_cell_attributes = '';

#   $table_cell_attributes = "colspan=\"$span\"" if ($span != 1);
#   m/\G(?=.*?([ \t]*)\|)/ and $right = $1 unless $right;
#   $table_cell_attributes .= ' ' if ($table_cell_attributes and ($left or $right));

#      if ($left and $right) { $table_cell_attributes .= 'align="center"' }
#   elsif ($left)            { $table_cell_attributes .= 'align="right"' }
#   # this is the default:
#   # elsif ($right) { $table_cell_attributes .= 'align="left"' }

#   return
#      (InElement('table') ? '' : OpenHtmlEnvironment('table', 1, 'user'))
#     .(InElement('tr')
#       ? (InElement('td') || InElement('th') ? CloseHtmlEnvironmentUntil('tr') : '')
#       :  AddHtmlEnvironment('tr'))
#     .AddHtmlEnvironment(($2 ? 'th' : 'td'), $table_cell_attributes);
# }

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008       by Brian Curry <http://raiazome.com>.
Copyright 2008       by Weakish Jiang <weakish@gmail.com>.
Copyright 2006, 2007 by Alex Schroeder <alex@gnu.org>.

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
