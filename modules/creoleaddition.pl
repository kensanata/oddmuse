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

$ModulesDescription .= '<p>$Id: creoleaddition.pl,v 1.15 2008/09/30 06:32:32 leycec Exp $</p>';

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
push(@MyRules, \&CreoleAdditionRules);

# Blockquote line-breaks conflict with Creole-style line-breaks.
$RuleOrder{\&CreoleAdditionRules} = -11;

sub CreoleAdditionRules {
  # ^^sup^^
  if ($CreoleAdditionSupSub && m/\G\^\^/cg) {
    return InElement('sup') ? CloseHtmlEnvironment() : AddHtmlEnvironment('sup');
  # ,,sub,,
  } elsif ($CreoleAdditionSupSub && m/\G\,\,/cg) {
    return InElement('sub') ? CloseHtmlEnvironment() : AddHtmlEnvironment('sub');
  # ##monospace code##
  } elsif ($CreoleAdditionMonospace && m/\G\#\#/cg) {
    return InElement('code') ? CloseHtmlEnvironment() : AddHtmlEnvironment('code');
  # definition lists
  # ; term
  # : description
  } elsif ($CreoleAdditionDefList && $bol &&
           (m/\G\s*\;[ \t]*(?=(.+(\n)(\s)*\:))/cg || (InElement('dd') &&
            m/\G\s*\n(\s)*\;[ \t]*(?=(.+\n(\s)*\:))/cg))) {
    return
       CloseHtmlEnvironmentUntil('dd')
      .OpenHtmlEnvironment('dl', 1)
      . AddHtmlEnvironment('dt');  # `:' needs special treatment, later
  } elsif (InElement('dt') and m/\G\s*\n(\s)*\:[ \t]*(?=(.+(\n)(\s)*\:)*)/cg) {
    return CloseHtmlEnvironment().AddHtmlEnvironment('dd');
  } elsif (InElement('dd') and m/\G\s*\n(\s)*\:[ \t]*(?=(.+(\n)(\s)*\:)*)/cg) {
    return CloseHtmlEnvironment().AddHtmlEnvironment('dd');
  # ''quote''
  } elsif ($CreoleAdditionQuote && m/\G\'\'/cgs) {
    return InElement('q') ? CloseHtmlEnvironment() : AddHtmlEnvironment('q');
  # """
  # block quotes
  # """
  } elsif ($CreoleAdditionQuote and $bol and m/\G\"\"\"(?:\n|$)/cg) {
    return InElement('blockquote')
      ? CloseHtmlEnvironmentsCreoleOld().AddHtmlEnvironment('p')
      : CloseHtmlEnvironments().AddHtmlEnvironment('blockquote').AddHtmlEnvironment('p');
  # %%small caps%%
  } elsif ($CreoleAdditionSmallCaps && m/\G\%\%/cgs) {
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
