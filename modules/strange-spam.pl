# Copyright (C) 2006–2015  Alex Schroeder <alex@gnu.org>
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

AddModuleDescription('strange-spam.pl', 'StrangeBannedContent');

our (%AdminPages, $OpenPageName, @MyInitVariables, %LockOnCreation, %PlainTextPages, $BannedContent);
our ($StrangeBannedContent);

$StrangeBannedContent = 'StrangeBannedContent';

*StrangeOldBannedContent = \&BannedContent;
*BannedContent = \&StrangeNewBannedContent;

push(@MyInitVariables, \&StrangeBannedContentInit);

sub StrangeBannedContentInit {
  $LockOnCreation{$StrangeBannedContent} = 1;
  $AdminPages{$StrangeBannedContent} = 1;
  $PlainTextPages{$StrangeBannedContent} = 1;
}

sub StrangeNewBannedContent {
  my $str = shift;
  my $rule = StrangeOldBannedContent($str, @_);
  return $rule if $rule;
  # changes here have effects on despam.pl!
  foreach (split(/\n/, GetPageContent($StrangeBannedContent))) {
    next unless m/^\s*([^#]+?)\s*(#\s*(\d\d\d\d-\d\d-\d\d\s*)?(.*))?$/;
    my ($regexp, $comment) = ($1, $4);
    if ($str =~ /($regexp)/ or $OpenPageName =~ /($regexp)/) {
      my $match = $1;
      $match =~ s/\n/ /g;
      return Tss('Rule "%1" matched "%2" on this page.', QuoteHtml($regexp),
		 QuoteHtml($match)) . ' '
		   . ($comment
		      ? Ts('Reason: %s.', $comment)
		      : T('Reason unknown.')) . ' '
		   . Ts('See %s for more information.',
			GetPageLink($StrangeBannedContent));
    }
  }
  return 0;
}
