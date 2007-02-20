# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: weblog-4.pl,v 1.13 2007/02/20 00:29:37 as Exp $</p>';

push(@MyInitVariables, sub {
       $SearchFreeTextTagUrl = $ScriptName . '?action=browse;tag=1;id=';
});

push(@MyAdminCode, \&BlogMenu);

sub BlogMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=new', T('New'), 'new'));
}

# Default page content copied from weblog-3.pl.

*BlogOldOpenPage = *OpenPage;
*OpenPage = *BlogNewOpenPage;

sub BlogNewOpenPage {
  BlogOldOpenPage(@_);
  if ($Page{revision} == 0) {
    if ($OpenPageName eq $HomePage) {
      $Page{text} = '<journal>';
    } elsif (GetParam('tag','') or $Category{$OpenPageName}) {
      # if the page is either on the categories page, or the tag=1
      # parameter was added, show a journal
      $Page{text} = T('Matching pages:')
	. "\n\n<journal search tag:$OpenPageName>";
    }
  }
}

# New Action

$Action{new} = \&DoCategories;

sub DoCategories {
  if (GetParam('tags', '') and GetParam('id', '')) {
    DoEdit(GetParam('id', ''), "\n\n\nTags: "
	   . join (' ', map { "[[tag:$_]]" } split(' ', GetParam('tags', ''))),
	   1);
  } else {
    print GetHeader('', T('New')), $q->start_div({-class=>'content categories'}),
      GetFormStart(undef, 'get', 'cat');
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime();
    my $today = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    my $go = T('Go!');
    print $q->p(T('Title: '),
		qq{<input type="text" name="id" value="$today" tabindex="1" />},
		GetHiddenValue('action', 'new'));
    print $q->p(T('Tags: '),
		qq{<input type="text" name="tags" tabindex="2" />});
    print $q->p(qq{<input type="submit" value="$go" tabindex="3" />});
    print $q->end_form, $q->end_div();
    PrintFooter();
  }
}
