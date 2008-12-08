#!/usr/bin/env perl
# ====================[ toc.pl                             ]====================

=head1 NAME

toc - An Oddmuse module for adding a "Table of Contents" to Oddmuse Wiki pages.

=head1 INSTALLATION

toc is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
$ModulesDescription .= '<p>$Id: toc.pl,v 1.60 2008/12/08 01:13:16 as Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

toc is easily configurable; set these variables in the B<wiki/config.pl> file
for your Oddmuse Wiki.

=cut
use vars qw($TocHeaderText
            $TocClass
            $TocAutomatic
            $TocAnchorPrefix

            $TocIsApplyingAutomaticRules);

=head2 $TocHeaderText

The string to be displayed as the header for each page's table of contents.

=cut
$TocHeaderText = 'Contents';

=head2 $TocClass

The string to be used as the HTML class for each page's table of contents. (This
is the string with which your CSS stylesheet customizes table of contents.)

=cut
$TocClass = 'toc';

=head2 $TocAutomatic

A boolean that, if true, automatically prepends the table of contents to the
first header for a page or, if false, does not. If false, you must explicitly
add the table of contents to each page for which you'd like one by explicitly
adding the "<toc>" markup to that page.

By default, this boolean is true.

=cut
$TocAutomatic = 1;

=head2 $TocAnchorPrefix

The string for prefixing the names of toc anchor links with. The default
should be fine, generally; it creates toc anchor links resembling:

=over

=item L<http://your.wiki.com/SomePage#Heading1>. A link to the first header on
      SomePage page for some wiki.

=item L<http://your.wiki.com/SomePage#Heading2>. A link to the second header on
      SomePage page for some wiki.

=back

And so on. This provides Wiki users a "clean" mechanism for bookmarking,
marking, and sharing links to particular segments of a Wiki page.

=cut
$TocAnchorPrefix = 'Heading';

=head2 $TocIsApplyingAutomaticRules

A boolean that, if true, performs a few "automatic" rules on behalf of this
extension. These are:

=over

=item Add a unique C<id="${ID}"> attribute to each header tag on every page.
      This ensures that every link in the table of contents, for every page,
      refers to one and only one header tag in that page.

=item Add an automatic table of contents to every page, if the
      C<$TocAutomatic> boolean is also enabled.

=back

By default, this boolean is true. (This is a good thing. Unless you know what
you're doing, you should probably leave this as is.)

=cut
$TocIsApplyingAutomaticRules = 1;

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&TocInit);

# A number uniquely identifying this current header. This allows us to link each
# list entry in the table of contents to the header it refers to.
my $TocHeaderNumber;

sub TocInit {
  $TocHeaderNumber = '';
}

# ....................{ MARKUP                             }....................
*RunMyRulesTocOld = *RunMyRules;
*RunMyRules       = *RunMyRulesToc;

push(@MyRules, \&TocRule);

=head2 MARKUP

toc handles page markup resembling:

  <toc header_text="$HeaderText" class="$Class">

Or, in its abbreviated form:

  <toc "$HeaderText" "$Class">

Or, in its maximally abbreviated form:

  <toc>

C<$HeaderText> is the header text for this table of contents: that is, text
heading the list of this table of contents. This is optional. If not specified,
it defaults to the value of the C<$TocHeaderText> variable.

C<$Class> is the HTML class for this table of contents, for CSS stylization of
that table. This is optional. If not specified, it defaults to "toc".

=cut
sub TocRule {
  # <toc...> markup. This explicitly displays a table of contents at this point.
  if ($bol and
      m~\G&lt;toc(/([A-Za-z\x80-\xff/]+))?    # $1
        (\s+(?:header_text\s*=\s*)?"(.+?)")?  # $3
        (\s+(?:class\s*=\s*)?"(.+?)")?        # $5
        &gt;[ \t]*(\n|$)~cgx) {               # $7
    my ($toc_class_old, $toc_header_text, $toc_class) = ($2, $4, $6);

    $TocHeaderNumber = 1;
    $toc_header_text = $TocHeaderText if not defined $toc_header_text;

    # A backwards-compatibility fix! Antiquated versions of this module
    # accepted markup resembling:
    #   <toc/${CLASS_NAME_1}/${CLASS_NAME_2}/...>
    #
    # which this conditional converts to the more conventional:
    #   <toc class="${CLASS_NAME_1} ${CLASS_NAME_2} ...">
    if ($toc_class_old) {
      $toc_class = $toc_class_old;
      $toc_class =~ tr~/~ ~;
    } $toc_class = $TocClass.($toc_class ? ' '.$toc_class : '');

    # If the topmost HTML tag is a paragraph, then the table of contents will
    # be the first child element of that paragraph; however, embedding that
    # table in a paragraph is quite unnecessary, and even obstructs our
    # CSS stylization of that table elsewhere. In this case, we close this
    # paragraph; this ensures that paragraph will have no content and
    # therefore be removed, later, by the Oddmuse engine. This is slightly
    # hacky -- but sufficiently necessary.
    return ($HtmlStack[0] eq 'p' ? CloseHtmlEnvironment() : '')
      .qq{<!-- toc header_text="$toc_header_text" class="$toc_class" -->}
      .AddHtmlEnvironment('p');
  } return undef;
}

=head2 RunMyRulesToc

Automates insertion of the <toc ...> markup for Wiki pages not explicitly
specifying it. This searches the current page's HTML output for the first HTML
header tag for that page and, when found, automatically inserts <toc ...> markup
immediately before that tag.

=cut
sub RunMyRulesToc {
  my $html = RunMyRulesTocOld(@_);

  # Some markup rule converted the input Wiki markup into HTML. If this HTML is
  # an HTML header tag, then we add a new "id" tag attribute to it (so as to
  # uniquely identify it for later linking to from the table of contents).
  # to the user, without embellishments or change.
  if ($TocIsApplyingAutomaticRules and $html) {
    if ($TocAutomatic and not $TocHeaderNumber and $bol and $html =~
      s~(<h[1-6][^>]*>)
       ~<!-- toc header_text="$TocHeaderText" class="$TocClass" -->$1~x) {
      $TocHeaderNumber = 1;
    }

    # If we've seen at least one HTML header and we're not currently in the
    # sidebar (as is the odd case when $TocPageName ne $OpenPageName), then
    # add a unique identifier to all (possible) HTML headers in this string.
    if ($TocHeaderNumber) {
      # To avoid infinite substitution recursion, we avoid matching header tags
      # already having id attributes. Unfortunately, I'm not as adept a regular
      # expression wizard as I should be, and was unable to get a negative
      # lookahead expression resembling (?!\s+id=".*?") to work. As such, I
      # use a simple negative character class hack. *shrug*
      while ($html =~ s~<h([1-6](\s+[^i]\w+\s+=\s+"[^"]")*)>
        ~<h$1 id="$TocAnchorPrefix$TocHeaderNumber">~cgx) {
        $TocHeaderNumber++;
      }
    }
  }

  return $html;
}

# ....................{ MARKUP =after                      }....................
my $TocCommentPattern = qr~\Q<!-- toc\E.*?\Q -->\E~;

*OldTocApplyRules = *ApplyRules;
*ApplyRules = *NewTocApplyRules;

# This changes the entire rendering engine such that it no longer
# prints output as it goes along. Instead all the output is collected
# in $html, post-processed by inserting the table of contents where
# appropriate, and then printed at the very end.
sub NewTocApplyRules {
  my ($html, $blocks, $flags);
  {
    local *STDOUT;
    open(  STDOUT, '>', \$html) or die "Can't open memory file: $!";
    ($blocks, $flags) = OldTocApplyRules(@_);
    close  STDOUT;
  }
  # If there are at least two HTML headers on this page, insert a table of
  # contents.
  if ($TocHeaderNumber > 2) {
    $html =~ s~\Q<!-- toc header_text="\E([^"]+)\Q" class="\E([^"]+)\Q" -->\E~
      GetTocHtml(\$html, \$blocks, $1, $2)~ge;
  }
  # Otherwise, remove the table of contents placeholder comments.
  else {
    $html   =~ s~$TocCommentPattern~~g;
    $blocks =~ s~$TocCommentPattern~~g;
  }
  print $html;
  return ($blocks, $flags);
}

sub GetTocHtml {
  my ($html_, $blocks_, $toc_header_text, $toc_class) = @_;
  my $toc_html =
     $q->start_div({-class=> $toc_class})
    .$q->h2(T($toc_header_text));

  # This forces evaluation of the "while ($list_depth < $header_depth) {"
  # clause on the first iteration of the outer while loop. Yes: trust us.
  my $list_depth = 0;

  while ($$html_ =~ m~<h([1-6])[^>]* id="($TocAnchorPrefix\d+)">(.*?)</h\1>~cg) {
    my ($header_depth, $header_id, $header_text) = ($1, $2, $3);

    # Strip all links from header text. (They unnecessarily convolute the
    # interface, since the header text is already embedded in a link to the
    # appropriate header in the dialogue script's body.)
    $header_text =~ s~<a[^>]*>(.*?)</a>~$1~;

    # By Usemod convention, all headers begin with depth 2. This algorithm,
    # however, expects headers to begin with depth 1. Thus, to "streamline"
    # things, we transform it appropriately. ;-)
    if (defined &UsemodRule) { $header_depth--; }

    # If this is the first header and if this header's depth is deeper than 1,
    # we manually clamp this header's depth to 1 so as to ensure the first list
    # item in the first ordered list resides at depth 1. (Failure to do this
    # produces very odd ordered lists.)
    if (not $list_depth and $header_depth > 1) { $header_depth = 1; }

    # Close ordered lists and list items for prior headings deeper than this
    # heading's depth.
    while ($list_depth > $header_depth) {
           $list_depth--;
      $toc_html .= '</li></ol>';
    }

    # If the current ordered list is at this heading's depth, add this heading
    # as a list item to that list.
    if ($list_depth == $header_depth) {
      $toc_html .= '</li><li>';
    }
    # Otherwise, add ordered lists and list items until at this heading's depth.
    else {
      while ($list_depth < $header_depth) {
             $list_depth++;
        $toc_html .= '<ol><li>';
      }
    }

    $toc_html .= "<a href=\"#$header_id\">$header_text</a>";
  }

  # Close ordered lists and list items for the last heading.
  while ($list_depth--) { $toc_html .= '</li></ol>'; }

  $toc_html .= $q->end_div();

  # Lastly, perform the same replacement on the cached version of this clean
  # block. (Failure to do this would ensure the first creation of this page
  # would emit the proper HTML, but all subsequent refreshings of this page
  # the improperly cached version.)
  $$blocks_ =~ s~$TocCommentPattern~$toc_html~;

  return $toc_html;
}

=head1 TODO

This extension no longer cleanly integrates with the Sidebar extension, since
this extension now prints the table of contents for a page after having printed
all other content for that page (rather than while printing all content for that
page, as was previously the case).

This is not correctable, unfortunately. The simplest solution is to suggest that
current Sidebar users migrate to the Crossbar module -- and that is where I
leave it.

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008                   by B.w.Curry <http://www.raiazome.com>.
Copyright 2004, 2005, 2006, 2007 by Alex Schroeder <alex@emacswiki.org>.

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
