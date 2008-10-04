#!/usr/bin/env perl
# ====================[ creoleaddition.pl                  ]====================

=head1 NAME

creoleaddition - An Oddmuse module for augmenting the Creole Markup module with
                 so-called, unofficial "Creole Additions" markup.

=head1 INSTALLATION

creoleaddition is simply installable; simply:

=over

=item First install the Creole Markup module; see
      L<http://www.oddmuse.org/cgi-bin/oddmuse/Creole_Markup_Extension>.

=item Move this file into the B<wiki/modules/> directory for your Oddmuse Wiki.

=back

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: creoleaddition.pl,v 1.19 2008/10/04 03:30:50 leycec Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

creoleaddition is easily configurable; set these variables in the
B<wiki/config.pl> file for your Oddmuse Wiki.

=cut
# Since these rules are not official now, users can turn off some of
# them.
use vars qw($CreoleAdditionSupSub
            $CreoleAdditionDefList
            $CreoleAdditionQuote
            $CreoleAdditionMonospace
            $CreoleAdditionSmallCaps $CreoleAdditionIsInSmallCaps
          );

=head2 $CreoleAdditionSupSub

A boolean that, if true, enables this extension's handling of
^^supscript^^ and ,,subscript,,-style markup. (By default, this boolean is
true.)

=cut
$CreoleAdditionSupSub = 1;

=head2 $CreoleAdditionDefList

A boolean that, if true, enables this extension's handling of
"; definition : lists"-style markup. (By default, this boolean is true.)

=cut
$CreoleAdditionDefList = 1;

=head2 $CreoleAdditionQuote

A boolean that, if true, enables this extension's handling of
"""block quote""" and ''inline quote''-style markup. (By default, this
boolean is true.)

=cut
$CreoleAdditionQuote = 1;

=head2 $CreoleAdditionMonospace

A boolean that, if true, enables this extension's handling of
##monospaced text##-style markup. (By default, this boolean is true.)

=cut
$CreoleAdditionMonospace = 1;

=head2 $CreoleAdditionSmallCaps

A boolean that, if true, enables this extension's handling of
%%small caps%%-style markup. (By default, this boolean is true.)

=cut
$CreoleAdditionSmallCaps = 1;

# ....................{ INITIALIZATION                     }....................
push(@MyInitVariables, \&CreoleAdditionInit);

sub CreoleAdditionInit {
  # True, if currently within small caps markup; false, otherwise. This is
  # slightly more hacky than we'd like; but, as a noxious product of the
  # programmed fact that "@HtmlBlocks" does not stack the attributes for an HTML
  # block with the tag for that block, is unavoidable. (See "%%small caps%%",
  # below.)
  $CreoleAdditionIsInSmallCaps = '';
}

# ....................{ MARKUP                             }....................
push(@MyRules, \&CreoleAdditionRule);

# Blockquote line-breaks conflict with Creole-style line-breaks.
$RuleOrder{\&CreoleAdditionRule} = -11;

sub CreoleAdditionRule {
  # ; definition list term
  if ($CreoleAdditionDefList and (
      ($bol and                    m/\G[ \t]*;[ \t]*(?=[^:]+?\n[ \t]*:[ \t]*)/cg) or
      (InElement('dd') and m/\G[ \t]*\n[ \t]*;[ \t]*(?=[^:]+?\n[ \t]*:[ \t]*)/cg))) {
    return
       CloseHtmlEnvironmentUntil('dd')
      .OpenHtmlEnvironment('dl', 1)
      . AddHtmlEnvironment('dt');
  }
  # : definition list description
  elsif ($CreoleAdditionDefList and (InElement('dt') or InElement('dd')) and
            m/\G[ \t]*\n[ \t]*:[ \t]*/cg) {
    return CloseHtmlEnvironment().AddHtmlEnvironment('dd');
  }
  # """block quotes"""
  elsif ($CreoleAdditionQuote and bol and m/\G\"\"\"(\s|$)/cg) {
    return InElement('blockquote')
      ? CloseHtmlEnvironmentsCreoleAdditionOld().AddHtmlEnvironment('p')
      : CloseHtmlEnvironments().AddHtmlEnvironment('blockquote').AddHtmlEnvironment('p');
  }
  # ''inline quotes''
  elsif ($CreoleAdditionQuote and m/\G\'\'/cgs) {
    return AddOrCloseCreoleAdditionEnvironment('q');
  }
  # ^^sup^^
  elsif ($CreoleAdditionSupSub and m/\G\^\^/cg) {
    return AddOrCloseCreoleAdditionEnvironment('sup');
  }
  # ,,sub,,
  elsif ($CreoleAdditionSupSub and m/\G\,\,/cg) {
    return AddOrCloseCreoleAdditionEnvironment('sub');
  }
  # ##monospace code##
  elsif ($CreoleAdditionMonospace and m/\G\#\#/cg) {
    return AddOrCloseCreoleAdditionEnvironment('code');
  }
  # %%small caps%%
  elsif ($CreoleAdditionSmallCaps and m/\G\%\%/cg) {
    if (defined $HtmlStack[0] && $HtmlStack[0] eq 'span' &&
        $CreoleAdditionIsInSmallCaps) {
        $CreoleAdditionIsInSmallCaps = '';
      return CloseHtmlEnvironment();
    }
    else {
        $CreoleAdditionIsInSmallCaps = 1;
      return AddHtmlEnvironment('span', 'style="font-variant: small-caps"');
    }
  }

  return undef;
}

# ....................{ FUNCTIONS                          }....................
*CloseHtmlEnvironmentsCreoleAdditionOld = *CloseHtmlEnvironments;
*CloseHtmlEnvironments =                  *CloseHtmlEnvironmentsCreoleAddition;

=head2 CloseHtmlEnvironmentsCreoleAddition

Closes HTML environments for the current block level element, up to but not
including the "<blockquote>" current block level element, if this block is
embedded within a blockquote. This, though kludgy, is the code magic permitting
block level elements in multi-line blockquotes.

=cut
sub CloseHtmlEnvironmentsCreoleAddition {
  return InElement('blockquote')
    ? CloseHtmlEnvironmentUntil('blockquote')
    : CloseHtmlEnvironmentsCreoleAdditionOld();
}

=head2 AddOrCloseCreoleEnvironment

Adds or closes the HTML environment corresponding to the passed HTML tag, as
needed. Specifically, if that environment is already opened, this function
closes it; otherwise, this function adds it.

=cut
sub AddOrCloseCreoleAdditionEnvironment {
  my $html_tag = shift;
  return InElement($html_tag)
    ? CloseHtmlEnvironmentUntil($html_tag).CloseHtmlEnvironment()
    : AddHtmlEnvironment       ($html_tag);
}

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008 by B.w.Curry <http://www.raiazome.com>.
Copyright 2008 by Weakish Jiang <weakish@gmail.com>.

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
