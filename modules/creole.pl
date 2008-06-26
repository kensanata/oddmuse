# Copyright (C) 2006, 2007  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: creole.pl,v 1.42 2008/06/26 08:00:36 as Exp $</p>';

use vars qw($CreoleLineBreaks $CreoleTildeAlternative);

# single newlines don't insert a linebreak
$CreoleLineBreaks = 0;
# the tilde does not disappear in front of a-z, A-Z, 0-9.
$CreoleTildeAlternative = 0;

push(@MyRules, \&CreoleRule, \&CreoleHeadingRule, \&CreoleNewLineRule);
# [[link|{{Image:foo}}]] conflicts with default link rule
$RuleOrder{\&CreoleRule} = -10;
# == headings rule must come after the TocRule
$RuleOrder{\&CreoleHeadingRule} = 100;
# newline rule must come very late, otherwise it will add a lot of useless br tag in, say, lists.
$RuleOrder{\&CreoleNewLineRule} = 120;

sub CreoleHeadingRule {
  # = to ====== for h1 to h6
  if ($bol && m/\G(\s*\n)*(=+)[ \t]*(.*?)[ \t]*=*[ \t]*(\n|\Z)/cg) {
    my $depth = length($2);
    my $text = $3;
    if ($depth > 6) {
	 return CloseHtmlEnvironments() . '<h6 class="' . "h$depth" . '">' . "$text</h6>"
	 . AddHtmlEnvironment('p');
 	}
    return CloseHtmlEnvironments() . "<h$depth>$text</h$depth>"
      . AddHtmlEnvironment('p');
  }
  return undef;
}

sub CreoleNewLineRule {
  # line break: one newline,
  if ($CreoleLineBreaks && m/\G\s*\n/cg) {
    return $q->br();
  }
  return undef;
}  


sub CreoleRule {
  # escape next char (and prevent // in URLs from enabling italics)
  # ~
  if (m/\G(~($FullUrlPattern|\S))/cgo) {
    if ($CreoleTildeAlternative
	and index('ABCDEFGHIJKLMNOPQRSTUVWXYZ'
		  . 'abcdefghijklmnopqrstuvwxyz'
		  . '0123456789', $2) != -1) {
      return $1; # tilde stays
    } else {
      return $2; # tilde disappears
    }
  }
  # horizontal line
  # ----
  elsif ($bol && m/\G(\s*\n)*[ \t]*----+[ \t]*\n?/cg
      or m/\G\s*\n----+[ \t]*\n?/cg ) {
    return CloseHtmlEnvironments() . $q->hr()
      . AddHtmlEnvironment('p');
  }
  # //**bold italic//**bold
  elsif (defined $HtmlStack[0] && defined $HtmlStack[1]
	 && $HtmlStack[0] eq 'strong'
	 && $HtmlStack[1] eq 'em'
	 && m/\G\/\//cg) {
    return CloseHtmlEnvironment() . CloseHtmlEnvironment();
  }
  # **//bold italic**//italic
  elsif (defined $HtmlStack[0] && defined $HtmlStack[1]
	 && $HtmlStack[0] eq 'em'
	 && $HtmlStack[1] eq 'strong'
	 && m/\G\*\*/cg) {
    return CloseHtmlEnvironment() . CloseHtmlEnvironment();
  }
  # **bold**
  elsif (m/\G\*\*/cg and not ($bol && InElement('li'))) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'strong')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('strong');
  }
  # //italic//
  elsif (m/\G\/\//cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em');
  }
  # # number list
  elsif ($bol && m/\G\s*(#)[ \t]*/cg
      or InElement('li') && m/\G\s*\n[ \t]*(#+)[ \t]*/cg) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ol', length($1))
      . AddHtmlEnvironment('li');
  }
  # * bullet list
  # - bullet list (not nested, requires space)
  elsif ($bol && (m/\G\s*(\*)[ \t]*/cg
		  || m/\G\s*(-)[ \t]+/cg)
	 or InElement('li') && (m/\G\s*\n[ \t]*(\*+)[ \t]*/cg
				|| m/\G\s*\n[ \t]*(-)[ \t]+/cg)) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ul', length($1))
      . AddHtmlEnvironment('li');
  }
  # tables using | -- end of the row or table
  elsif (InElement('td') || InElement('th')
	 and (m/\G[ \t]*\|?[ \t]*(\n)?(\n|$)/cg)) {
    if ($1) {
      return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
    } else {
      return CloseHtmlEnvironmentUntil('table');
    }
  }
  # tables using | -- an ordinary table cell
  elsif (m/\G[ \t]*(\|+)(=)?([ \t]*)/cg) {
    my $html = '';
    $html .= OpenHtmlEnvironment('table',1,'user') unless InElement('table');
    $html .= AddHtmlEnvironment('tr') unless InElement('tr');
    $html .= CloseHtmlEnvironmentUntil('tr')
      if InElement('td') || InElement('th');
    $html .= AddHtmlEnvironment(($2 ? 'th' : 'td'),
				TableAttributes(length($1), $3));
    return $html;
  }
  # paragraphs: at least two newlines
  elsif (m/\G\s*\n(\s*\n)+/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  }
  # line break: \\
  elsif (m/\G\\\\(\s*\n?)/cg) {
    return $q->br();
  }
  # {{{
  # preformatted
  # }}}
  elsif ($bol && m/\G\{\{\{[ \t]*\n(.*?\n)\}\}\}[ \t]*(\n|\z)/cgs) {
    my $str = $1;
    $str =~ s/\n }}}/\n}}}/g;
    return CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $str)
      . AddHtmlEnvironment('p');
  }
  # {{{unformatted}}}
  elsif (m/\G\{\{\{(.*?}*)\}\}\}/cgs) {
    return $q->code($1);
  }
  # {{pic}}
  elsif (m/\G(\{\{$FreeLinkPattern(\|.+?)?\}\})/cgos) {
    Dirty($1);
    # FIXME: inlining this gives "substr outside of string" error
    my $alt = substr($3,1);
    print GetDownloadLink($2, 1, undef, $alt);
    return '';
  }
  # {{url}}
  elsif (m/\G\{\{$FullUrlPattern\s*(\|.+?)?\}\}/cgos) {
    return $q->a({-href=>$1,
		  -class=>'image outside'},
		 $q->img({-src=>$1,
			  -alt=>substr($2,1),
			  -class=>'url outside'}));
  }
  # link: [[link|{{pic}}]]
  elsif (m/\G\[\[$FreeLinkPattern\|\{\{$FreeLinkPattern(\|.+?)?\}\}\]\]/cgos) {
    return ScriptLink($1, $q->img({-src=>GetDownloadLink($2, 2),
				   -alt=>substr($3,1)||NormalToFree($1),
				   -class=>'upload'}),
		      'image');
  }
  # link: [[link|{{url}}]]
  elsif (m/\G\[\[$FreeLinkPattern\|\{\{$FullUrlPattern\s*(\|.+?)?\}\}\]\]/cgos) {
    return ScriptLink($1, $q->img({-src=>$2,
				   -class=>'url outside',
				   -alt=>substr($3,1)||$1}),
		      'image');
  }
  # link: [[url|{{pic}}]]
  elsif (m/\G\[\[$FullUrlPattern\s*\|\{\{$FreeLinkPattern(\|.+?)?\}\}\]\]/cgos) {
    return $q->a({-href=>$1, -class=>'image outside'},
		 $q->img({-src=>GetDownloadLink($2, 2),
			  -class=>'upload',
			  -alt=>substr($3,1)||$2}));
  }
  # link: [[url|{{url}}]]
  elsif (m/\G\[\[$FullUrlPattern\s*\|\{\{$FullUrlPattern\s*(\|.+?)?\}\}\]\]/cgos) {
    return $q->a({-href=>$1, -class=>'image outside'},
		 $q->img({-src=>$2,
			  -class=>'url outside',
			  -alt=>substr($3,1)}));
  }
  # link: [[url]] and [[url|text]]
  elsif (m/\G\[\[$FullUrlPattern\s*(\|\s*([^]]+))?\]\]/cgos) {
    return GetUrl($1, $3||$1, 1);
  }
  return undef;
}

sub TableAttributes {
  my ($span, $left, $right) = @_;
  my $attr = '';
  $attr = "colspan=\"$span\"" if ($span != 1);
  m/\G(?=.*?([ \t]*)\|)/ and $right = $1 unless $right;
  $attr .= ' ' if ($attr and ($left or $right));
  if ($left and $right) { $attr .= 'align="center"' }
  elsif ($left) { $attr .= 'align="right"' }
  # this is the default:
  # elsif ($right) { $attr .= 'align="left"' }
  return $attr;
}
