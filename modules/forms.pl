#!/usr/bin/env perl
use strict;
use v5.10;

# ====================[ forms.pl                           ]====================

AddModuleDescription('forms.pl', 'Form Extension');

our ($q, $OpenPageName, @MyRules, $CrossbarPageName);

# ....................{ MARKUP                             }....................
push(@MyRules, \&FormsRule);

sub FormsRule {
  if (IsFile(GetLockedPageFile($OpenPageName)) or (InElement('div', '^class="crossbar"$') and
      IsFile(GetLockedPageFile($CrossbarPageName)))) {
    if (/\G(\&lt;form.*?\&lt;\/form\&gt;)/cgs) {
      my $form = $1;
      my $oldpos = pos;
      Clean(CloseHtmlEnvironments());
      Dirty($form);
      $form =~ s/\%([a-z]+)\%/GetParam($1)/eg;
      $form =~ s/\$([a-z]+)\$/$q->span({-class=>'param'}, GetParam($1))
        .$q->input({-type=>'hidden', -name=>$1, -value=>GetParam($1)})/eg;
      print UnquoteHtml($form);
      pos = $oldpos;
      return AddHtmlEnvironment('p');
    }
    elsif (m/\G\&lt;html\&gt;(.*?)\&lt;\/html\&gt;/cgs) {
      return UnquoteHtml($1);
    }
  }
  return;
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
