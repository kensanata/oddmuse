$ModulesDescription .= '<p>$Id: portrait-support.pl,v 1.6 2004/01/30 11:47:15 as Exp $</p>';

push(@MyMacros, sub{ s/\[new(:[^]:]*)\]/"[new$1:" . TimeToText($Now) . "]"/ge });

push(@MyRules, \&PortraitSupportRule);

my $MyColor = 0;
my $MyColorDiv = 0;
my %Portraits = ();

sub PortraitSupportRule {
  if (m/\Gportrait:$UrlPattern/gc) {
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
		    ScriptLink($name, $q->img({-src=>$1, -alt=>'', -class=>'portrait'}),
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
      . '<div class="color" style="background-color:'
      . ($MyColor ? "#eee" : "#fff") . '">'
      . '<p><span class="new">[new]</span>' . $portrait;
  }
  return '';
}

*OldPortraitSupportWikiHeading = *WikiHeading;
*WikiHeading = *NewPortraitSupportWikiHeading;

sub NewPortraitSupportWikiHeading {
  my $html;
  $html = '</div>' if $MyColorDiv;
  return $html . OldPortraitSupportWikiHeading(@_);
}

*OldPortraitSupportApplyRules = *ApplyRules;
*ApplyRules = *NewPortraitSupportApplyRules;

sub NewPortraitSupportApplyRules {
  my ($blocks, $flags) = OldPortraitSupportApplyRules(@_);
  if ($MyColorDiv) {
    print '</div>';
    $blocks .= $FS . '</div>';
    $flags .= $FS . 0;
  }
  return ($blocks, $flags);
}
