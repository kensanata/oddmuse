# Copyright (C) 2005 Bart van Kuik <bart@vankuik.nl>
# Copyright (C) 2010 Bertrand Habib <hbbb05@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/adsense.pl">adsense.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/AdSense_Module">AdSense Module</a></p>';

use vars qw($AdSensePageName $AdSensePlace);

push (@MyInitVariables, \&AdSenseInit);

sub AdSenseInit {
  $AdSensePageName = "AdSense" unless $AdSensePageName;
  $AdSensePlace = "top" unless $AdSensePlace;	   
  if ($AdSensePlace eq 'bottom') {  # Process adsense after all modules have been loaded
    push (@MyFooters, \&GetAdSense);
  } elsif ($AdSensePlace eq 'top')  {
   *AdSenseOldGetHtmlHeader = *GetHtmlHeader;
   *GetHtmlHeader = *AdSenseNewGetHtmlHeader;
  }
}

sub AdSenseNewGetHtmlHeader {
  my $result = AdSenseOldGetHtmlHeader(@_);
  $result .= GetAdSense();
  return $result;
}

sub GetAdSense {
  return GetPageContent($AdSensePageName) if GetParam('action', 'browse') eq 'browse';
}

