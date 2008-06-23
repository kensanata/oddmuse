# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html
#
# For user doc, see: 
# http://www.oddmuse.org/cgi-bin/oddmuse/Backlinks_Extension

$ModulesDescription .= '<p>$Id: backlinks.pl,v 1.2 2008/06/23 17:13:51 weakish Exp $</p>';

*OldGetSearchLink = *GetSearchLink;
*GetSearchLink = *NewGetSearchLink;
sub NewGetSearchLink {
  my ($text, $class, $name, $title) = @_;
  my $id = UrlEncode(QuoteRegexp($text));
  $name = UrlEncode($name);
  $text = NormalToFree($text);
  $id =~ s/_/\ /g;               # Search for url-escaped spaces
  return ScriptLink("action=backlink;search=\\[\\[$id(\\|.*)*\\]\\]", $text, $class, $name, $title);
}

$Action{backlink} = \&DoBackLink;

sub DoBackLink {
my $id = shift;
my $search = GetParam('search', '');
my $taglabel = $search;
   $taglabel =~ s/\\\[\\\[//;
   $taglabel =~ s/\\\]\\\]//; 
  ReportError(T('The search parameter is missing.')) unless $search;
  print GetHeader('', Ts('Pages link to %s', $taglabel), '');
  local (%Page, $OpenPageName);
    my %hash = ();
    foreach my $id (SearchTitleAndBody($search))  {
      $hash{$id} = 1;
    }
    my @found = keys %hash;
    if (defined &PageSort) {
      @found = sort PageSort @found;
    } else {
      @found = sort(@found);
    }
    @found = map { $q->li(GetPageLink($_)) } @found;
    print $q->start_div({-class=>'search list'}),
      $q->ul(@found), $q->end_div;  
  PrintFooter();
}  
