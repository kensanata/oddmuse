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

$ModulesDescription .= '<p>$Id: creole.pl,v 1.1 2006/09/03 23:22:20 as Exp $</p>';

push(@MyRules, \&CreoleRule);

sub CreoleRule {
  my %heading = qw(h2 1 h3 1 h4 1);
  # # number list
  if ($bol && m/\G(\s*\n)*#[ \t]/cg) {
    return CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ol', 1)
      . AddHtmlEnvironment('li');
  }
  # - bullet list
  elsif ($bol && m/\G(\s*\n)*-[ \t]/cg) {
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
  # ending headings
  elsif ($bol && defined $HtmlStack[0] && $heading{$HtmlStack[0]}) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  }
  # paragraphs: at least two newlines
  elsif (m/\G\s*\n(\s*\n)+/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  }
  # line break: one newline
  elsif (m/\G\s*\n/cg) {
    return $q->br();
  }
  # preformatted
  elsif ($bol && m/\G\{\{\{\n?(.*?\n)\}\}\}[ \t]*\n?/cgs) {
    return CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $1)
      . AddHtmlEnvironment('p');
  }
  # unformatted
  elsif (m/\G\{\{\{(.*?)\}\}\}/cgs) {
    return $q->span({-class=>'nowiki'}, $1);
  }
  # horizontal line
  # ----
  # ~~~~
  # ____
  elsif ($bol && m/(----+|~~~~+|____+)[ \t]*\n?/cg) {
    return CloseHtmlEnvironments() . $q->hr()
      . AddHtmlEnvironment('p');
  }
  return undef;
}
