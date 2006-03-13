$Action{journal} = \&PullJournal;

sub PullJournal {
  my ($num, $regexp, $mode, $offset) = @_;
  my $num = GetParam('num', 10);
  my $regexp = GetParam('regexp', '^\d\d\d\d-\d\d-\d\d');
  my $mode = GetParam('mode', '');
  my $offset = GetParam('offset', 0);
  print GetHttpHeader('text/xml');
  PrintJournal($num, $regexp, $mode, $offset);
}
