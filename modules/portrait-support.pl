# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: portrait-support.pl,v 1.10 2004/08/06 19:54:56 as Exp $</p>';

push(@MyMacros, sub{ s/\[new::\]/"[new:" . GetParam('username', T('Anonymous'))
		       . ':' . TimeToText($Now) . "]"/ge });
push(@MyMacros, sub{ s/\[new(:[^]:]+)\]/"[new$1:" . TimeToText($Now) . "]"/ge });

push(@MyRules, \&PortraitSupportRule);

my $MyColor = 0;
my $MyColorDiv = 0;
my %Portraits = ();

sub PortraitSupportRule {
  if ($bol && m/\G(\s*\n)*----+[ \t]*\n?/cg) {
    $MyColor = 0;
    return CloseHtmlEnvironments() . ($MyColorDiv ? '</div>' : '') . $q->hr();
  } elsif ($bol && m/\G(\s*\n)*(\=+)[ \t]*(.+?)[ \t]*(=+)[ \t]*\n?/cg) {
    my ($depth, $text) = ($2, $3);
    $depth = length($depth);
    $depth = 6  if ($depth > 6);
    $MyColor = 0;
    return CloseHtmlEnvironments() . ($MyColorDiv ? '</div>' : '') . "<h$depth>$text</h$depth>";
  } elsif (m/\Gportrait:$UrlPattern/gc) {
    return $q->img({-src=>$1, -alt=>T("Portrait"), -class=>'portrait'});
  } elsif (m/\G\[new(.*)\]/gc) {
    my $portrait;
    my ($ignore, $name, $time) = split(/:/, $1, 3);
    if ($name) {
      if (not $Portrait{$name}) {
	my $oldpos = pos;
	if (GetPageContent($name) =~ m/portrait:$UrlPattern/) {
	  $Portrait{$name} =
	    $q->div({-class=>'portrait'},
		    ScriptLink($name, $q->img({-src=>$1, -alt=>'new: ' . $time,
					       -class=>'portrait'}),
			       'newauthor', '', $FS),
		    $q->br(),
		    GetPageLink($name));
	}
      }
      $portrait = $Portrait{$name};
      $portrait =~ s/$FS/$time/;
    }
    $MyColor = !$MyColor;
    my $html;
    $html = '</div>' if $MyColorDiv;
    $MyColorDiv = 1;
    return $html . CloseHtmlEnvironments()
      . '<div class="color ' . ($MyColor ? 'one' : 'two') . '">'
      . '<p>' . $portrait;
  }
  return undef;
}

*OldPortraitSupportApplyRules = *ApplyRules;
*ApplyRules = *NewPortraitSupportApplyRules;

sub NewPortraitSupportApplyRules {
  my ($blocks, $flags) = OldPortraitSupportApplyRules(@_);
  if ($MyColorDiv) {
    print '</div>';
    $blocks .= $FS . '</div>';
    $flags .= $FS . 0;
    $MyColorDiv = 0;
  }
  return ($blocks, $flags);
}
