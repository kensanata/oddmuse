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

use vars qw($WeblogTextLogo $WeblogXmlLogo);

$WeblogXmlLogo = '/images/rss.png';
$WeblogTextLogo = '/images/txt.png';

$ModulesDescription .= '<p>$Id: weblog-1.pl,v 1.7 2005/01/06 11:35:04 as Exp $</p>';

$RefererTracking = 1;
$CommentsPrefix = 'Comments_on_';
$EditAllowed = 2;

push(@MyInitVariables, \&WebLog1Init);

sub WebLog1Init {
  if (GetParam('blog', 1)) {	# language independent!
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
    $today = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time - 60*60*24);
    $yesterday = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    # this modification is not mod_perl safe!
    my $blog = T('Blog');
    push(@UserGotoBarPages, $blog) unless grep (/^$blog$/, @UserGotoBarPages);
    push(@UserGotoBarPages, $today) unless grep (/^$today$/, @UserGotoBarPages);
    push(@UserGotoBarPages, $yesterday) unless grep (/^$yesterday$/, @UserGotoBarPages);
    $UserGotoBar .=
      ScriptLink('action=rss',
		 "<img src=\"$WeblogXmlLogo\" alt=\"XML\" class=\"XML\" />")
	. ' '. ScriptLink('action=rc;raw=1',
			  "<img src=\"$WeblogTextLogo\" alt=\"TXT\" class=\"XML\" />");
  }
}
