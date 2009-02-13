# Copyright (C) 2004, 2005, 2006, 2009  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: portrait-support.pl,v 1.26 2009/02/13 10:29:21 as Exp $</p>';

push(@MyMacros, sub{ s/\[new::\]/"[new:" . GetParam('username', T('Anonymous'))
		       . ':' . TimeToText($Now) . "]"/ge });
push(@MyMacros, sub{ s/\[new:$FreeLinkPattern\]/"[new:$1:" . TimeToText($Now) . "]"/ge });

push(@MyRules, \&PortraitSupportRule);

use vars qw($PortraitSupportColorDiv $PortraitSupportColor);

$PortraitSupportColor = 0;
$PortraitSupportColorDiv = 0;

my %Portraits = ();

sub PortraitSupportRule {
  if ($bol) {
    if (m/\G(\s*\n)*----+[ \t]*\n?/cg) {
      $PortraitSupportColor = 0;
      my $html = CloseHtmlEnvironments() . ($PortraitSupportColorDiv ? '</div>' : '')
	. $q->hr() . AddHtmlEnvironment('p');
      $PortraitSupportColorDiv = 0;
      return $html;
    } elsif ($bol && m/\Gportrait:$UrlPattern/gc) {
      return $q->img({-src=>$1, -alt=>T("Portrait"), -class=>'portrait'});
    } elsif ($bol && m/\G(:*)\[new(.*)\]/gc) {
      my $portrait = '';
      my $depth = length($1);
      my ($ignore, $name, $time) = split(/:/, $2, 3);
      if ($name) {
	if (not $Portrait{$name}) {
	  my $oldpos = pos;
	  if (GetPageContent($name) =~ m/portrait:$UrlPattern/) {
	    $Portrait{$name} =
	      $q->div({-class=>"portrait"},
		      $q->p(ScriptLink($name, $q->img({-src=>$1, -alt=>'new: ' . $time,
						       -class=>'portrait'}),
				       'newauthor', '', $FS),
			    $q->br(),
			    GetPageLink($name)));
	  }
	}
	$portrait = $Portrait{$name};
	$portrait =~ s/$FS/$time/;
      }
      my $html = CloseHtmlEnvironments()
	. ($PortraitSupportColorDiv ? '</div>' : '');
      $PortraitSupportColor = !$PortraitSupportColor;
      $html .= '<div class="color '
	. ($PortraitSupportColor ? 'one' : 'two')
	. ' level' . $depth
        . '">' . $portrait . AddHtmlEnvironment('p');
      $PortraitSupportColorDiv = 1;
      return $html;
    }
  }
  return undef;
}

*OldPortraitSupportApplyRules = *ApplyRules;
*ApplyRules = *NewPortraitSupportApplyRules;

sub NewPortraitSupportApplyRules {
  my ($blocks, $flags) = OldPortraitSupportApplyRules(@_);
  if ($PortraitSupportColorDiv) {
    print '</div>';
    $blocks .= $FS . '</div>';
    $flags .= $FS . 0;
    $PortraitSupportColorDiv = 0;
  }
  return ($blocks, $flags);
}
