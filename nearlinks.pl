
*OldBrowseResolvedPage = *BrowseResolvedPage;
*BrowseResolvedPage = *NewBrowseResolvedPage;

sub NewBrowseResolvedPage {
  my $id = shift;
  my ($class, $new, $title) = ResolveId($id);
  if ($class eq 'near' && not GetParam('rcclusteronly', 0)) {
    print $q->redirect({-uri=>$NearSite{$title} . $new});
  } else {
    OldBrowseResolvedPage($id);
  }
}

*OldResolveId = *ResolveId;
*ResolveId = *NewResolveId;

my %NearPage = ();
my %NearSite = ();
my %NearLinksUsed = ();

sub NearInit {
  if (not %NearPage) {
    GetSiteUrl(); # make sure %InterSite is set
    local $/ = undef;
    foreach my $site (keys %InterSite) {
      open(F, $DataDir . '/' . $site) or next;
      my $data = <F>;
      close(F);
      foreach (split(/\n/, $data)) {
        if (not $NearPage{$_}) {
          $NearPage{$_} = $_;
          $NearSite{$_} = $site;
        }
      }
    }
  }
}

sub NewResolveId {
  my $id = shift;
  my @result = OldResolveId($id);
  return @result if $result[1];
  NearInit();
  if ($NearPage{$id}) {
    $NearLinksUsed{$NearPage{$id}} = 1 ;
    return ('near', $NearPage{$id}, $NearSite{$id});
  }
}

my $MyFootnoteCounter = 0;
my @MyFootnotes = ();

sub MyRules {
  if ((-f GetLockedPageFile($OpenPageName))
      and (/\G(\&lt;form.*?\&lt;\/form\&gt;)/sgc)) {
    return UnquoteHtml($1);
  } elsif (/\G(Page alias: $LinkPattern)\n/gc
	   or /\G(PageAlias: $FreeLinkPattern)\n/gc) {
    Dirty($1);
    print GetPageLink('PageAlias', 'Page alias')
      . ': ' . GetPermanentAnchor($2);
  } elsif (m/\G(\[\[\[(.*?)\]\]\])/gcs) {
    Dirty($1);
    push(@MyFootnotes,$2);
    $MyFootnoteCounter++;
    print $q->a({-href=>'#'.$MyFootnoteCounter,
		 -name=>'f'.$MyFootnoteCounter,
		 -title=>$2,
		 -class=>'footnote'},
		$MyFootnoteCounter);
  } elsif (m/\G!\+\+\+/gc) {
    return '+++';
  } elsif (m/\Gportrait:$UrlPattern/gc) {
    return $q->img({-src=>$1, -alt=>T("Portrait"), -class=>'portrait'});
  } elsif (m/\GMy\s+subscribed\s+pages:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)+)categories:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)*(?:$LinkPattern|\[\[$FreeLinkPattern\]\]))/gc) {
    return Subscribe($1, $4);
  } elsif (m/\GMy\s+subscribed\s+pages:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)*(?:$LinkPattern|\[\[$FreeLinkPattern\]\]))/gc) {
    return Subscribe($1, '');
  } elsif (m/\GMy\s+subscribed\s+categories:\s*((?:(?:$LinkPattern|\[\[$FreeLinkPattern\]\]),\s*)*(?:$LinkPattern|\[\[$FreeLinkPattern\]\]))/gc) {
    return Subscribe('', $1);
  }
  return '';
}

sub Subscribe {
  my ($pages, $categories) = @_;
  my $oldpos = pos;
  my @pageslist = map {
    if (/\[\[$FreeLinkPattern\]\]/) {
      FreeToNormal($1);
    } else {
      $_;
    }
  } split(/\s*,\s*/, $pages);
  my @catlist = map {
    if (/\[\[$FreeLinkPattern\]\]/) {
      FreeToNormal($1);
    } else {
      $_;
    }
  } split(/\s*,\s*/, $categories);
  my $regexp;
  $regexp .= '^(' . join('|', @pageslist) . ")\$" if @pageslist;
  $regexp .= '|' if @pageslist and @catlist;
  $regexp .= '(' . join('|', @catlist) . ')' if @catlist;
  pos = $oldpos;
  my $html = 'My subscribed ';
  return $html unless @pageslist or @catlist;
  $html .= 'pages: ' . join(', ', map { s/_/ /g; $_; } @pageslist)
    if @pageslist;
  $html .= ', ' if @pageslist and @catlist;
  $html .= 'categories: ' . join(', ', map { s/_/ /g; $_; } @catlist)
    if @catlist;
  return ScriptLink('action=rc;rcfilteronly=' . $regexp, $html);
}

*OldPrintFooter = *PrintFooter;
*PrintFooter = *NewPrintFooter;

sub NewPrintFooter {
  my @params = @_;
  my $html;
  if ($MyFootnoteCounter) {
    for (my $i = 1; $i <= $MyFootnoteCounter; $i++) {
      $html .= '<br>' if $html;
      $html .= $q->a({-name=>$i,
		      -href=>'#f'.$i},
		     $i . '.' ) . ' ' . shift @MyFootnotes;
    }
    print $q->div({-class=>'footnotes'},
		  $q->hr(), $q->p(T('Footnotes:')), $q->p($html));
  }
  OldPrintFooter(@params);
}


sub PrintMyContent {
  my $id = (shift);
  NearInit();
  if ($NearPage{$id}) {
    print $q->div({-class=>'sister'}, $q->hr(),
                  $q->p(T('The same page on other sites:'), $q->br(),
			$q->a({-href=>GetSiteUrl($NearSite{$id}) . $id,
                               -title=>$NearSite{$id} . ':' . $id},
                              $q->img({-src=>'/community/'
                                       . $NearSite{$id} . '.png',
                                       -alt=>T('SisterSite:') . ' '
                                       . $NearSite{$id} . ':' . $id}))));
  }
  if (%NearLinksUsed) {
    print $q->div({-class=>'near'}, $q->p(GetPageLink(T('EditNearLinks')) . ':',
      join(' ', map { GetEditLink($_, $_); } keys %NearLinksUsed)));
  }
  if (GetParam('debug', 0)) {
    print $q->div({-class=>'debug'}, $q->hr(),
		  $q->p('Debug: ', ));
  }
}

