use Time::ParseDate;

$ModulesDescription .= '<p>$Id: weblog-2.pl,v 1.2 2004/01/30 01:20:44 as Exp $</p>';

*OldWeblog2InitVariables = *InitVariables;
*InitVariables = *NewWeblog2InitVariables;

sub NewWeblog2InitVariables {
  OldWeblog2InitVariables();
  my $id = join('_', $q->keywords);
  $id = $q->path_info() unless $id;
  my $current;
  ($current, $year, $mon, $mday) = ($id =~ m|^/?((\d\d\d\d)-(\d\d)-(\d\d))|);
  if ($current and $current ne $today) {
    my $time = parsedate($current, GMT => 1);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime($time - 60*60*24);
    my $previous = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime($time + 60*60*24);
    my $next = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    push(@UserGotoBarPages,$next) unless grep(/^$next$/, @UserGotoBarPages);
    push(@UserGotoBarPages,$current) unless grep(/^$current$/, @UserGotoBarPages);
    push(@UserGotoBarPages,$previous) unless grep(/^$previous$/, @UserGotoBarPages);
  }
}
