$Action{despam} = \&DoDespam;

my @DespamRules = ();

sub DoDespam {
  RequestLockOrError();
  my @pages = DespamPages();
  print GetHeader('', T('Despamming pages'), '') . '<div class="content"><p>';
  foreach my $id (@pages) {
    next if $id eq $BannedContent;
    OpenPage($id);
    my $title = $id;
    $title =~ s/_/ /g;
    my $rule = DespamBannedContent($Page{text});
    print GetPageLink($id, $title);
    DespamPage($rule) if $rule;
    print $q->br();
  }
  print '</p></div>';
  PrintFooter();
  ReleaseLock();
}

# Based on BannedContent(), but with caching
sub DespamBannedContent {
  my $str = shift;
  @DespamRules = split(/\n/, GetPageContent($BannedContent));
  foreach (@DespamRules) {
    if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
      my $rule = $1;
      if ($str =~ /($rule)/i) {
	my $match = $1;
	return Tss('Rule "%1" matched "%2" on this page.', $rule, $match);
      }
    }
  }
  return 0;
}

sub DespamPages {
  my @pages = AllPagesList(); # only check recently changed pages?
  return @pages;
}

sub DespamPage {
  my $rule = shift;
  # from DoHistory()
  my @revisions = sort {$b <=> $a} map { m|/([0-9]+).kp$|; $1; } GetKeepFiles($OpenPageName);
  foreach my $revision (@revisions) { # remember the last revision checked
    my ($text, $rev) = GetTextRevision($revision, 1); # quiet
    if (not $rev) {
      print ': ' . Ts('Cannot find revision %s.', $revision);
      return;
    } elsif (not DespamBannedContent($text)) {
      my $summary = Tss('Revert to revision %1: %2', $revision, $rule);
      print ': ' . $summary;
      Save($OpenPageName, $text, $summary);
      return;
    }
  }
  if (grep(/^1$/, @revisions) or not @revisions) { # if there is no kept revision, yet
    my $summary = Ts($rule). ' ' . Ts('Marked as %s.', $DeletedPage);
    print ': ' . $summary;
    Save($OpenPageName, $DeletedPage, $summary);
  } else {
    print ': ' . T('Cannot find unspammed revision.'. $revision);
  }
}
