# Copyright (C) 2005  Bayle Shanks http://purl.net/net/bshanks
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

use strict;
use v5.10;

our ($Now, @MyMacros, @MyRules, $DefaultStyleSheet, $q, $bol);

AddModuleDescription('agree-disagree.pl', 'AgreeDisagreePlugin');

push(@MyRules, \&AgreeDisagreeSupportRule);

push(@MyMacros, sub{ s/\[\+\]/"[+:" . GetParam('username', T('Anonymous'))
                       . ':' . TimeToText($Now) . "]"/ge });
push(@MyMacros, sub{ s/\[\+(:[^]:]+)\]/"[+$1:" . TimeToText($Now) . "]"/ge });
push(@MyMacros, sub{ s/\[\-\]/"[-:" . GetParam('username', T('Anonymous'))
                       . ':' . TimeToText($Now) . "]"/ge });
push(@MyMacros, sub{ s/\[\-(:[^]:]+)\]/"[-$1:" . TimeToText($Now) . "]"/ge });


$DefaultStyleSheet .= <<'EOT' unless $DefaultStyleSheet =~ /div\.agree/; # mod_perl?
    div.agreeCount {
 float: left;
 clear: left;
background-color: Green;
padding-left: .5em;
padding-right: .5em;
padding-top: .5em;
padding-bottom: .5em;
}
div.disagreeCount {
  float: left;
 clear: right;
background-color: Red;
padding-left: .5em;
padding-right: .5em;
padding-top: .5em;
padding-bottom: .5em;
}

div.agreeNames {
  float: left;
background-color: Green;
font-size: xx-small;
 display: none;
}
div.disagreeNames {
  float: left;
background-color: Red;
font-size: xx-small;
 display: none;
}



EOT




    my %AgreePortraits = ();


sub AgreeDisagreeSupportRule {
  if ($bol) {
    if ($bol && m/(\G(\s*\[\+(.*?)\]|\s*\[-(.*?)\])+)/gcs) {

      my $votes = $1;
      my @ayes = ();
      my @nayes = ();
      while ($votes =~ m/\G.*?\[\+(.*?)\]/gcs) {
        my ($ignore, $name, $time) = split(/:/, $1, 3);
        push(@ayes, $name);
      }
      my $votes2 = $votes;
      while ($votes2 =~ m/\G.*?\[-(.*?)\]/gcs) {
        my ($ignore, $name, $time) = split(/:/, $1, 3);
        push(@nayes, $name);
      }

      my $html = CloseHtmlEnvironments() ;
      $html .= $q->div({-class=>'agreeCount'}) . ($#ayes+1) . '  ' . '</div>' ;

      $html .= $q->div({-class=>'agreeNames'}) . printNames(@ayes) . '</div>' ;
      $html .= $q->div({-class=>'disagreeCount'}) . '  ' . ($#nayes+1) . '</div>' ;
      $html .= $q->div({-class=>'disagreeNames'}) . printNames(@nayes) . '</div>' ;


      return $html;
    }
  }
  return undef;
}


sub printNames {
  my @names = @_;

  my $html = '';
  foreach my $name (@names)  {
    $html .= "$name<br>";
  }
  return $html;
}
