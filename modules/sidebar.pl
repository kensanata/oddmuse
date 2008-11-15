#!/usr/bin/env perl
# ====================[ sidebar.pl                         ]====================
$ModulesDescription .= '<p>$Id: sidebar.pl,v 1.20 2008/11/15 21:24:33 leycec Exp $</p>';

use vars qw($SidebarName);

# ....................{ CONFIGURATION                      }....................

# Include this page on every page:
$SidebarName = 'SideBar';

$SidebarSubstitutionPattern = '^';

# ....................{ INITIALIZATION                     }....................

# Do this later so that the user can customize $SidebarName.
push(@MyInitVariables, \&SidebarInit);

sub SidebarInit {
  $SidebarName = FreeToNormal($SidebarName); # spaces to underscores
  $AdminPages{$SidebarName} = 1;
}

# ....................{ MARKUP =before                     }....................
push(@MyBeforeApplyRules, \&SidebarBeforeApplyRule);

sub SidebarBeforeApplyRule {
  my $markup_ = shift;
  my  $sidebar_markup = GetPageContent($SidebarName);
  if ($sidebar_markup and $sidebar_markup !~ m~^\s*$~) {
    $$markup_ =~ s~$SidebarSubstitutionPattern~
      "\n&lt;sidebar&gt;\n".QuoteHtml($sidebar_markup)."\n&lt;/sidebar&gt;\n"~e;
  }
}

# ....................{ MARKUP                             }....................
push(@MyRules, \&SidebarRule);
SetHtmlEnvironmentContainer('div', '^class="sidebar"$');

sub SidebarRule {
  if ($bol) {
    # Dialogue markup expands to a list of questions for that dialogue and
    # stylizable divs. Neither of these elements contain "dirty" text; thus,
    # we simply append to the currently "clean" fragment of such text.
    if    ( m~\G\&lt;sidebar\&gt;\n~cg) {
      return ($HtmlStack[0] eq 'p' ? CloseHtmlEnvironment() : '')
        .AddHtmlEnvironment  ('div', 'class="sidebar"')
        .AddHtmlEnvironment  ('p');
    }
    elsif (m~\G\&lt;/sidebar\&gt;(\n|$)~cg) {
      return
         CloseHtmlEnvironment('div', 'class="sidebar"')
        .AddHtmlEnvironment  ('p');
    }
  }

  return undef;
}

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008              by B.w.Curry <http://www.raiazome.com>.
Copyright 2004, 2005, 2007  by Alex Schroeder <alex@emacswiki.org>.
Copyright 2004              by Tilmann Holst

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
