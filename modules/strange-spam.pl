# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: strange-spam.pl,v 1.8 2006/08/15 09:23:16 as Exp $</p>';

use vars qw($StrangeBannedContent);

$StrangeBannedContent = 'StrangeBannedContent';

*StrangeOldBannedContent = *BannedContent;
*BannedContent = *StrangeNewBannedContent;

# copy scalar
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
  foreach (grep /./, map {
    s/#.*//;  # trim comments
    s/^\s+//; # trim leading whitespace
    s/\s+$//; # trim trailing whitespace
    $_; } split(/\n/, GetPageContent($StrangeBannedContent))) {
    my $regexp = $_;
    next unless $regexp; # skip empty strings
    if ($str =~ /($regexp)/i) {
      return Tss('Rule "%1" matched "%2" on this page.', QuoteHtml($regexp), $1);
    }
  }
  return 0;
}
