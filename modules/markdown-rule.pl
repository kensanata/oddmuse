#! /usr/bin/perl
# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>

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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/markdown-rule.pl">markdown-rule.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Markdown_Rule_Extension">Markdown Rule Extension</a></p>';

push(@MyRules, \&MarkdownRule);
# Since we want this package to be a simple add-on, we try and avoid
# all conflicts by going *last*. The use of # for numbered lists by
# Usemod conflicts with the use of # for headings, for example.
$RuleOrder{\&MarkdownRule} = 200;

# http://daringfireball.net/projects/markdown/syntax
# https://help.github.com/articles/markdown-basics
# https://help.github.com/articles/github-flavored-markdown

sub MarkdownRule {
  # atx headers
  if ($bol and m~\G(\s*\n)*(#{1,6})[ \t]*~cg) {
    my $header_depth = length($2);
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment("h" . $header_depth);
  }
  # end atx header at a newline
  elsif ((InElement('h1') or InElement('h2') or InElement('h3') or
	  InElement('h4') or InElement('h5') or InElement('h6'))
	 and m/\G\n/cg) {
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment("p");
  }
  # setext headers
  elsif ($bol and m/\G((\s*\n)*(.+?)[ \t]*\n(-+|=+)[ \t]*\n)/gc) {
    return CloseHtmlEnvironments()
      . (substr($4,0,1) eq '=' ? $q->h2($3) : $q->h3($3))
      . AddHtmlEnvironment('p');
  }
  # > blockquote
  # with continuation
  elsif ($bol and m/\G&gt;/gc) {
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment('blockquote');
  }
  # ***bold and italic***
  elsif (not InElement('strong') and not InElement('em') and m/\G\*\*\*/cg) {
    return AddHtmlEnvironment('em') . AddHtmlEnvironment('strong');
  }
  # **bold**
  elsif (m/\G\*\*/cg) {
    return AddOrCloseHtmlEnvironment('strong');
  }
  # *italic*
  elsif (m/\G\*/cg) {
    return AddOrCloseHtmlEnvironment('em');
  }
  # ~~strikethrough~~ (deleted)
  elsif (m/\G~~/cg) {
    return AddOrCloseHtmlEnvironment('del');
  }
  # - bullet list
  elsif ($bol and m/\G(\s*\n)*-[ \t]*/cg
	   or InElement('li') and m/\G(\s*\n)+-[ \t]*/cg) {
    return CloseHtmlEnvironment('li')
      . OpenHtmlEnvironment('ul',1) . AddHtmlEnvironment('li');
  }
  # 1. numbered list
  elsif ($bol and m/\G(\s*\n)*\d+\.[ \t]*/cg
	   or InElement('li') and m/\G(\s*\n)+\d+\.[ \t]*/cg) {
    return CloseHtmlEnvironment('li')
      . OpenHtmlEnvironment('ol',1) . AddHtmlEnvironment('li');
  }
  # beginning of a table
  elsif ($bol and !InElement('table') and m/\G\|/cg) {
    # warn pos . " beginning of a table";
    return OpenHtmlEnvironment('table',1)
      . AddHtmlEnvironment('tr')
      . AddHtmlEnvironment('th');
  }
  # end of a row and beginning of a new row
  elsif (InElement('table') and m/\G\|?\n\|/cg) {
    # warn pos . " end of a row and beginning of a new row";
    return CloseHtmlEnvironment('tr')
      . AddHtmlEnvironment('tr')
      . AddHtmlEnvironment('td');
  }
  # otherwise the table ends
  elsif (InElement('table') and m/\G\|?(\n|$)/cg) {
    # warn pos . " otherwise the table ends";
    return CloseHtmlEnvironment('table')
      . AddHtmlEnvironment('p');
  }
  # continuation of the first row
  elsif (InElement('th') and m/\G\|/cg) {
    # warn pos . " continuation of the first row";
    return CloseHtmlEnvironment('th')
      . AddHtmlEnvironment('th');
  }
  # continuation of other rows
  elsif (InElement('td') and m/\G\|/cg) {
    # warn pos . " continuation of other rows";
    return CloseHtmlEnvironment('td')
      . AddHtmlEnvironment('td');
  }
  # whitespace indentation = code
  elsif ($bol and m/\G(\s*\n)*(    .+)\n?/gc) {
    my $str = substr($2, 4);
    while (m/\G(    .*)\n?/gc) {
      $str .= "\n" . substr($1, 4);
    }
    return OpenHtmlEnvironment('pre',1) . $str; # always level 1
  }
  # ``` = code
  elsif ($bol and m/\G```[ \t]*\n(.*?)\n```[ \t]*(\n|$)/gcs) {
    return CloseHtmlEnvironments() . $q->pre($1)
      . AddHtmlEnvironment("p");
  }
  # [an example](http://example.com/ "Title")
  elsif (m/\G\[(.+?)\]\($FullUrlPattern(\s+"(.+?)")?\)/goc) {
    my ($text, $url, $title) = ($1, $2, $4);
    $url =~ /^($UrlProtocols)/;
    my %params;
    $params{-href} = $url;
    $params{-class} = "url $1";
    $params{-title} = $title if $title;
    return $q->a(\%params, $text);
  }
  return undef;
}
