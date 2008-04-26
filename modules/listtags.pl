# Copyright (C) 2006 Brock Wilcox <awwaiid@thelackthereof.org>
# Copyright (C) 2008 Weakish Jiang <weakish@gmail.com>
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


$ModulesDescription .= '<p>$Id: listtags.pl,v 1.3 2008/04/26 00:54:27 weakish Exp $</p>';

# This action is similar with list action

use vars qw($TagListLabel);

$TagListLabel = "tag:";

push(@MyRules, \&ListTagRule);

sub ListTagRule {
  if ($bol && /\G(\[\[\!tag\s*(.+)\]\])/gc) {
    my $tag_text = $2;
    my @tags = split /,\s*/, $tag_text;
    @tags = map {
      my $name = $_;
      my $encoded = $name;
      $encoded =~ s/ +/\\s+/g;
      $encoded = UrlEncode($encoded);
      ScriptLink("action=taglist;search=\\[\\[\!tag\\s*($encoded|.*,\\s*$encoded)(,|\\]\\])", $name);
    } @tags;
    $tags = join ', ', @tags;
    return CloseHtmlEnvironments()
      . "<div class=\"taglist\">$TagListLabel $tags</div>"
      . AddHtmlEnvironment('p');
  }
  return undef;
}

$Action{taglist} = \&DoTagList;

sub DoTagList {
my $id = shift;
my $search = GetParam('search', '');
my $currenttag = $search;
   $currenttag =~ s/\|.*//;
   $currenttag =~ s/\\\[.*\(//; 
  ReportError(T('The search parameter is missing.')) unless $search;
  print GetHeader('', Ts('Pages tagged with %s', $currenttag), '');
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

