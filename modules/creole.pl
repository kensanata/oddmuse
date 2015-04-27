#!/usr/bin/env perl
use strict;

# ====================[ creole.pl                          ]====================

=head1 NAME

creole - An Oddmuse module for marking up Oddmuse Wiki pages according to the
         Wiki Creole standard, a Wiki-agnostic syntax scheme.

=head1 INSTALLATION

creole is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
AddModuleDescription('creole.pl', 'Creole Markup Extension');

our ($q, $bol, %InterSite, $FullUrlPattern, $FreeLinkPattern, $FreeInterLinkPattern, $InterSitePattern, @MyRules, %RuleOrder, @MyInitVariables, @HtmlStack, @HtmlAttrStack);

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

creole is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
our ($CreoleLineBreaks,
            $CreoleTildeAlternative,
            $CreoleTableCellsContainBlockLevelElements,
            $CreoleDashStyleUnorderedLists);

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

=head2 $CreoleTableCellsContainBlockLevelElements

A boolean that, if true, permits table cell markup to embed block level
elements in table cells. (By default, this boolean is false.)

You are encouraged to enable this boolean, as it significantly improves the
"stuff" you can do with Wiki Creole table syntax. For example, enabling this
boolean permits you to embed nested lists in tables.

Block level elements are such "high-level" entities as paragraphs, blockquotes,
list items, and so on. Thus, enabling this boolean permits you to embed multiple
paragraphs, blockquotes, and so on in individual table cells.

Please note: enabling this boolean permits non-conformant syntax -- that is,
syntax which no longer conforms to the Wiki Creole standard. (In general,
unless you have significant amounts of Wiki Creole table markup strictly
conforming to the Wiki Creole standard, this shouldn't be an issue.)

Please note: enabling this boolean also requires you explicitly close the last
table cell of a cell with a "|" character. (This character is optional under
the Wiki Creole standard, but not under this non-conformant alteration.)

=cut
$CreoleTableCellsContainBlockLevelElements = 0;

=head2 $CreoleDashStyleUnorderedLists

A boolean that, if true, permits unordered list items to be prefixed with either
a '-' dash or an '*' asterisk or, if false, requires unordered list items to be
prefixed with an '*' asterisk, only. (By default, this boolean is false.)

Please note: enabling this boolean permits non-conformant syntax -- that is,
syntax which no longer conforms to the Wiki Creole standard. Unless your Wiki
requires it, you are encouraged not to set this boolean.

=cut
$CreoleDashStyleUnorderedLists = 0;

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&CreoleInit);

# A boolean that is true if the "creoleaddition.pl" module is also installed.
my $CreoleIsCreoleAddition;

# A boolean set by CreoleRule() to true, if a new table cell has just been
# started. This allows testing, elsewhere, of whether we are at the start of a
# a new table cell. Why test that? Because. If we are indeed at the start of a
# a new table cell, we should behave as if the "$bol" boolean is true: we should
# allow block level elements at the start of this new table cell.
#
# Of course, we have to set this to false immediately after matching past the
# start of that table cell. This is what RunMyRulesCreole() does.
my $CreoleIsTableCellBol;

# A regular expression matching Wiki Creole-style table cells.
my $CreoleTableCellPattern = '[ \t]*(\|+)(=)?\n?([ \t]*)';

# A regular expression matching Wiki Creole-style pipe delimiters in links.
my $CreoleLinkPipePattern = '[ \t]*\|[ \t]*';

# A regular expression matching Wiki Creole-style link text. This expression
# takes into account the fact that such text is always optional.
my $CreoleLinkTextPattern = "($CreoleLinkPipePattern(.+?))?";

# The html tag and string of html tag attributes for the current Creole header.
# This prevents an otherwise necessary, costly evaluation of test statements
# resembling:
#
#  if (InElement('h1') or InElement('h2') or InElement('h3') or
#      InElement('h4') or InElement('h5') or InElement('h6')) { ... }
#
# As Creole headers cannot span blocks or lines, this should be a safe caching.
my ($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr);

sub CreoleInit {
  $CreoleIsCreoleAddition = defined &CreoleAdditionRule;

  $CreoleIsTableCellBol =
  $CreoleHeaderHtmlTag =
  $CreoleHeaderHtmlTagAttr = '';

  # This is the "code magic" enabling block-level elements in multi-line
  # table cells.
  if ($CreoleTableCellsContainBlockLevelElements) {
    SetHtmlEnvironmentContainer('td');
    SetHtmlEnvironmentContainer('th');
  }

  # FIXME: The following changes interfere with the bbcode extension.
  # To achieve something similar, we often see sites with an InterMap
  # entry called Self, eg. from http://emacswiki.org/InterMap: Self
  # /cgi-bin/emacs? -- which allows you to link to Self:action=index.

  # Permit page authors to link to URLs resembling:
  #   "See [[/?action=index|the site map]]."
  #
  # Which Oddmuse converts to HTML resembling:
  #   "See <a href="/?action=index">the site map</a>."
  #
  # When not using this extension, authors must add this Wiki's base URL:
  #  "See [[http://www.oddmuse.com/cgi-bin/oddmuse?action=index|the site map]]."
  # my $UrlChars = '[-a-zA-Z0-9/@=+$_~*.,;:?!\'"()&#%]';    # see RFC 2396
  # $FullUrlPattern = "((?:$UrlProtocols:|/)$UrlChars+)";

  # Permit page authors to link to other pages having semicolons in their names.
  # my $LinkCharsSansZero = "-;,.()' _1-9A-Za-z\x{0080}-\x{fffd}";
  # my $LinkChars = $LinkCharsSansZero.'0';
  # $FreeLinkPattern = "([$LinkCharsSansZero]|[$LinkChars][$LinkChars]+)";
}

# ....................{ MARKUP                             }....................
push(@MyRules,
     \&CreoleRule,
     \&CreoleHeadingRule,
     \&CreoleListAndNewLineRule);

# Creole link rules conflict with Oddmuse's default LinkRule.
$RuleOrder{\&CreoleRule} = -10;
# Creole heading rules must come after the TocRule.
$RuleOrder{\&CreoleHeadingRule} = 100;
# List items must come later than MarkupRule because *foo* at the
# beginning of a line should be bold, not the list item foo*. Also,
# newlines must come after list items, otherwise this will add a lot
# of useless "</br>" tags.
$RuleOrder{\&CreoleListAndNewLineRule} = 180;
# Oddmuse's built-in ListRule conflicts with above CreoleListAndNewLineRule.
# Thus, we ensure the latter is applied before the former.
$RuleOrder{\&ListRule} = 190;

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
  my ($is_interlinking, $is_intraanchoring) = @_;

  # horizontal rule
  # ----
  if ($bol && m/\G[ \t]*----[ \t]*(\n|$)/cg) {
    return CloseHtmlEnvironments().$q->hr().AddHtmlEnvironment('p');
  }
  # {{{
  # nowiki block
  # }}}
  elsif ($bol && m/\G\{\{\{[ \t]*\n(.*?)\n\}\}\}[ \t]*(\n|$)/cgs) {
    my $str = $1;
    return CloseHtmlEnvironments()
      .$q->pre({-class=> 'real'}, $str)
        .AddHtmlEnvironment('p');
  }
  # escape next char (and prevent // in URLs from enabling italics)
  # ~
  elsif (m/\G(~($FullUrlPattern|\S))/cgo) {
    return
      ($CreoleTildeAlternative and
       index( 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
             .'abcdefghijklmnopqrstuvwxyz'
             .'0123456789', $2) != -1)
        ? $1  # tilde stays
        : $2; # tilde disappears
  }
  # **bold**
  elsif (m/\G\*\*/cg) { return AddOrCloseHtmlEnvironment('strong'); }
  # //italic//
  elsif (m/\G\/\//cg) { return AddOrCloseHtmlEnvironment('em'); }
  # {{{preformatted code}}}
  elsif (m/\G\{\{\{(.*?}*)\}\}\}/cg) { return $q->code($1); }
  # download: {{pic}} and {{pic|text}}
  elsif (m/\G(\{\{$FreeLinkPattern$CreoleLinkTextPattern\}\})/cgos) {
    my $text = $4 || $2;
    return GetCreoleLinkHtml($1, GetDownloadLink(FreeToNormal($2), 1, undef, $text), $text);
  }
  # image link: {{url}} and {{url|text}}
  elsif (m/\G\{\{$FullUrlPattern$CreoleLinkTextPattern\}\}/cgos) {
    return GetCreoleImageHtml(
      $q->a({-href=> UnquoteHtml($1),
             -class=> 'image outside'},
            $q->img({-src=> UnquoteHtml($1),
                     -alt=> UnquoteHtml($3),
                     -title=> UnquoteHtml($3),
                     -class=> 'url outside'})));
  }
  # image link: [[link|{{pic}}]] and [[link|{{pic|text}}]]
  elsif (m/\G(\[\[$FreeLinkPattern$CreoleLinkPipePattern
              \{\{$FreeLinkPattern$CreoleLinkTextPattern\}\}\]\])/cgosx) {
    my $text = $5 || $2;
    return GetCreoleLinkHtml($1, GetCreoleImageHtml(
      ScriptLink(UrlEncode(FreeToNormal($2)),
                 $q->img({-src=> GetDownloadLink(FreeToNormal($3), 2),
                          -alt=> UnquoteHtml($text),
                          -title=> UnquoteHtml($text),
                          -class=> 'upload'}), 'image')), $text);
  }
  # image link: [[link|{{url}}]] and [[link|{{url|text}}]]
  elsif (m/\G(\[\[$FreeLinkPattern$CreoleLinkPipePattern
              \{\{$FullUrlPattern$CreoleLinkTextPattern\}\}\]\])/cgosx) {
    my $text = $5 || $2;
    return GetCreoleLinkHtml($1, GetCreoleImageHtml(
      ScriptLink(UrlEncode(FreeToNormal($2)),
                 $q->img({-src=> UnquoteHtml($3),
                          -alt=> UnquoteHtml($text),
                          -title=> UnquoteHtml($text),
                          -class=> 'url outside'}), 'image')), $text);
  }
  # image link: [[url|{{pic}}]] and [[url|{{pic|text}}]]
  elsif (m/\G(\[\[$FullUrlPattern$CreoleLinkPipePattern
              \{\{$FreeLinkPattern$CreoleLinkTextPattern\}\}\]\])/cgosx) {
    my $text = $5 || $2;
    return GetCreoleLinkHtml($1, GetCreoleImageHtml(
      $q->a({-href=> UnquoteHtml($2), -class=> 'image outside'},
            $q->img({-src=> GetDownloadLink(FreeToNormal($3), 2),
                     -alt=> UnquoteHtml($text),
                     -title=> UnquoteHtml($text),
                     -class=> 'upload'}))), $text);
  }
  # image link: [[url|{{url}}]] and [[url|{{url|text}}]]
  elsif (m/\G\[\[$FullUrlPattern$CreoleLinkPipePattern
             \{\{$FullUrlPattern$CreoleLinkTextPattern\}\}\]\]/cgosx) {
    return GetCreoleImageHtml(
      $q->a({-href=> UnquoteHtml($1), -class=> 'image outside'},
            $q->img({-src=> UnquoteHtml($2),
                     -alt=> UnquoteHtml($4),
                     -title=> UnquoteHtml($4),
                     -class=> 'url outside'})));
  }
  # link: [[url]] and [[url|text]]
  elsif (m/\G\[\[$FullUrlPattern$CreoleLinkTextPattern\]\]/cgos) {
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
  elsif (m/\G(\[\[$FreeLinkPattern$CreoleLinkTextPattern\]\])/cgos) {
    my $markup =    $1;
    my $page_name = $2;
    my $link_text = $4 ? CreoleRuleRecursive($4, @_) : $page_name;

    return GetCreoleLinkHtml($markup,
      GetPageOrEditLink($page_name, $link_text, 0, 1), $link_text);
  }
  # interlink: [[Wiki:page]] and [[Wiki:page|text]]
  elsif ($is_interlinking and
         m/\G(\[\[$FreeInterLinkPattern$CreoleLinkTextPattern\]\])/cgos) {
    my $markup =    $1;
    my $interlink = $2;
    my $interlink_text = $4;
    my ($site_name, $page_name) = $interlink =~ m~^($InterSitePattern):(.*)$~;

    # Permit embedding of Creole syntax within interlink text. We operate on
    # "$interlink_text", rather than "$4", since that ordinal has already been
    # overridden by the above regular expression match.
    $interlink_text =       $interlink_text
      ? CreoleRuleRecursive($interlink_text, @_)
      :  $q->span({-class=> 'site'}, $site_name)
        .$q->span({-class=> 'separator'}, ':')
        .$q->span({-class=> 'page'}, $page_name);

    # If the Wiki for this interlink is a registered Wiki (that is, it appears
    # in this Wiki's "$InterMap" page), then produce an interlink to it;
    # otherwise, produce a normal intralink to a page on this Wiki.
    return GetCreoleLinkHtml($markup,
        $InterSite{$site_name}
      ? GetInterLink     ($interlink, $interlink_text, 0, 1)
      : GetPageOrEditLink($page_name, $interlink_text, 0, 1), $interlink_text);
  }
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
           (!$CreoleTableCellsContainBlockLevelElements and m/\G[ \t]*\n\n/cg)) {
      # Note: we do not call "CloseHtmlEnvironmentsCreoleOld", as that function
      #       refers to the Oddmuse built-in. If another module with name
      #       lexically following "creole.pl" also redefines the built-in
      #       "CloseHtmlEnvironments" function, then calling the
      #       "CloseHtmlEnvironmentsCreoleOld" function causes that other
      #       module's redefinition to not be called. (Yes; an entangling mess
      #       we've made for ourselves, here. Clearly, this needs a rethink in
      #       some later Oddmuse refactoring.)
      return CloseHtmlEnvironment('table').AddHtmlEnvironment('p');
    }
    # Lastly, we know this this is start of a new table cell (and possibly also
    # the end of the last table cell), if we match:
    #  * an explicit "|" character.
    #
    # This condition should appear after the end-of-table test, above.
    elsif (m/\G$CreoleTableCellPattern/cg) {
      # This is the start of a new table cell. However, we only consider that
      # equivalent to the "$bol" variable when the
      # "$CreoleTableCellsContainBlockLevelElements" variable is enabled. (In
      # other words, we only declare that we may insert block level elements at
      # the start of this new table cell, when we allow block level elements in
      # table cells. Yum.)
      $CreoleIsTableCellBol = $CreoleTableCellsContainBlockLevelElements;

      my $tag = $2 ? 'th' : 'td';
      my $column_span = length($1);
      my $is_right_justified = $3;

      # Now that we've retrieved all numbered matches, match another lookahead.
      my $is_left_justified = m/\G(?=[^\n|]*?[ \t]+\|)/;
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

  return;
}

sub CreoleHeadingRule {
  # header opening: = to ====== for h1 to h6
  #
  # header opening and closing have been partitioned into two separate
  # conditional matches rather than congealed into one conditional match. Why?
  # Because, in so doing, we permit application of other markup rules,
  # elsewhere, to header text. This, in turn, permits insertion and
  # interpretation of complex markup in header text; e.g.,
  # == //This Is a **Level-2** Header %%Having Complex Markup%%.// ==
  if ($bol and m~\G(\s*\n)*(=+)[ \t]*~cg) {
    my $header_depth = length($2);
    ($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr) = $header_depth <= 6
      ? ('h'.$header_depth, '')
      : ('h6', qq{class="h$header_depth"});
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr);
  }
  # header closing: = to ======, newline, or EOF
  #
  # Note: partitioning this from the heading opening conditional, above,
  # typically causes Oddmuse to insert an extraneous space at the end of
  # header tags. This is non-dangerous, fortunately; and changes nothing.
  elsif ($CreoleHeaderHtmlTag and m~\G[ \t]*=*[ \t]*(\n|$)~cg) {
    my $header_html =
      CloseHtmlEnvironment($CreoleHeaderHtmlTag, '^'.$CreoleHeaderHtmlTagAttr.'$')
       .AddHtmlEnvironment('p');
    $CreoleHeaderHtmlTag = $CreoleHeaderHtmlTagAttr = '';
    return $header_html;
  }

  return;
}

sub CreoleListAndNewLineRule {
  my $is_in_list_item  = InElement('li');

  # # numbered list
  # * bullet list (nestable; needs space when nested to disambiguate from bold)
  if (($bol             and m/\G[ \t]*([#*])[ \t]*/cg) or
      ($is_in_list_item and m/\G[ \t]*\n+[ \t]*(#+)[ \t]*/cg) or
      ($is_in_list_item and m/\G[ \t]*\n+[ \t]*(\*+)[ \t]+/cg)) {
    # Note: the first line of this return statement is --not-- equivalent to:
    # "return CloseHtmlEnvironmentUntil('li')", as that line does not permit
    # modules overriding the CloseHtmlEnvironments() function to "have a say."
    return ($is_in_list_item ? CloseHtmlEnvironmentUntil('li') : CloseHtmlEnvironments())
      .OpenHtmlEnvironment(substr($1, 0, 1) eq '#' ? 'ol' : 'ul', length($1), '', 'ol|ul')
      .AddHtmlEnvironment('li');
  }
  # - bullet list (not nestable; always needs space)
  elsif ($CreoleDashStyleUnorderedLists and (
        ($bol and             m/\G[ \t]*(-)[ \t]+/cg) or
        ($is_in_list_item and m/\G[ \t]*\n+[ \t]*(-)[ \t]+/cg))) {
    return ($is_in_list_item ? CloseHtmlEnvironmentUntil('li') : CloseHtmlEnvironments())
      .OpenHtmlEnvironment('ul', length($1))
      .AddHtmlEnvironment ('li');
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

  return;
}

# ....................{ HTML                               }....................

=head2 GetCreoleImageHtml

Returns the passed HTML image, conditionally wrapped within an HTML paragraph
tag having an necessary image class when the passed HTML also represents such a
new paragraph. Difficult to explain, isn't she?

=cut
sub GetCreoleImageHtml {
  my $image_html = shift;
  return
    ($bol ? CloseHtmlEnvironments().AddHtmlEnvironment('p', 'class="image"') : '')
    .$image_html;
}

=head2 GetCreoleLinkHtml

Marks the passed HTML as a dirty block, unless this HTML belongs to an HTML
header tag. Such tags may not contain dirty blocks! Most Oddmuse modules using
header tags (e.g., "sidebar.pl", "toc.pl") require, as a caching efficiency,
header text to be clean. This is a nearly necessary efficiency, since
regeneration of markup for those modules is an often costly operation. (We
certainly don't want to regenerate the Table of Contents for each page having at
least one header having at least one dirty link whenever an external user browses
to that page!)

Thus, if in a header, this function cleans links out of the passed HTML and
returns the resultant HTML (to the current clean block). Otherwise, this
function appends the resultant HTML to a new dirty block, prints it, and returns
it. (This does not print the resultant HTML when clean, since clean blocks are
printed, automatically, by the next call to C<Dirty>.)

This function, lastly, accepts three function parameters. These are:

=over

=item C<$markup>. (This is the Wiki markup string to be marked as dirty when it
      is not embedded in a Creole header.)

=item C<$html>. (This is the HTML string to be marked as dirty when this HTML
      is not embedded in a Creole header.)

=item C<$text>. (This is the text string to be marked as clean when this HTML
      is embedded within a Creole header.)

=back

Creole functions, above, should **not** call the C<Dirty> function directly.
Rather, they should always call this function...with appropriate parameters.

=cut
sub GetCreoleLinkHtml {
  my ($markup, $html, $link_text) = @_;

  if ($CreoleHeaderHtmlTag) { return $link_text; }
  else {
    Dirty($markup);
    print $html;
    return '';
  }
}

# ....................{ FUNCTIONS                          }....................
*RunMyRulesCreoleOld = \&RunMyRules;
*RunMyRules =          \&RunMyRulesCreole;

=head2 RunMyRulesCreole

Runs all markup rules for the current block of page markup. This redefinition
ensures that the beginning of a table cell is considered the beginning of a
block-level element -- that, in other words, the C<$bol> global be set to 1.

If the C<$CreoleTableCellsContainBlockLevelElements> option is set to 0 (the
default), then this function is, effectively, a no-op - and just calls the
default C<RunMyRules> function.

=cut
sub RunMyRulesCreole {
  # See documentation for the "$CreoleIsTableCellBol" variable, above.
  my $creole_is_table_cell_bol_last = $CreoleIsTableCellBol;
  $bol = 1 if $CreoleIsTableCellBol;
  my $html = RunMyRulesCreoleOld(@_);
  $CreoleIsTableCellBol = '' if $creole_is_table_cell_bol_last;

  return $html;
}

=head2 CreoleRuleRecursive

Calls C<CreoleRule> on the passed string, from within some existing call to
C<CreoleRule>. This function ensures, among other safeties, that the
C<CreoleRule> function is not recursed into more than once.

=cut

our $CreoleRuleRecursing; # must have a variable to localize below

sub CreoleRuleRecursive {
  my     $markup = shift;
  return $markup if $CreoleRuleRecursing;  # avoid infinite loops
  local $CreoleRuleRecursing = 1; # use local for the mod_perl case
  local $bol = 0;  # prevent block level element handling

  # Preserve global variables.
  my ($oldpos, $old_) = (pos, $_);
  my @oldHtmlStack =     @HtmlStack;
  my @oldHtmlAttrStack = @HtmlAttrStack;

  # Reset global variables.
  $_ = $markup;
  @HtmlStack = @HtmlAttrStack = ();

  my ($html, $html_creole) = ('', '');

  # The contents of this loop are, in part, hacked from the guts of Oddmuse's
  # ApplyRules() function. We cannot simply call that function, as it "cleans"
  # the HTML converted from the text passed to it, rather than returns that
  # HTML.
  while (1) {
    if ($html_creole = CreoleRule(@_) or
       ($CreoleIsCreoleAddition and  # try "creoleaddition.pl", too.
        $html_creole = CreoleAdditionRule(@_))) {
      $html .= $html_creole;
    }
    elsif (m/\G&amp;([a-z]+|#[0-9]+|#x[a-fA-F0-9]+);/cg) { # entity references
      $html .= "&$1;";
    }
    elsif (m/\G\s+/cg) {
      $html .= ' ';
    }
    elsif (   m/\G([A-Za-z\x{0080}-\x{fffd}]+([ \t]+[a-z\x{0080}-\x{fffd}]+)*[ \t]+)/cg
           or m/\G([A-Za-z\x{0080}-\x{fffd}]+)/cg
           or m/\G(\S)/cg) {
      $html .= $1;  # multiple words but do not match http://foo
    }
    else { last; }
  }

  # Restore global variables, in reverse order.
  @HtmlAttrStack = @oldHtmlAttrStack;
  @HtmlStack =     @oldHtmlStack;
  ($_, pos) = ($old_, $oldpos);

  # Allow entrance into this function, again.
  $CreoleRuleRecursing = 0;

  return $html;
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
