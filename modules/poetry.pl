#!/usr/bin/env perl
# ====================[ poetry.pl                          ]====================

=head1 NAME

poetry - An Oddmuse module for adding poetry to Oddmuse pages.

=head1 SYNOPSIS

Poetry - particularly rhymically free, "free verse" poetry - tends to depend on
fanciful, often meaningful line-breaks, indentation, and whitespace, which
publication of that poetry must preserve. This extension preserves that.

=head1 INSTALLATION

poetry is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: poetry.pl,v 1.7 2008/12/23 04:42:52 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

poetry is easily configurable; set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($PoetryIsHandlingCreoleStyleMarkup
            $PoetryIsHandlingXmlStyleMarkup
            $PoetryHtmlTag);

=head2 $PoetryIsHandlingCreoleStyleMarkup

A boolean that, if true, enables handling of Creole-style markup. See
L<MARKUP> below. By default, this boolean is true.

=cut
$PoetryIsHandlingCreoleStyleMarkup = 1;

=head2 $PoetryIsHandlingXmlStyleMarkup

A boolean that, if true, enables handling of Xml-style markup. See
L<MARKUP> below. By default, this boolean is true.

=cut
$PoetryIsHandlingXmlStyleMarkup = 1;

=head2 $PoetryHtmlTag

A string having the HTML tag with which to markup poetry. By default, this is a
preformatted block with default class "poem", which produces HTML:

  <pre class="poem">
  Like this, a
  <em>poem</em> with default
  class <code>poem</code>.
  </pre>

Preformatted blocks cleanly preserve paragraph whitespace. However, if
preformatted blocks are not your cup of HTML, you can set this string to 'div',
which produces HTML:

  <div class="poem">
  Like this, a
  <em>poem</em> with default
  class <code>poem</code>.
  </div>

=cut
$PoetryHtmlTag = 'pre';

# ....................{ MARKUP                             }....................
my $PoetryHtmlAttrPattern = '^class="poem( \S|"$)';

push(@MyRules, \&PoetryRule);
SetHtmlEnvironmentContainer('pre', $PoetryHtmlAttrPattern);

# Stanza linebreaks conflict with Creole-style line-breaks.
$RuleOrder{\&PoetryRule} = 170;

=head2 MARKUP

poetry handles two markup styles: Creole and Xml. The Creole style is more
concise, but a bit less adjustable, than the Xml style.

The Creole style is three colons:

   :::
   Like this, a
   //poem// with default
   class, ##poem##, and its last
   stanza
        indented, and linking to [[Another_Poem|another poem]].
   :::

The Xml style is a "<poem>...</poem>" block:

   <poem class="haiku">
   Like this, a %%[[Haiku]]%% having
   the Html
   classes, ##haiku## and ##poem##.
   </poem>

Or, more concisely:

   <poem>
   Like this, a %%[[Haiku]]%% having
   the default HT-
   ML class, ##poem##.
   </poem>

Both markup produce a preformatted block (that is, a "<pre>...</pre>" block)
having the "poem" Html class (for CSS stylization of that block). The Xml style
permits customization of this Html class; the Creole style does not. Thus, use
the Xml style for poetry requiring unique CSS stylization.

Both markup preserve linebreaks, leading indendation, and interspersed
whitespace, preserving the lyrical structure of the poetry this markup is
marking up. In other words, this markup does "the right thing."

Both markup permit embedding of other Wiki markup -- like Wiki links, lists,
headers, and so on -- within themselves. (This permits, should you leverage it,
Wiki poets to pen interactive and actively interesting, Wiki-integrated poetry.)

=cut
sub PoetryRule {
  if (InElement($PoetryHtmlTag, $PoetryHtmlAttrPattern)) {
    # Closure for the current poem.
    if ($bol and (
      ($PoetryIsHandlingCreoleStyleMarkup and m~\G:::(\n|$)~cg) or
      ($PoetryIsHandlingXmlStyleMarkup and m~\G&lt;/poem\&gt;[ \t]*(\n|$)~cg))) {
      return CloseHtmlEnvironment($PoetryHtmlTag, $PoetryHtmlAttrPattern).
        AddHtmlEnvironment('p');
    }
    # Linebreaks and paragraphs. This interprets one newline as a linebreak, two
    # newlines as a paragraph, and N newlines, where N is greater than two, as a
    # paragraph followed by N-2 linebreaks. (This produces appropriate vertical
    # tracking, surprisingly.)
    elsif (m~\G(\s*\n)+~cg) {
      $number_of_newlines = ($1 =~ tr/\n//);

      my $html = '';
      if ($number_of_newlines >  1) {
          $number_of_newlines -= 2;
        $html .= CloseHtmlEnvironments().AddHtmlEnvironment('p');
      }

             $html .= $q->br() x $number_of_newlines;
      return $html;
    }
    # Whitespace and indentation.
    elsif (m~\G(\s+)~cg) { return '&nbsp;' x length($1); }
  }
  # A new poem.
  elsif ($bol and (
    ($PoetryIsHandlingCreoleStyleMarkup and m~\G:::(\n|$)~cg) or
    ($PoetryIsHandlingXmlStyleMarkup and
     m~\G\&lt;poem(\s+(?:class\s*=\s*)?"(.+?)")?\&gt;[ \t]*(\n|$)~cg))) {
    return CloseHtmlEnvironments()
      .AddHtmlEnvironment($PoetryHtmlTag, 'class="poem'.
                          (defined $2 ? ' '.$2 : '').'"')
      .AddHtmlEnvironment('p');
  }

  return undef;
}

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
