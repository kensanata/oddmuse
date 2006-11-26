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

$ModulesDescription .= '<p>$Id: creole.pl,v 1.15 2006/11/26 11:03:20 as Exp $</p>';

push(@MyRules, \&CreoleRule);
# [[link|{{Image:foo}}]] conflicts with default link rule
$RuleOrder{\&CreoleRule} = -10;

sub CreoleRule {
  # horizontal line
  # ----
  # (must come before unnumbered lists using dashes)
  if ($bol && m/\G(\s*\n)*----+[ \t]*\n?/cg or m/\G\s*\n----+[ \t]*\n?/cg ) {
    return CloseHtmlEnvironments() . $q->hr()
      . AddHtmlEnvironment('p');
  }
  # # number list
  elsif ($bol && m/\G\s*(#+)[ \t]*/cg
      or InElement('li') && m/\G\s*\n[ \t]*(#+)[ \t]*/cg) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ol', length($1))
      . AddHtmlEnvironment('li');
  }
  # - and * bullet list
  elsif ($bol && m/\G\s*([*-])[ \t]*/cg
      or InElement('li') && m/\G\s*\n[ \t]*([*-]+)[ \t]*/cg) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ul', length($1))
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
  }
  # **bold**
  elsif (m/\G\*\*/cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'strong')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('strong');
  }
  # //italic//
  elsif (m/\G\/\//cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em');
  }
  # == Level 1 (Largest)
  # === Level 2
  # ==== Level 3
  # Too bad those are not the only ones allowed... :(
  elsif ($bol && m/\G(\s*\n)*(==+)[ \t]*(.*?)[ \t]*=*[ \t]*(\n|\Z)/cg) {
    my $depth = length($2);
    $depth = 6 if $depth > 6;
    $depth = 2 if $depth < 2;
    my $text = $3;
    return CloseHtmlEnvironments() . "<h$depth>$text</h$depth>"
      . AddHtmlEnvironment('p');
  }
  # paragraphs: at least two newlines
  elsif (m/\G\s*\n(\s*\n)+/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  }
  # line break: one newline
  elsif (m/\G\s*\n/cg) {
    return $q->br();
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
    return $q->code($1);
  }
  # {{pic}}
  elsif (m/\G(\{\{$FreeLinkPattern(\|.+)?\}\})/cgos) {
    Dirty($1);
    my $alt = substr($3,1); # FIXME: inlining this gives "substr outside of string" error
    return GetDownloadLink($2, 1, undef, $alt);
  }
  # {{url}}
  elsif (m/\G\{\{$FullUrlPattern(\|.+)?\}\}/cgos) {
    return $q->a({-href=>$1,
		  -class=>'image outside'},
		 $q->img({-src=>$1,
			  -alt=>substr($2,1),
			  -class=>'url outside'}));
  }
  # link: [[link|{{pic}}]]
  elsif (m/\G\[\[$FreeLinkPattern\|\{\{$FreeLinkPattern(\|.+)?\}\}\]\]/cgos) {
    return ScriptLink($1, $q->img({-src=>GetDownloadLink($2, 2),
				   -alt=>substr($3,1)||NormalToFree($1),
				   -class=>'upload'}),
		      'image');
  }
  # link: [[link|{{url}}]]
  elsif (m/\G\[\[$FreeLinkPattern\|\{\{$FullUrlPattern(\|.+)?\}\}\]\]/cgos) {
    return ScriptLink($1, $q->img({-src=>$2,
				   -class=>'url outside',
				   -alt=>substr($3,1)||$1}),
		      'image');
  }
  # link: [[url|{{pic}}]]
  elsif (m/\G\[\[$FullUrlPattern\|\{\{$FreeLinkPattern(\|.+)?\}\}\]\]/cgos) {
    return $q->a({-href=>$1, -class=>'image outside'},
		 $q->img({-src=>GetDownloadLink($2, 2),
			  -class=>'upload',
			  -alt=>substr($3,1)||$2}));
  }
  # link: [[url|{{url}}]]
  elsif (m/\G\[\[$FullUrlPattern\|\{\{$FullUrlPattern(\|.+)?\}\}\]\]/cgos) {
    return $q->a({-href=>$1, -class=>'image outside'},
		 $q->img({-src=>$2,
			  -class=>'url outside',
			  -alt=>substr($3,1)}));
  }
  # link: [[url]] and [[url|text]]
  elsif (m/\G\[\[$FullUrlPattern(\|([^]]+))?\]\]/cgos) {
    return GetUrl($1, $3||$1, 1);
  }
  return undef;
}
