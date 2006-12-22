# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

$ModulesDescription .= '<p>$Id: forms.pl,v 1.6 2006/12/22 15:49:36 as Exp $</p>';

push(@MyRules, \&FormsRule);

sub FormsRule {
  if (-f GetLockedPageFile($OpenPageName)) {
    if (/\G(\&lt;form.*?\&lt;\/form\&gt;)/cgs) {
      my $form = $1;
      my $oldpos = pos;
      Clean(CloseHtmlEnvironments());
      Dirty($form);
      $form =~ s/\%([a-z]+)\%/GetParam($1)/ge;
      $form =~ s/\$([a-z]+)\$/$q->span({-class=>'param'}, GetParam($1))
	. $q->input({-type=>'hidden', -name=>$1, -value=>GetParam($1)})/ge;
      print UnquoteHtml($form);
      pos = $oldpos;
      return AddHtmlEnvironment('p');
    } elsif (m/\G\&lt;html\&gt;(.*?)\&lt;\/html\&gt;/cgs) {
      return UnquoteHtml($1);
    }
  }
  return undef;
}
