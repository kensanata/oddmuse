$EditCluster = 'EditCluster';

sub GetRc {
  my $printDailyTear = shift;
  my $printRCLine = shift;
  my @outrc = @_;
  my %extra = ();
  my %changetime = ();
  # note that minor edits have no effect!
  foreach my $rcline (@outrc) {
    my ($ts, $pagename) = split(/$FS/, $rcline);
    $changetime{$pagename} = $ts;
  }
  my $date = '';
  my $all = GetParam('all', 0);
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $match, $lang) =
    map { GetParam($_, ''); }
      ('rcidonly', 'rcuseronly', 'rchostonly', 'rcclusteronly',
       'rcfilteronly', 'match', 'lang');
  my @clusters = $q->param('clusters'); # the clusters the user is interested in
  my $ordinary = 0;
  my %wanted_clusters = ();
  foreach (@clusters) {
    if ($_ eq T('ordinary changes')) {
      $ordinary = 1;
    } else {
      $wanted_clusters{$_} = 1;
    }
  }
  $wanted_clusters{$clusterOnly} = $clusterOnly;
  @outrc = reverse @outrc if GetParam('newtop', $RecentTop);
  my @filters;
  @filters = SearchTitleAndBody($filterOnly) if $filterOnly;
  foreach my $rcline (@outrc) {
    my ($ts, $pagename, $minor, $summary, $host, $username, $revision, $languages, $cluster)
      = split(/$FS/, $rcline);
    next if not $all and $ts < $changetime{$pagename};
    next if $idOnly and $idOnly ne $pagename;
    next if $match and $pagename !~ /$match/i;
    next if $hostOnly and $host !~ /$hostOnly/i;
    next if $filterOnly and not grep(/^$pagename$/, @filters);
    next if ($userOnly and $userOnly ne $username);
    my @languages = split(/,/, $languages);
    next if ($lang and @languages and not grep(/$lang/, @languages));
    # meatball summary clustering
    my %cluster = (); # the clusters of the page
    $cluster{$cluster} = 1 if $cluster;
    while ($summary =~ /^\[(.*)\]/g) {
      my $group = $1;
      $group = join(',', sort(split(/\s*,\s*/, $group)));
      $cluster{$group} = 1;
    }
    # user wants no cluster but page has cluster
    next if not %wanted_clusters and %cluster;
    # users wants clusters, so must match with clusters of the page;
    # if page has no clusters and user wants ordinary pages, skip the
    # test.
    if ($ordinary and not %cluster) {
      # don't skip it
    } elsif (%wanted_clusters) {
      my $show = 1;
      foreach my $cluster (keys %cluster) { # assuming "fr,CopyEdit"
	foreach $member (split(/,/, $cluster)) { # eg. "fr"
	  if ($cluster{$cluster}) {
	    $show = 1;
	    last;
	  } else {
	  }
	  next unless $show;
	}
      }
    }
    if ($date ne CalcDay($ts)) {
      $date = CalcDay($ts);
      &$printDailyTear($date);
    }
    &$printRCLine($pagename, $ts, $host, $username, $summary, 0, $revision,
		  \@languages, $cluster);
  }
}

*EditClusterOldRcHeader = *RcHeader;
*RcHeader = *EditClusterNewRcHeader;

sub EditClusterNewRcHeader {
  if (GetParam('from', 0)) {
    print $q->h2(Ts('Updates since %s', TimeToText(GetParam('from', 0))));
  } else {
    print $q->h2((GetParam('days', $RcDefault) != 1)
		 ? Ts('Updates in the last %s days', GetParam('days', $RcDefault))
		 : Ts('Updates in the last %s day', GetParam('days', $RcDefault)))
  }
  my $action;
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $match, $lang) =
    map {
      my $val = GetParam($_, '');
      print $q->p($q->b('(' . Ts('for %s only', $val) . ')')) if $val;
      $action .= ";$_=$val" if $val; # remember these parameters later!
      $val;
    }
      ('rcidonly', 'rcuseronly', 'rchostonly', 'rcclusteronly',
       'rcfilteronly', 'match', 'lang');
  if ($clusterOnly) {
    $action = GetPageParameters('browse', $clusterOnly) . $action;
  } else {
    $action = "action=rc$action";
  }
  my $days = GetParam('days', $RcDefault);
  my $all = GetParam('all', 0);
  my @menu;
  if ($all) {
    push(@menu, ScriptLink("$action;days=$days;all=0",
			   T('List latest change per page only'),'','','','',1));
  } else {
    push(@menu, ScriptLink("$action;days=$days;all=1",
			   T('List all changes'),'','','','',1));
  }
  print $q->p((map { ScriptLink("$action;days=$_;all=$all",
				($_ != 1) ? Ts('%s days', $_) : Ts('%s days', $_),'','','','',1);
		   } @RcDays), $q->br(), @menu, $q->br(),
	      ScriptLink($action . ';from=' . ($LastUpdate + 1) . ";all=$all",
			 T('List later changes')));
  my @clusters = ((map { /\* (\S+)/; $1; }
		   grep(/^\* /, split(/\n/, GetPageContent($EditCluster)))),
		  T('ordinary changes'));
  return unless @clusters;
  my $form = GetFormStart(undef, 'get') . $q->checkbox_group('clusters', \@clusters);
  $form .= $q->input({-type=>'hidden', -name=>'action', -value=>'rc'});
  $form .= $q->input({-type=>'hidden', -name=>'all', -value=>1}) if $all;
  $form .= $q->input({-type=>'hidden', -name=>'days', -value=>$days}) if $days != $RcDefault;
  $form .= $q->input({-type=>'hidden', -name=>'rcfilteronly', -value=>$rcfilteronly}) if $rcfilteronly;
  $form .= $q->input({-type=>'hidden', -name=>'rcuseronly', -value=>$rcuseronly}) if $rcuseronly;
  $form .= $q->input({-type=>'hidden', -name=>'rchostonly', -value=>$rchostonly}) if $rchostonly;
  $form .= $q->input({-type=>'hidden', -name=>'match', -value=>$match}) if $match;
  $form .= $q->input({-type=>'hidden', -name=>'lang', -value=>$lang}) if $lang;
  print $form, ' ', $q->submit(T('Go!')), $q->end_form();
}
