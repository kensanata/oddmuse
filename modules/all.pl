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

$ModulesDescription .= '<p>$Id: all.pl,v 1.1 2006/06/15 11:30:14 as Exp $</p>';

$Action{all} = \&DoPrintAllPages;

my $Monolithic = 0;

sub DoPrintAllPages {
  return  if (!UserIsAdminOrError());
  $Monolithic = 1; # changes ScriptLink
  print GetHeader('', T('Complete Content'))
    . $q->p(Ts('The main page is %s.', $q->a({-href=>'#' . $HomePage}, $HomePage)));
  print $q->p($q->b(Ts('(for %s)', GetParam('lang', 0)))) if GetParam('lang', 0);
  PrintAllPages(0, 0, AllPagesList());
  PrintFooter();
}

sub PrintAllPages {
  my $links = shift;
  my $comments = shift;
  my $lang = GetParam('lang', 0);
  for my $id (@_) {
    OpenPage($id);
    my @languages = split(/,/, $Page{languages});
    @languages = GetLanguages($Page{text}) unless GetParam('cache', $UseCache); # maybe refresh!
    next if $lang and @languages and not grep(/$lang/, @languages);
    my $title = $id;
    $title =~ s/_/ /g;	 # Display as spaces
    print $q->start_div({-class=>'page'}) . $q->hr
      . $q->h1($links ? GetPageLink($id, $title) : $q->a({-name=>$id},$title));
    PrintPageHtml();
    if ($comments and UserCanEdit($CommentsPrefix . $id, 0) and $id !~ /^$CommentsPrefix/) {
      print $q->p({-class=>'comment'},
		  GetPageLink($CommentsPrefix . $id, T('Comments on this page')));
    }
    print $q->end_div();;
  }
}

*OldAllScriptLink = *ScriptLink;
*ScriptLink = *NewAllScriptLink;

sub NewAllScriptLink {
  my ($action, $text, $class, $name, $title, $accesskey, $nofollow) = @_;
  if ($Monolithic
      and $action !~ /^($UrlProtocols)\%3a/
      and $action !~ /^\%2f/
      and $action !~ /=/) {
    $params{-href} = '#' . $action;
    $params{'-class'} = $class  if $class;
    $params{'-name'} = $name  if $name;
    $params{'-title'} = $title  if $title;
    $params{'-accesskey'} = $accesskey  if $accesskey;
    $params{'-rel'} = 'nofollow'  if $nofollow;
    return $q->a(\%params, $text);
  } else {
    return OldAllScriptLink(@_);
  }
}
