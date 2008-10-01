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

$ModulesDescription .= '<p>$Id: creole.pl,v 1.44 2008/10/01 07:54:44 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

creole is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($CreoleLineBreaks $CreoleTildeAlternative);

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

# ....................{ MARKUP                             }....................
push(@MyRules,
     \&CreoleRule,
     \&CreoleHeadingRule,
     \&CreoleListAndNewLineRule,
    );

# [[link|{{Image:foo}}]] conflicts with default link rule.
$RuleOrder{\&CreoleRule} = -10;
# == headings rule must come after the TocRule.
$RuleOrder{\&CreoleHeadingRule} = 100;
# List items must come later than MarkupRule because *foo* at the
# beginning of a line should be bold, not the list item foo*. Also,
# newlines must come after list items, otherwise this will add a lot
# of useless "</br>" tags.
$RuleOrder{\&CreoleListAndNewLineRule} = 180;

=head2 ListRule

Oddmuse's default C<ListRule> function conflicts with this extension's
C<CreoleListAndNewLineRule> function. We effectively "delete" the former
function, therefore, by simply making it return nothing.

=cut
sub ListRule { return undef; }

sub CreoleRule {
  # escape next char (and prevent // in URLs from enabling italics)
  # ~
  if (m/\G(~($FullUrlPattern|\S))/cgo) {
    if ($CreoleTildeAlternative
  and index('ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      . 'abcdefghijklmnopqrstuvwxyz'
      . '0123456789', $2) != -1) {
      return $1; # tilde stays
    } else {
      return $2; # tilde disappears
    }
  }
  # horizontal line
  # ----
  elsif ($bol && m/\G(\s*\n)*[ \t]*----+[ \t]*\n?/cg
      or m/\G\s*\n----+[ \t]*\n?/cg) {
    return CloseHtmlEnvironments().$q->hr().AddHtmlEnvironment('p');
  }
  # **bold**
  elsif (m/\G\*\*/cg) { return AddOrCloseCreoleEnvironment('strong'); }
  # //italic//
  elsif (m/\G\/\//cg) { return AddOrCloseCreoleEnvironment('em'); }
  # {{{
  # preformatted
  # }}}
  elsif ($bol && m/\G\{\{\{[ \t]*\n(.*?\n)\}\}\}[ \t]*(\n|\z)/cgs) {
    my $str = $1;
    $str =~ s/\n }}}/\n}}}/g;
    return CloseHtmlEnvironments()
      .$q->pre({-class=> 'real'}, $str)
      .AddHtmlEnvironment('p');
  }
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
      $q->img({-src=> $2,
               -class=> 'url outside',
               -alt=> substr($3,1)}));
  }
  # link: [[url]] and [[url|text]]
  elsif (m/\G\[\[$FullUrlPattern\s*(\|\s*([^]]+))?\]\]/cgos) {
    return GetUrl($1, $3||$1, 1);
  }
  # Table syntax is matched last (or nearly last), so as to allow other Creole-
  # specific syntax within tables.
  #
  # tables using | -- end of the table (two newlines) or row (one newline)
  elsif (InElement('table') and m/\G[ \t]*\|[ \t]*(\n)?(\n|$)/cg) {
    return $1
      # end of the table (two newlines)
      ? CloseHtmlEnvironmentsCreoleOld().AddHtmlEnvironment('p')
      # end of the row (one newline)
      : CloseHtmlEnvironmentUntil('table');
  }
  # tables using | -- an ordinary table cell
  elsif (m/\G[ \t]*(\|+)(=)?([ \t]*)/cg) {
    return
       (InElement('table') ? '' : OpenHtmlEnvironment('table', 1, 'user'))
      .(InElement('tr')
        ? (InElement('td') || InElement('th') ? CloseHtmlEnvironmentUntil('tr') : '')
        :  AddHtmlEnvironment('tr'))
          .AddHtmlEnvironment(($2 ? 'th' : 'td'),
                              GetCreoleTableHtmlAttributes(length($1), $3));
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
     if (InElement('td')) { return CloseHtmlEnvironmentUntil('td'); }
  elsif (InElement('th')) { return CloseHtmlEnvironmentUntil('th'); }
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

sub GetCreoleImageHtml {
  my $image_html = shift;
  return
    ($bol ? CloseHtmlEnvironments().AddHtmlEnvironment('p', 'class="image"') : '')
    .$image_html;
}

sub GetCreoleTableHtmlAttributes {
  my ($span, $left, $right) = @_;
  my $attr = '';

  $attr = "colspan=\"$span\"" if ($span != 1);
  m/\G(?=.*?([ \t]*)\|)/ and $right = $1 unless $right;
  $attr .= ' ' if ($attr and ($left or $right));

  if ($left and $right) { $attr .= 'align="center"' }
  elsif ($left) { $attr .= 'align="right"' }
  # this is the default:
  # elsif ($right) { $attr .= 'align="left"' }

  return $attr;
}

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
