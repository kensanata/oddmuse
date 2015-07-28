# Copyright (C) 2006-2014  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;

AddModuleDescription('weblog-4.pl', 'Blogging With Tags');

our ($q, %Action, %Page, $OpenPageName, $HomePage, $ScriptName, @MyInitVariables, @MyAdminCode, $SearchFreeTextTagUrl);

push(@MyInitVariables, sub {
       $SearchFreeTextTagUrl = $ScriptName . '?action=browse;tag=1;id=';
});

push(@MyAdminCode, \&BlogMenu);

sub BlogMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=new', T('New'), 'new'));
}

# Default page content copied from weblog-3.pl.

*BlogOldOpenPage = \&OpenPage;
*OpenPage = \&BlogNewOpenPage;

sub BlogNewOpenPage {
  BlogOldOpenPage(@_);
  if ($Page{revision} == 0) {
    if ($OpenPageName eq $HomePage) {
      $Page{text} = '<journal>';
    } elsif (GetParam('tag','')) {
      # if the page is either on the categories page, or the tag=1
      # parameter was added, show a journal
      $Page{text} = T('Matching pages:')
	. "\n\n<journal search tag:$OpenPageName>";
    }
  }
}

# New Action

$Action{new} = \&DoNewPage;

sub DoNewPage {
  if (GetParam('tags', '') and GetParam('id', '')) {
    DoEdit(GetParam('id', ''), "\n\n\nTags: "
	   . join (' ', map { "[[tag:$_]]" } split(' ', GetParam('tags', ''))),
	   1);
  } else {
    print GetHeader('', T('New')), $q->start_div({-class=>'content new'}),
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
