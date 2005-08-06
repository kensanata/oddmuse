$EditCluster = 'EditCluster';
$DefaultStyleSheet .= '
form.edit p + p + p { display:none }
form.edit p + p + p + p { display:block }';

sub GetRc {
  my $printDailyTear = shift;
  my $printRCLine = shift;
  my @outrc = @_;
  my %extra = ();
  my %changetime = ();
  # Slice minor edits
  my $showedit = GetParam('showedit', $ShowEdits);
  # Filter out some entries if not showing all changes
  if ($showedit != 1) {
    my @temprc = ();
    foreach my $rcline (@outrc) {
      my ($ts, $pagename, $minor) = split(/$FS/, $rcline); # skip remaining fields
      if ($showedit == 0) {	# 0 = No edits
	push(@temprc, $rcline)	if (!$minor);
      } else {			# 2 = Only edits
	push(@temprc, $rcline)	if ($minor);
      }
      $changetime{$pagename} = $ts;
    }
    @outrc = @temprc;
  }
  foreach my $rcline (@outrc) {
    my ($ts, $pagename, $minor) = split(/$FS/, $rcline);
    $changetime{$pagename} = $ts;
  }
  my $date = '';
  my $all = GetParam('all', 0);
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $match, $lang) =
    map { GetParam($_, ''); }
      ('rcidonly', 'rcuseronly', 'rchostonly', 'rcclusteronly',
       'rcfilteronly', 'match', 'lang');
  my @clusters = $q->param('clusters');
  warn $#clusters, ' - ', join ', ', @clusters;
  push (@clusters, $clusterOnly) if $clusterOnly;
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
    # meatball sumamry clustering
    if (@clusters) {
      my %cluster = ();
      $cluster{$cluster} = 1 if $cluster;
      while ($summary =~ /^\[(.*)\]/g) {
	my $group = $1;
	foreach my $cluster (split(/\s*,\s*/, $group)) {
	  $cluster{$cluster} = 1;
	}
      }
      my $show = 0;
      foreach my $cluster (@clusters) {
	if ($cluster{$cluster}) {
	  $show = 1;
	  last;
	}
      }
      next unless $show;
    }
    if ($date ne CalcDay($ts)) {
      $date = CalcDay($ts);
      &$printDailyTear($date);
    }
    &$printRCLine($pagename, $ts, $host, $username, $summary, $minor, $revision,
		  \@languages, $cluster);
  }
}

*EditClusterOldRcHeader = *RcHeader;
*RcHeader = *EditClusterNewRcHeader;

sub EditClusterNewRcHeader {
  EditClusterOldRcHeader(@_);
  my @clusters = map { /\* (\S+)/; $1; } grep(/^\* /, split(/\n/, GetPageContent($EditCluster)));
  return unless @clusters;
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
  my $form = GetFormStart(undef, 'get') . $q->checkbox_group('clusters', \@clusters);
  $form .= $q->input({-type=>'hidden', -name=>'action', -value=>'rc'});
  $form .= $q->input({-type=>'hidden', -name=>'all', -value=>1}) if (GetParam('all', 0));
  $form .= $q->input({-type=>'hidden', -name=>'showedit', -value=>1}) if (GetParam('showedit', 0));
  $form .= $q->input({-type=>'hidden', -name=>'days', -value=>GetParam('days', $RcDefault)})
    if (GetParam('days', $RcDefault) != $RcDefault);
  $form .= $q->input({-type=>'hidden', -name=>'rcfilteronly', -value=>$rcfilteronly}) if $rcfilteronly;
  $form .= $q->input({-type=>'hidden', -name=>'rcuseronly', -value=>$rcuseronly}) if $rcuseronly;
  $form .= $q->input({-type=>'hidden', -name=>'rchostonly', -value=>$rchostonly}) if $rchostonly;
  $form .= $q->input({-type=>'hidden', -name=>'match', -value=>$match}) if $match;
  $form .= $q->input({-type=>'hidden', -name=>'lang', -value=>$lang}) if $lang;
  print $form, ' ', $q->submit(T('Go!')), $q->end_form();
}
