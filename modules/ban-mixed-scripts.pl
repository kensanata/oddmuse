# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>

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

=encoding utf8

=head1 Mixed Scripts

This module disallows ordinary users from posting words that consist of multiple
scripts. Stuff like this: "It's diffіcult to find knowledgeable people on this
topic, but youu sound like you know wgat you're taⅼkіng аboսt!" Did you notice
the confusable characters? The sentence contains the following:
ARMENIAN SMALL LETTER SEH
CYRILLIC SMALL LETTER A
CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
SMALL ROMAN NUMERAL FIFTY

=cut

use strict;
use v5.10;

use Unicode::UCD qw(charprop);

AddModuleDescription('ban-mixed-scripts.pl', 'Ban Mixed Scripts Extension');

*OldBanMixedScriptsBannedContent = \&BannedContent;
*BannedContent = \&NewBanMixedScriptsBannedContent;

sub NewBanMixedScriptsBannedContent {
  my $rule = OldBanMixedScriptsBannedContent(@_);
  $rule ||= BanMixedScript(@_);
  return $rule;
}

sub BanMixedScript {
  my $str = shift;
  my @words = $str =~ m/\w+/g;
  my %seen;
  my %prop;
  for my $word (@words) {
    next if $seen{$word};
    $seen{$word} = 1;
    my $script;
    for my $char (split(//, $word)) {
      my $s = $prop{$char};
      if (not $s) {
	$s = charprop(ord($char), "Script_Extensions");
	if ($s eq 'Hiragana') {
	  $s = 'Han'; # this mixing is ok
	}
	$prop{$char} = $s;
      }
      next if $s eq "Common";
      if (not $script) {
	$script = $s;
      } elsif ($script ne $s) {
	return "Mixed scripts in $word ($script and $s, if not more)";
      }
    }
  }
}
