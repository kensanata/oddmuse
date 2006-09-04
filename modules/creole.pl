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

$ModulesDescription .= '<p>$Id: creole.pl,v 1.5 2006/09/04 12:20:32 as Exp $</p>';

push(@MyRules, \&CreoleRule);
# [[link|{{Image:foo}}]] conflicts with default link rule
$RuleOrder{\&CreoleRule} = -10;

sub CreoleRule {
  my %heading = qw(h2 1 h3 1 h4 1);
  # # number list
  if ($bol && m/\G(\s*\n)*#[ \t]/cg
      or InElement('li') && m/\G(\s*\n)+#[ \t]+/cg) {
    return CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ol', 1)
      . AddHtmlEnvironment('li');
  }
  # - bullet list
  elsif ($bol && m/\G(\s*\n)*-[ \t]/cg
      or InElement('li') && m/\G(\s*\n)+-[ \t]+/cg) {
    return CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ul', 1)
      . AddHtmlEnvironment('li');
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
  # **bold**
  } elsif (m/\G\*\*/cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'strong')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('strong');
  # //italic//
  } elsif (m/\G\/\//cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em');
  }
  # == Level 1 (Largest)
  # === Level 2
  # ==== Level 3
  elsif ($bol && m/\G(\s*\n)*(===?=?)[ \t]/cg) {
    my $tag = 'h' . length($2); # h2-h4
    return CloseHtmlEnvironments() . AddHtmlEnvironment($tag);
  }
  # eat trailing ==
  elsif (defined $HtmlStack[0] && $heading{$HtmlStack[0]}
	 && m/\G=+[ \t]*\n?/cg) {
    return '';
  }
  # paragraphs: at least two newlines
  elsif (m/\G\s*\n(\s*\n)+/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  }
  # line break: one newline, or close a heading
  elsif (m/\G\s*\n/cg) {
    if (defined $HtmlStack[0] && $heading{$HtmlStack[0]}) {
      return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
    } else {
      return $q->br();
    }
  }
  # {{{
  # preformatted
  # }}}
  elsif ($bol && m/\G\{\{\{\n?(.*?\n)\}\}\}[ \t]*\n?/cgs) {
    return CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $1)
      . AddHtmlEnvironment('p');
  }
  # {{{unformatted}}}
  elsif (m/\G\{\{\{(.*?)\}\}\}/cgs) {
    return $q->span({-class=>'nowiki'}, $1);
  }
  # {{Image:pic}}
  elsif (m/\G(\{\{Image:$FreeLinkPattern\}\})/cgs) {
    Dirty($1);
    return GetDownloadLink($2, 1);
  }
  # {{Image:url}}
  elsif (m/\G\{\{Image:$FullUrlPattern\}\}/cgs) {
    return $q->a({-href=>$1,
		  -class=>'image outside'},
		 $q->img({-src=>$1,
			  -class=>'url outside'}));
  }
  # link: [[link|{{Image:pic}}]]
  elsif (m/\G\[\[$FreeLinkPattern\|\{\{Image:$FreeLinkPattern\}\}\]\]/cgs) {
    return ScriptLink($1, $q->img({-src=>GetDownloadLink($2, 2),
				   -alt=>NormalToFree($1),
				   -class=>'upload'}),
		      'image');
  }
  # link: [[url|{{Image:pic}}]]
  elsif (m/\G\[\[$FullUrlPattern\|\{\{Image:$FreeLinkPattern\}\}\]\]/cgs) {
    return $q->a({-href=>$1, -class=>'image outside'},
		 $q->img({-src=>GetDownloadLink($2, 2),
			  -class=>'upload',
			  -alt=>$2}));
  }
  # link: [[url|{{Image:url}}]]
  elsif (m/\G\[\[$FullUrlPattern\|\{\{Image:$FullUrlPattern\}\}\]\]/cgs) {
    return $q->a({-href=>$1, -class=>'image outside'},
		 $q->img({-src=>$2,
			  -class=>'url outside',
			  -alt=>$2}));
  }
  # link: [[url|text]]
  elsif (m/\G\[\[$FullUrlPattern\|([^]]+)?\]\]/cgs) {
    return GetUrl($1, $2, 1);
  }
  # horizontal line
  # ----
  elsif ($bol && m/----+[ \t]*\n?/cg) {
    return CloseHtmlEnvironments() . $q->hr()
      . AddHtmlEnvironment('p');
  }
  return undef;
}
