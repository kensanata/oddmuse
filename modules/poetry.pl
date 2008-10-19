#!/usr/bin/env perl
# ====================[ poetry.pl                          ]====================

=head1 NAME

poetry - An Oddmuse module for adding poetry to Oddmuse pages.

=head1 SYNOPSIS

Poetry - particularly, rhymically loose "free verse" poetry - tends to depend on
fanciful (but meaningful) line-breaks, indentation, and whitespace, which
publications of that poetry must preserve. This extension preserves that.

=head1 INSTALLATION

poetry is easily installable; move this file into the B<wiki/modules/>
directory for your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: poetry.pl,v 1.2 2008/10/19 01:51:43 leycec Exp $</p>';

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&PoetryInit);

# A boolean that, if true, signifies that we are currently in a "verse" div.
# Testing InElement('div') is insufficient, since we might as well be in some
# other div element.
my $PoetryRuleInDiv;
sub PoetryInit {
   $PoetryRuleInDiv = '';
}

# ....................{ MARKUP                             }....................
push(@MyRules, \&PoetryRule);

=head2 MARKUP

poetry handles markup markup surrounded by three colons:

   :::
   Like this, a
   //poem// with its last
   stanza
        indented, and linking to [[Another_Poem|another poem]].
   :::

This demonstrates that, for example, this extension preserves line-breaks,
indendation, and whitespace - and properly converts and interprets such Wiki
markup as links and italicized text.

=cut

# Stanza line-breaks conflict with Creole-style line-breaks.
$RuleOrder{\&PoetryRule} = 170;

sub PoetryRule {
  # :::
  # open a new "verse" div or close an existing one
  if ($bol and m/\G:::(\n|$)/cg) {
    if ($PoetryRuleInDiv) {
        $PoetryRuleInDiv = '';
      return CloseHtmlEnvironments().AddHtmlEnvironment('p');
    }
    else {
        $PoetryRuleInDiv = 1;
      return CloseHtmlEnvironments()
        .AddHtmlEnvironment('div', 'class="verse"')
        .AddHtmlEnvironment('p');
    }
  }
  # Otherwise, if we are currently in an existing "verse" div, force proper
  # whitespace with liberal use of <br/> tags. (We cannot use a simple "pre"
  # tag, as such preformatted blocks do not permit embedding of HTML tags.)
  elsif ($PoetryRuleInDiv) {
    if (m/\G\s*\n(\s*\n)+/cg) {     # paragraphs: at least two newlines
      return CloseHtmlEnvironmentUntil('div').AddHtmlEnvironment('p');
    }
    elsif (m/\G\s*\n/cg) {          # line break: one newline
      return $q->br();
    }
    elsif ($bol and m/\G(\s*)/cg) { # indentation
      return '&nbsp;' x length($1);
    }
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
