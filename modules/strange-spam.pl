# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: strange-spam.pl,v 1.18 2007/11/28 09:34:36 as Exp $</p>';

use vars qw($StrangeBannedContent);

$StrangeBannedContent = 'StrangeBannedContent';

*StrangeOldBannedContent = *BannedContent;
*BannedContent = *StrangeNewBannedContent;
$BannedContent = $StrangeOldBannedContent;

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
