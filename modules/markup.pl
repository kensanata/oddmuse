# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: markup.pl,v 1.21 2005/09/25 11:14:58 as Exp $</p>';

use vars qw(%MarkupPairs %MarkupSingles %MarkupLines);

push(@MyRules, \&MarkupRule);
# The ---- rule in usemod.pl conflicts with the --- rule
$RuleOrder{\&MarkupRule} = 150;

%MarkupPairs = ('*' => 'b',
		'/' => 'i',
		'_' => ['em', {'style'=>'text-decoration: underline; font-style: normal;'}],
		'~' => 'em',
	       );

%MarkupForcedPairs = ('{{{' => ['code', {'style'=>'white-space:pre;'}, '}}}'],
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
  return '<' . $start . '>' . $str . '</' . $end . '>';
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
    my $end = $tag;
    # handle different end tag
    my $data = $MarkupForcedPairs{UnquoteHtml($tag)};
    if (ref($data)) {
      my @data = @{$data};
      $end = $data[2] if $data[2];
    }
    $end = quotemeta($end);
    if ($end and m/\G((:?.*?\n?)*?)$end/gc) {
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
  }
  return undef;
}
