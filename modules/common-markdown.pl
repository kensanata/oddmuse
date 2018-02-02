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

AddModuleDescription('common-markdown.pl', 'Common Markdown Extension');

our ($q, $bol, %RuleOrder, @MyRules, $UrlProtocols, $FullUrlPattern, @HtmlStack);

sub absolute_uri_regular_expression {
  # For purposes of this spec, a scheme is any sequence of 2–32 characters
  # beginning with an ASCII letter and followed by any combination of ASCII
  # letters, digits, or the symbols plus (”+”), period (”.”), or hyphen (”-”).
  my $scheme = qr"[[:alpha:]][[:alnum:]+.-]{1,31}";
  # An absolute URI, for these purposes, consists of a scheme followed by a
  # colon (:) followed by zero or more characters other than ASCII whitespace
  # and control characters, <, and >. If the URI includes these characters, they
  # must be percent-encoded (e.g. %20 for a space).
  return qr"$scheme:[^[:cntrl:] ]*?";
}

sub html_regular_expression {
  # An attribute name consists of an ASCII letter, _, or :, followed by zero or
  # more ASCII letters, digits, _, ., :, or -. (Note: This is the XML
  # specification restricted to ASCII. HTML5 is laxer.)
  my $attribute_name = qr"[[:alpha:]_:][[:alnum:]+.:-]*";

  # An unquoted attribute value is a nonempty string of characters not including
  # spaces, ", ', =, <, >, or `. Since < and > are quoted as &lt; and &gt; we
  # don't care about them?
  my $unquoted = qr/[^"'`=]+/;

  # A single-quoted attribute value consists of ', zero or more characters not
  # including ', and a final '.
  my $single_quoted = qr/'[^']*'/;

  # A double-quoted attribute value consists of ", zero or more characters not
  # including ", and a final ".
  my $double_quoted = qr/"[^"]*"/;

  # An attribute value consists of an unquoted attribute value, a single-quoted
  # attribute value, or a double-quoted attribute value.
  my $attribute_value = qr"($unquoted|$single_quoted|$double_quoted)";

  # An attribute value specification consists of optional whitespace, a =
  # character, optional whitespace, and an attribute value.
  my $attribute_value_spec = qr"\s*=\s*$attribute_value";

  # An attribute consists of whitespace, an attribute name, and an optional
  # attribute value specification.
  my $attribute = qr"\s+$attribute_name($attribute_value_spec)?";

  # A tag name consists of an ASCII letter followed by zero or more ASCII
  # letters, digits, or hyphens (-).
  my $tag_name = qr"[[:alpha:]][[:alnum:]-]*";

  # An open tag consists of a < character, a tag name, zero or more attributes,
  # optional whitespace, an optional / character, and a > character.
  my $open_tag = qr"&lt;$tag_name($attribute)*\s*/?&gt;";

  # A closing tag consists of the string </, a tag name, optional whitespace,
  # and the character >.
  my $closing_tag = qr"&lt;/$tag_name\s*&gt;";
  # An HTML comment consists of <!-- + text + -->, where text does not start
  # with > or ->, does not end with -, and does not contain --. (See the HTML5
  # spec.)
  my $comment = qr"&lt;!--(?!&gt;)([^-]|-[^-])+--&gt;"s;
  # A processing instruction consists of the string <?, a string of characters
  # not including the string ?>, and the string ?>.
  my $processing_instruction = qr"&lt;\?.+\?&gt;";
  # A declaration consists of the string <!, a name consisting of one or more
  # uppercase ASCII letters, whitespace, a string of characters not including
  # the character >, and the character >.
  my $declaration = qr"&lt;![A-Z]+\s+.+?&gt;";
  # A CDATA section consists of the string <![CDATA[, a string of characters not
  # including the string ]]>, and the string ]]>.
  my $cdata = qr"&lt;!\[CDATA\[.*?\]\]&gt;"s;
  # An HTML tag consists of an open tag, a closing tag, an HTML comment, a
  # processing instruction, a declaration, or a CDATA section.
  return qr"($open_tag|$closing_tag|$comment|$processing_instruction|$declaration|$cdata)"s;
}

my $html_re = html_regular_expression();
my $uri_re = absolute_uri_regular_expression();
my $mail_re = qr/[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*/;

# print $mail_re . "\n";
# $_ = QuoteHtml(q{<foo@bar.example.com>});
# print "$_\n";
# m/&lt;($mail_re)&gt;/;
# print "Match: $1\n";
# exit;

push(@MyRules, \&CommonMarkdownRule);
our %RuleOrder = (\&CommonMarkdownRule => -10); # before LinkRule

sub CommonMarkdownRule {

  # warn(substr($_,0,pos) . '*' . substr($_,pos) . "\n");

  # Any ASCII punctuation character may be backslash-escaped.
  # Backslashes before other characters are treated as literal backslashes.
  # But double quote gets a special treatment.
  if (/\G\\([!#$%&'()*+,-.\/:;<=>?@[\\\]^_`{|}~])/cg) {
    return $1;
  }

  # some regular characters turn into named entities
  elsif (m/\G\\?"/cg) {
  	return '&quot;';
  }

  # autolinks
  elsif (m/\G&lt;($uri_re)&gt;/cg) {
    my $uri = $1;
    my $bytes = encode_utf8($uri);
    $bytes =~ s/([^[:alnum:]._~\-:!*'();@&=+\$,\/?#])/
      sprintf("%%%02X", ord($1))/ge;
    return qq{<a href="$bytes">$uri</a>};
  }
  elsif (m/\G&lt;($mail_re)&gt;/cg) {
    my $uri = $1;
    my $bytes = encode_utf8($uri);
    $bytes =~ s/([^[:alnum:]._~\-:!*'();@&=+\$,\/?#])/
      sprintf("%%%02X", ord($1))/ge;
    return qq{<a href="mailto:$bytes">$uri</a>};
  }

  # atx headers
  elsif ($bol and m/\G(\s*\n)*(#{1,6})[ \t]*/cg) {
    my $header_depth = length($2);
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment("h" . $header_depth);
  }
  # end atx header at a newline
  elsif ((InElement('h1') or InElement('h2') or InElement('h3') or
  	  InElement('h4') or InElement('h5') or InElement('h6'))
  	 and m/\G[ \t]*$/csg) {
    return CloseHtmlEnvironments()
      . AddHtmlEnvironment("p");
  }

  # *italic* (closing before adding environment!)
  elsif (InElement('em') and m/\G\*/cg) {
    return CloseHtmlEnvironment('em');
  }
  elsif ($bol and m/\G\*/cg or m/\G(?<=\P{Word})\*/cg) {
    return AddHtmlEnvironment('em');
  }

  # *code* (closing before adding environment!)
  elsif (m/\G`([^\n`][^`]*)`/cg) {
    my $code = $1;
    # Line breaks do not occur inside code spans
    $code =~ s/  +\n/ /g;
    $code =~ s/\\\n/\\ /g;
    return $q->code($code);
  }

  # Raw HTML
  elsif (m/\G$html_re/cg) {
    return UnquoteHtml($1);
  }

  # A sequence of non-blank lines that cannot be interpreted as other kinds of
  # blocks forms a paragraph.
  elsif (m/\G(\n[ \t]*\n+)/cg) {
    return CloseHtmlEnvironments() . "\n"
	. AddHtmlEnvironment('p');
  }

  # A line break (not in a code span or HTML tag) that is preceded by two or
  # more spaces and does not occur at the end of a block is parsed as a hard
  # line break (rendered in HTML as a <br /> tag):
  elsif (m/\G  +\n */cg or m/\G\\\n */cg) {
  	return "<br />\n";
  }
  # Spaces at the end of the line and beginning of the next line are removed.
  elsif (m/\G[ \t]*\n[ \t]*/cg) {
  	return "\n";
  }
  # Spaces at the end of the string are simply removed
  elsif (m/\G[ \t]*$/cg) {
  	return "";
  }
  # Other whitespace does not collapse
  elsif (m/\G(\s+)/cg) {
  	return $1;
  }

  # Any characters not given an interpretation by the above rules will be parsed
  # as plain textual content. Go word by word.
  elsif (m/\G(\w+)/cg) {
    return $1;
  }

  return undef;
}
