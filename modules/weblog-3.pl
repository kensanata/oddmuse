# Copyright (C) 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: weblog-3.pl,v 1.12 2006/01/01 23:46:57 as Exp $</p>';

# Categories

$CategoriesPage = 'Categories';

*CategoriesOldOpenPage = *OpenPage;
*OpenPage = *CategoriesNewOpenPage;

%Category = (); # fast checking
@Categories = (); # correct order
my $CategoryInit = 0;

sub CategoriesNewOpenPage {
  CategoryInit() unless $CategoryInit;
  CategoriesOldOpenPage(@_);
  if ($Page{revision} == 0) {
    if ($OpenPageName eq $HomePage) {
      $Page{text} = '<journal>';
    } elsif (GetParam('tag','') or $Category{$OpenPageName}) {
      # if the page is either on the categories page, or the tag=1
      # parameter was added, show a journal
      $Page{text} = T('Matching pages:')
	. "\n\n"
	. '<journal "^\d\d\d\d-\d\d-\d\d.*'
	. $OpenPageName
	. '">';
    }
  }
}

sub CategoryInit {
  $CategoryInit = 1;
  my @paragraphs = split(/\n\n+/, GetPageContent($CategoriesPage));
  foreach (@paragraphs) {
    next unless /^\*/;
    while (/\*.*?\[\[$FreeLinkPattern\]\]/g) {
      my $id = FreeToNormal($1);
      $Category{$id} = 1;
      push(@Categories, $id);
    }
    last;
  }
}

# New Action

$Action{new} = \&DoCategories;

sub DoCategories {
  print GetHeader('', T('New')), $q->start_div({-class=>'content categories'}),
    GetFormStart(undef, 'get', 'cat');
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime();
  my $today = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
  CategoryInit() unless $CategoryInit;
  print $q->p({-class=>'table'}, map {GetEditLink("$today $_", $_)} @Categories);
  print $q->p($q->textfield('id', $today), GetHiddenValue('action', 'edit'));
  print $q->p(Ts('Edit %s.', GetPageLink($CategoriesPage)));
  print $q->submit("Go!");
  print $q->end_form, $q->end_div();
  PrintFooter();
}

# Set Goto Bar according to links on the HomePage.
# Every item should start with exactly one bullet
# and a link in double square brackets.

*GetGotoBar = * NewGetGotoBar;
my $GotoBarInit = 0;

sub GotoBarInit {
  $GotoBarInit = 1;
  my @paragraphs = split(/\n\n+/, GetPageContent($HomePage));
  foreach (@paragraphs) {
    next unless /^\*/;
    while (/\*.*?\[\[(.*?)\]\]/g) {
      push(@UserGotoBarPages, $1);
    }
    last;
  }
}

sub NewGetGotoBar {
  my $id = shift;
  GotoBarInit() unless $GotoBarInit;
  my @links;
  foreach my $name (@UserGotoBarPages) {
    push (@links, GetPageLink($name, $name));
  }
  my @parts = split(/_/, GetId());
  CategoryInit() unless $CategoryInit;
  if ($parts[0] =~ /\d\d\d\d-\d\d-\d\d/) {
    shift(@parts);
    push(@links, map {
      if ($Category{$_}) {
	$q->a({-href=>$ScriptName . ($UsePathInfo ? '/' : '?') . UrlEncode($_),
	       -class=>'local tag',
	       -rel=>'tag'}, $_);
      } else {
	# provide tag=1 parameter to tell OpenPage to add journal tag
	$q->a({-href=>$ScriptName . '?tag=1;action=browse;id=' . UrlEncode($_),
	       -class=>'local tag',
	       -rel=>'tag'}, $_);
      }
    } @parts);
  }
  push (@links, ScriptLink('action=new', T('New')));
  return $q->span({-class=>'gotobar bar'}, @links, $UserGotoBar);
}
