#! /usr/bin/perl
# Copyright (C) 2014–2017  Alex Schroeder <alex@gnu.org>

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

use strict;
use v5.10;

AddModuleDescription('markdown-rule.pl', 'Markdown Rule Extension');

our ($q, $bol, %RuleOrder, @MyRules, $UrlProtocols, $FullUrlPattern, @HtmlStack);

push(@MyRules, \&MarkdownRule);
# Since we want this package to be a simple add-on, we try and avoid
# all conflicts by going *last*. The use of # for numbered lists by
# Usemod conflicts with the use of # for headings, for example.
$RuleOrder{\&MarkdownRule} = 200;

# http://daringfireball.net/projects/markdown/syntax
# https://help.github.com/articles/markdown-basics
# https://help.github.com/articles/github-flavored-markdown

sub MarkdownRule {
  # \escape
  if (m/\G\\([-#>*`=])/cg) {
    return $1;
  }
  # atx headers
  elsif ($bol and m~\G(\s*\n)*(#{1,6})[ \t]*~cg) {
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
  # > blockquote
  # with continuation
  elsif ($bol and m/\G&gt;/cg) {
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment('blockquote');
  }
  # """ = blockquote, too
  elsif ($bol and m/\G"""[ \t]*\n(.*?)\n"""[ \t]*(\n|$)/cgs) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my ($oldpos, $old_) = ((pos), $_);
    print '<blockquote>';
    ApplyRules($1, 1, 1, undef, 'p'); # local links, anchors, no revision, start with p
    print '</blockquote>';
    Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
    ($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
  }
  # ``` = code
  elsif ($bol and m/\G```[ \t]*\n(.*?)\n```[ \t]*(\n|$)/cgs) {
    return CloseHtmlEnvironments() . $q->pre($1)
      . AddHtmlEnvironment("p");
  }
  # ` = code may not start with a newline
  elsif (m/\G`([^\n`][^`]*)`/cg) {
    return $q->code($1);
  }
  # ***bold and italic***
  elsif (not InElement('strong') and not InElement('em') and m/\G\*\*\*/cg) {
    return AddHtmlEnvironment('em') . AddHtmlEnvironment('strong');
  }
  elsif (InElement('strong') and InElement('em') and m/\G\*\*\*/cg) {
    return CloseHtmlEnvironment('strong') . CloseHtmlEnvironment('em');
  }
  # **bold**
  elsif (m/\G\*\*/cg) {
    return AddOrCloseHtmlEnvironment('strong');
  }
  # *italic* (closing before adding environment!)
  elsif (InElement('em') and m/\G\*/cg) {
    return CloseHtmlEnvironment('em');
  }
  elsif ($bol and m/\G\*/cg or m/\G(?<=\P{Word})\*/cg) {
    return AddHtmlEnvironment('em');
  }
  # ~~strikethrough~~ (deleted)
  elsif (m/\G~~/cg) {
    return AddOrCloseHtmlEnvironment('del');
  }
  # indented lists = nested lists
  elsif ($bol and m/\G(\s*\n)*()([*-]|\d+\.)[ \t]+/cg
      or InElement('li') && m/\G(\s*\n)+( *)([*-]|\d+\.)[ \t]+/cg) {
    my $nesting_goal = int(length($2)/4) + 1;
    my $tag = ($3 eq '*' or $3 eq '-') ? 'ul' : 'ol';
    my $nesting_current = 0;
    my @nesting = grep(/^[uo]l$/, @HtmlStack);
    my $html = CloseHtmlEnvironmentUntil('li'); # but don't close li element
    # warn "\@nesting is (@nesting)\n";
    # warn "    goal is $nesting_goal\n";
    # warn "     tag is $3 > $tag\n";
    while (@nesting > $nesting_goal) {
      $html .= CloseHtmlEnvironment(pop(@nesting));
      # warn "      pop\n";
    }
    # if have the correct nesting level, but the wrong type, close it
    if (@nesting == $nesting_goal
	and $nesting[$#nesting] ne $tag) {
      $html .= CloseHtmlEnvironment(pop(@nesting));
      # warn "   switch\n";
    }
    # now add a list of the appropriate type
    if (@nesting < $nesting_goal) {
      $html .= AddHtmlEnvironment($tag);
      # warn "       add $tag\n";
    }
    # and a new list item
    if (InElement('li')) {
      $html .= CloseHtmlEnvironmentUntil($nesting[$#nesting]);
      # warn "     close li\n";
    }
    $html .= AddHtmlEnvironment('li');
      # warn "       add li\n";
    return $html;
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
  elsif ($bol and m/\G(\s*\n)*(    .+)\n?/cg) {
    my $str = substr($2, 4);
    while (m/\G(    .*)\n?/cg) {
      $str .= "\n" . substr($1, 4);
    }
    return OpenHtmlEnvironment('pre',1) . $str; # always level 1
  }
  # link: [an example](http://example.com/ "Title")
  elsif (m/\G\[((?:[^]\n]+\n?)+)\]\($FullUrlPattern(\s+"(.+?)")?\)/cg) {
    my ($text, $url, $title) = ($1, $2, $4);
    $url =~ /^($UrlProtocols)/;
    my %params;
    $params{-href} = $url;
    $params{-class} = "url $1";
    $params{-title} = $title if $title;
    return $q->a(\%params, $text);
  }
  # setext headers (must come after block quotes)
  elsif ($bol and m/\G((\s*\n)*(.+?)[ \t]*\n(-+|=+)[ \t]*\n)/cg) {
    return CloseHtmlEnvironments()
      . (substr($4,0,1) eq '=' ? $q->h2($3) : $q->h3($3))
      . AddHtmlEnvironment('p');
  }
  return;
}

push(@MyRules, \&MarkdownExtraRule);

sub MarkdownExtraRule {
  # __italic underline__
  if (m/\G__/cg) {
    return AddOrCloseHtmlEnvironment('em', 'style="font-style: normal; text-decoration: underline"');
  }
  # _underline_ (closing before adding environment!)
  elsif (InElement('em', 'style="font-style: normal; text-decoration: underline"') and m/\G_/cg) {
    return CloseHtmlEnvironment('em');
  }
  elsif ($bol and m/\G_/cg or m/\G(?<=\P{Word})_(?=\S)/cg) {
    return AddHtmlEnvironment('em', 'style="font-style: normal; text-decoration: underline"');
  }
  # //italic//
  elsif (m/\G\/\//cg) {
    return AddOrCloseHtmlEnvironment('em');
  }
  # /italic/ (closing before adding environment!)
  elsif (InElement('em') and m/\G\//cg) {
    return CloseHtmlEnvironment('em');
  }
  elsif ($bol and m/\G\//cg or m/\G(?<=[|[:space:]])\/(?=\S)/cg) {
    return AddHtmlEnvironment('em');
  }
  return;
}
