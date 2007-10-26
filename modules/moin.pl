# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: moin.pl,v 1.5 2007/10/26 16:34:08 as Exp $</p>';

push(@MyRules, \&MoinRule);
$RuleOrder{\&MoinRule} = -10; # run before default rules because of [[BR]]

my %moin_level;   # mapping length of whitespace to indentation level
my $moin_current; # the current length of whitespace (not indentation level!)

sub MoinLength {
  $str = shift;
  my $oldpos = pos;
  $str =~ s/\t/       /g;
  die if pos != $oldpos;
  return length($str); # the length of whitespace
}

sub MoinListLevel {
  my $oldpos = pos;
  my $length = MoinLength(shift);
  if (not InElement('li') and not InElement('dd')) { # problematic mixing!
    %moin_level = ($length => 1);
    $moin_current = $length;
  } elsif ($moin_level{$length}) {
    # return from a sublist or continuing the current list
    foreach my $ln (keys %moin_level) {
      delete $moin_level{$ln} if $moin_level{$ln} > $moin_level{$length};
    }
    $moin_current = $length;
  } elsif ($length > $moin_current) {
    # or entering a new sublist
    $moin_level{$length} = $moin_level{$moin_current} + 1;
    $moin_current = $length;
  } else {
    # else we've returned to an invalid level - but we know that there is a higher level!
    $length++ until $moin_level{$length};
    $moin_current = $length;
  }
  pos = $oldpos;
  return $moin_level{$moin_current}
}

sub MoinRule {
  # ["free link"]
  if (m/\G(\["(.*?)"\])/gcs) {
    Dirty($1);
    print GetPageOrEditLink($2);
    return '';
  }
  # [[BR]]
  elsif (m/\G\[\[BR\]\]/gc) {
    return $q->br();
  }
  # {{{
  # block
  # }}}
  elsif ($bol && m/\G\{\{\{\n?(.*?\n)\}\}\}[ \t]*\n?/cgs) {
    return CloseHtmlEnvironments()
      . $q->pre({-class=>'real'}, $1)
	. AddHtmlEnvironment('p');
  }
  #  * list item
  #   * nested item
  elsif ($bol && m/\G(\s*\n)*([ \t]+)\*[ \t]*/cg
	 or InElement('li') && (m/\G(\s*\n)+([ \t]+)\*[ \t]*/cg)) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ul', MoinListLevel($2))
	. AddHtmlEnvironment('li');
  }
  #  1. list item
  #   1. nested item
  elsif ($bol && m/\G(\s*\n)*([ \t]+)1\.[ \t]*/cg
	 or InElement('li') && m/\G(\s*\n)+([ \t]+)1\.[ \t]*/cg) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ol', MoinListLevel($2))
	. AddHtmlEnvironment('li');
  }
  # indented text using whitespace
  elsif ($bol && m/\G(\s*\n)*([ \t]+)/cg) {
    my $str = $2;
    if (MoinLength($str) == $moin_current
	and (InElement('li') or InElement('dd'))) {
      return ' ';
    } else {
      return CloseHtmlEnvironmentUntil('dd')
	. OpenHtmlEnvironment('dl', MoinListLevel($str), 'quote')
	  . $q->dt()
	    . AddHtmlEnvironment('dd');
    }
  }
  # emphasis and strong emphasis using '' and '''
  elsif (defined $HtmlStack[0] && $HtmlStack[1] && $HtmlStack[0] eq 'em'
	 && $HtmlStack[1] eq 'strong' and m/\G'''''/cg) {
    # close either of the two
    return CloseHtmlEnvironment() . CloseHtmlEnvironment();
  }
  # traditional wiki syntax for '''strong'''
  elsif (m/\G'''/cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'strong')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('strong');
  }
  # traditional wiki syntax for ''emph''
  elsif (m/\G''/cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em');
  }
  # moin syntax for __underline__
  elsif (m/\G__/cg) {
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em', 'style="text-decoration: underline; font-style: normal;"');
  }
  # don't automatically fuse lines
  elsif (m/\G([ \t]+|[ \t]*\n)/cg) {
    return ' ';
  }
  return undef;
}
