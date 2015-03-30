# Copyright (C) 2012  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;

package OddMuse;

AddModuleDescription('banned-regexps.pl', 'Banning Regular Expressions');

=h1 Compatibility

This extension works with logbannedcontent.pl.

=h1 Example content for the BannedRegexps page:

    # This page lists regular expressions that prevent the saving of a page.
    # The regexps are matched against any page or comment submitted.
    # The format is simple: # comments to the end of the line. Empty lines are ignored.
    # Everything else is a regular expression. If the regular expression is followed by
    # a comment, this is used as the explanation when a user is denied editing. If the
    # comment starts with a date, this date is not included in the explanation.
    # The date could help us decide which regular expressions to delete in the future.
    # In other words:
    # ^\s*([^#]+?)\s*(#\s*(\d\d\d\d-\d\d-\d\d\s*)?(.*))?$
    # Group 1 is the regular expression to use.
    # Group 4 is the explanation to use.

    порно # 2012-12-31 Russian porn
    <a\s+href=["']?http # 2012-12-31 HTML anchor tags usually mean spam
    \[url= # 2012-12-31 bbCode links usually mean spam
    \s+https?:\S+[ .\r\n]*$ # 2012-12-31 ending with a link usually means spam
    (?s)\s+https?:\S+.*\s+https?:\S+.*\s+https?:\S+.* # 2012-12-31 three naked links usually mean spam

=cut

use vars qw(%AdminPages %LockOnCreation @MyInitVariables %PlainTextPages $BannedContent $BannedFile);
use vars qw($BannedRegexps);

$BannedRegexps = 'BannedRegexps';

push(@MyInitVariables, sub {
       $AdminPages{$BannedRegexps} = 1;
       $LockOnCreation{$BannedRegexps} = 1;
       $PlainTextPages{$BannedRegexps} = 1;
     });

*RegexpOldBannedContent = \&BannedContent;
*BannedContent = \&RegexpNewBannedContent;

sub RegexpNewBannedContent {
  my $str = shift;
  my $rule = RegexpOldBannedContent($str, @_);
  if (not $rule) {
    foreach (split(/\n/, GetPageContent($BannedRegexps))) {
      next unless m/^\s*([^#]+?)\s*(#\s*(\d\d\d\d-\d\d-\d\d\s*)?(.*))?$/;
      my ($regexp, $comment, $re) = ($1, $4, undef);
      eval { $re = qr/$regexp/i; };
      if (defined($re) && $str =~ $re) {
	my $group1 = $1;
	my $explanation = ($group1
			   ? Tss('Regular expression "%1" matched "%2" on this page.', QuoteHtml($regexp), $group1)
			   : Ts('Regular expression "%s" matched on this page.', QuoteHtml($regexp)));
        $rule = $explanation . ' '
          . ($comment ? Ts('Reason: %s.', $comment) : T('Reason unknown.')) . ' '
          . Ts('See %s for more information.', GetPageLink($BannedRegexps));
        last;
      }
    }
  }
  LogWrite($rule) if $rule and $BannedFile;
  return $rule if $rule;
  return 0;
}
