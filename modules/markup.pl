# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: markup.pl,v 1.10 2004/08/18 13:01:48 as Exp $</p>';

use vars qw(%MarkupPairs %MarkupSingles);

push(@MyRules, \&MarkupRule);
# The ---- rule in usemod.pl conflicts with the --- rule
$RuleOrder{\&MarkupRule} = 150;

%MarkupPairs = ('*' => 'b',
		'/' => 'i',
		'_' => 'u',
		'~' => 'em',
	       );

# This could be done using macros, however: If we convert to the
# numbered entity, the next person editing finds it hard to read.  If
# we convert to a unicode character, it is no longer obvious how to
# achieve it.
%MarkupSingles = ('...' => '&#x2026;', # HORIZONTAL ELLIPSIS
		  '---' => '&#x2014;', # EM DASH
		  '-- ' => '&#x2013; ', # EN DASH
		  '-&gt; ' => '&#x2192; ', # RIGHTWARDS ARROW
		 );

my $words = '([A-Za-z\x80-\xff][-%.,:;\'"!?0-9 A-Za-z\x80-\xff]*?)';
# zero-width look-ahead assertion to prevent km/h from counting
my $noword = '(?=[^-0-9A-Za-z\x80-\xff]|$)';

my $markup_pairs_re = '';
my $markup_singles_re = '';

*OldMarkupInitVariables = *InitVariables;
*InitVariables = *NewMarkupInitVariables;

sub NewMarkupInitVariables {
  OldMarkupInitVariables();
  $markup_pairs_re = '\G([' . join('', (map { quotemeta($_) } keys(%MarkupPairs))) . '])';
  # die($markup_pairs_re);
  $markup_pairs_re = qr/\G${markup_pairs_re}${words}\1${noword}/;
  $markup_singles_re = '\G(' . join('|', (map { quotemeta($_) } keys(%MarkupSingles))) . ')';
  $markup_singles_re = qr/$markup_singles_re/;
}

sub MarkupRule {
  if (m/$markup_pairs_re/gc) {
    return '<' . $MarkupPairs{$1} . '>' . $2 . '</' . $MarkupPairs{$1} . '>';
  } elsif (m/$markup_singles_re/gc) {
    return $MarkupSingles{$1};
  } elsif ($MarkupPairs{'/'} and m|\G~/|gc) {
    return '~/'; # fix ~/elisp/ example
  } elsif ($MarkupPairs{'/'} and m|\G(/[-A-Za-z0-9\x80-\xff/]+/$words/)|gc) {
    return $1; # fix /usr/share/lib/! example
  }
  return undef;
}
