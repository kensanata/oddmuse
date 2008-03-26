# Copyright (C) 2004, 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: markup.pl,v 1.32 2008/03/26 21:57:19 as Exp $</p>';

use vars qw(%MarkupPairs %MarkupSingles %MarkupLines $MarkupQuotes $MarkupQuoteTable);

$MarkupQuotes = 1;
$MarkupQuoteTable = [["'", "'", '"', '"'], # 0
		     ['&#x2018;', '&#x2019;', '&#x201d;', '&#x201c;', '&#x2019;'], # 1
		     ['&#x2039;', '&#x203a;', '&#x00bb;', '&#x00ab;', '&#x2019;'], # 2
		     ['&#x203a;', '&#x2039;', '&#x00ab;', '&#x00bb;', '&#x2019;'], # 3
		     ['&#x201a;', '&#x2018;', '&#x201c;', '&#x201e;', '&#x2019;'], # 4
		    ];

push(@MyRules, \&MarkupRule);
# The ---- rule in usemod.pl conflicts with the --- rule
$RuleOrder{\&MarkupRule} = 150;

%MarkupPairs = ('*' => 'b',
		'/' => 'i',
		'_' => ['em', {'style'=>'text-decoration: underline; font-style: normal;'}],
		'~' => 'em',
	       );

%MarkupForcedPairs = ("{{{\n" => ['pre', undef, '}}}'],
		      '##' => 'code',
		      '%%' => 'span',
		      '**' => 'b',
		      '//' => 'i',
		      '__' => ['em', {'style'=>'text-decoration: underline; font-style: normal;'}],
		      '~~' => 'em',
		     );

# This could be done using macros, however: If we convert to the
# numbered entity, the next person editing finds it hard to read.  If
# we convert to a unicode character, it is no longer obvious how to
# achieve it.
%MarkupSingles = ('...' => '&#x2026;', # HORIZONTAL ELLIPSIS
		  '---' => '&#x2014;', # EM DASH
		  '-- ' => '&#x2013; ', # EN DASH
		  '-> ' => '&#x2192; ', # RIGHTWARDS ARROW
		 );

%MarkupLines = ('>' => 'pre',
	       );

my $words = '([A-Za-z\x80-\xff][-%.,:;\'"!?0-9 A-Za-z\x80-\xff]*?)';
# zero-width look-ahead assertion to prevent km/h from counting
my $noword = '(?=[^-0-9A-Za-z\x80-\xff]|$)';

my $markup_pairs_re = '';
my $markup_forced_pairs_re = '';
my $markup_singles_re = '';
my $markup_lines_re = '';

# do not add all block elements, because not all of them make sense,
# as they cannot be nested -- thus it would not be possible to put
# list items inside a list element, for example.
my %block_element = map { $_ => 1 } qw(p blockquote address div h1 h2
				       h3 h4 h5 h6 pre);

# do this later so that the user can customize the vars
push(@MyInitVariables, \&MarkupInit);

sub MarkupInit {
  $markup_pairs_re = '\G([' . join('', (map { quotemeta(QuoteHtml($_)) }
					keys(%MarkupPairs))) . '])';
  $markup_pairs_re = qr/${markup_pairs_re}${words}\1${noword}/;
  $markup_forced_pairs_re = '\G(' . join('|', (map { quotemeta(QuoteHtml($_)) }
					       keys(%MarkupForcedPairs))) . ')';
  $markup_forced_pairs_re = qr/$markup_forced_pairs_re/;
  $markup_singles_re = '\G(' . join('|', (map { quotemeta(QuoteHtml($_)) }
					  sort {$b cmp $a} # longer regex first
					  keys(%MarkupSingles))) . ')';
  $markup_singles_re = qr/$markup_singles_re/;
  $markup_lines_re = '\G(' . join('|', (map { quotemeta(QuoteHtml($_)) }
					keys(%MarkupLines))) . ')(.*\n?)';
  $markup_lines_re = qr/$markup_lines_re/;
}

sub MarkupTag {
  my ($tag, $str) = @_;
  my ($start, $end);
  if (ref($tag)) {
    my $arrayref = $tag;
    my ($tag, $hashref) = @{$arrayref};
    my %hash = %{$hashref};
    $start = $end = $tag;
    foreach my $attr (keys %hash) {
      $start .= ' ' . $attr . '="' . $hash{$attr} . '"';
    }
  } else {
    $start = $end = $tag;
  }
  my $result = "<$start>$str</$end>";
  $result = CloseHtmlEnvironments() . $result . AddHtmlEnvironment('p')
    if $block_element{$start};
  return $result;
}

sub MarkupRule {
  if ($bol and %MarkupLines and m/$markup_lines_re/gc) {
    my ($tag, $str) = ($1, $2);
    $str = $q->span($tag) . $str;
    while (m/$markup_lines_re/gc) {
      $str .= $q->span($1) . $2;
    }
    return CloseHtmlEnvironments()
      . MarkupTag($MarkupLines{UnquoteHtml($tag)}, $str)
      . AddHtmlEnvironment('p');
  } elsif (%MarkupForcedPairs and m/$markup_forced_pairs_re/gc) {
    my $tag = $1;
    my $start = $tag;
    my $end = $tag;
    # handle different end tag
    my $data = $MarkupForcedPairs{UnquoteHtml($tag)};
    if (ref($data)) {
      my @data = @{$data};
      $start = $data[0] if $data[0];
      $end = $data[2] if $data[2];
    }
    my $endre = quotemeta($end);
    $endre .= '[ \t]*\n?' if $block_element{$start}; # skip trailing whitespace if block
    # may match the empty string, or multiple lines, but may not span
    # paragraphs.
    if ($endre and m/\G$endre/gc) {
      return $tag . $end;
    } elsif ($tag eq $end && m/\G((:?.+?\n)*?.+?)$endre/gc) { # may not span paragraphs
      return MarkupTag($data, $1);
    } elsif ($tag ne $end && m/\G((:?.|\n)+?)$endre/gc) {
      return MarkupTag($data, $1);
    } else {
      return $tag;
    }
  } elsif (%MarkupPairs and m/$markup_pairs_re/gc) {
    return MarkupTag($MarkupPairs{UnquoteHtml($1)}, $2);
  } elsif (%MarkupSingles and m/$markup_singles_re/gc) {
    return $MarkupSingles{UnquoteHtml($1)};
  } elsif ($MarkupPairs{'/'} and m|\G~/|gc) {
    return '~/'; # fix ~/elisp/ example
  } elsif ($MarkupPairs{'/'} and m|\G(/[-A-Za-z0-9\x80-\xff/]+/$words/)|gc) {
    return $1; # fix /usr/share/lib/! example
  } elsif ($MarkupQuotes and (m/\G(?<=[[:space:]])"/cg
			      or pos == 0 and m/\G"/cg)) {
    return $MarkupQuoteTable->[$MarkupQuotes]->[3];
  } elsif ($MarkupQuotes and (m/\G"(?=[[:space:][:punct:]])/cg
			      or m/\G"\z/cg)) {
    return $MarkupQuoteTable->[$MarkupQuotes]->[2];
  } elsif ($MarkupQuotes and (m/\G(?<=[[:punct:]])"/cg)) {
    return $MarkupQuoteTable->[$MarkupQuotes]->[3];
  } elsif ($MarkupQuotes and pos == 0 and m/\G'/cg) {
    return $MarkupQuoteTable->[$MarkupQuotes]->[0];
  } elsif ($MarkupQuotes and (m/\G'(?=[[:space:][:punct:]])/cg
			      or m/\G'\z/cg)) {
    return $MarkupQuoteTable->[$MarkupQuotes]->[1];
  } elsif ($MarkupQuotes and m/\G(?<![[:space:][:punct:]])'/cg) {
    return $MarkupQuoteTable->[$MarkupQuotes]->[4];
  } elsif ($MarkupQuotes and m/\G(?<=[[:space:][:punct:]])'/cg) {
    return $MarkupQuoteTable->[$MarkupQuotes]->[0];
  }
  return undef;
}
