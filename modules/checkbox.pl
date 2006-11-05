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

$ModulesDescription .= '<p>$Id: checkbox.pl,v 1.1 2006/11/05 17:00:37 as Exp $</p>';

# [[ : To do]]
# [[X: Done]]
# [[save: Save]]

push(@MyRules, \&CheckBoxRule);

sub CheckBoxRule {
  if ($bol and /\G\[\[( |x):([^]]+)\]\]/cgi) {
    my $html;
    if (not InElement('form')) {
      # We want to use GetFormStart so we have to trade-off using
      # AddHtmlEnvironment.
      $html = CloseHtmlEnvironments()
	. GetFormStart(undef, 'get', 'checkboxes');
      unshift(@HtmlStack, 'form');
      $html .= AddHtmlEnvironment('p');
    }
    $html .= $q->checkbox(-name     => FreeToNormal($2),
			  -checked  => ($1 eq ' '? 0 : 1),
			  -label    => $2)
      . $q->br();
    return $html;
  } elsif (/\G\[\[save:([^]]+)\]\]/cgi) {
    if (InElement('form')) {
      return ($q->input({-type   => 'hidden',
			   -name   => 'action',
			   -value  => 'checkbox'})
	      . $q->input({-type   => 'hidden',
			   -name   => 'id',
			   -value  => $OpenPageName})
	      . $q->submit(-name   => $1));
    } else {
      return $1;
    }
  }
  return undef;
}

$Action{checkbox} = \&DoCheckBox;

sub DoCheckBox{
  my $id = shift;
  OpenPage($id);
  my $text = $Page{text};
  my %summary;
  $text =~ s{(\A|\n)\[\[( |x):([^]]+)\]\]}{
    # no search and replace in this loop
    if (GetParam(FreeToNormal($3))) {
      $summary{$3} = 1 if $2 eq ' ';
      "${1}[[x:${3}]]";
    } else {
      $summary{$3} = 0 if $2 eq 'x' or $2 eq 'X';
      "${1}[[ :${3}]]";
    }
  }eig;
  SetParam('text', $text);
  SetParam('summary', join(', ', map {
    if ($summary{$_}) {
      Ts('set %s', $_);
    } else {
      Ts('unset %s', $_);
    }
  } keys %summary));
  DoPost($id);
}
