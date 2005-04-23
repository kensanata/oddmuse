# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: moin.pl,v 1.2 2005/04/23 12:54:45 as Exp $</p>';

push(@MyRules, \&MoinRule);

sub MoinRule {
  # ["free link"]
  if (m/\G(\["(.*?)"\])/gcs) {
    Dirty($1);
    print GetPageOrEditLink($2);
    return '';
  }
  # {{{
  # block
  # }}}
  elsif ($bol && m/\G\{\{\{\n?(.*?\n)\}\}\}[ \t]*\n?/cgs) {
    return CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $1) . AddHtmlEnvironment('p');
  }
  #  * list item
  #   * nested item
  elsif ($bol && m/\G(\s*\n)*( +)\*[ \t]*/cg
	 or InElement('li') && m/\G(\s*\n)+( +)\*[ \t]*/cg) {
    return CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ul',length($2))
      . AddHtmlEnvironment('li');
  }
  # emphasis and strong emphasis using '' and '''
  elsif (defined $HtmlStack[0] && $HtmlStack[1] && $HtmlStack[0] eq 'em'
	 && $HtmlStack[1] eq 'strong' and m/\G'''''/cg) { # close either of the two
    return CloseHtmlEnvironment() . CloseHtmlEnvironment();
  } elsif (m/\G'''/cg) { # traditional wiki syntax for '''strong'''
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'strong')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('strong');
  } elsif (m/\G''/cg) { # traditional wiki syntax for ''emph''
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em');
  } elsif (m/\G__/cg) { # moin syntax for __underline__
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em', 'style="text-decoration: underline; font-style: normal;"');
  }
  return undef;
}
