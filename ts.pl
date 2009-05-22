# some routines taken from wiki.pl to help debug: it translates Perl
# times into human readable times

sub CalcDay {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf('%4d-%02d-%02d', $year+1900, $mon+1, $mday);
}

sub CalcTime {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf('%02d:%02d:%02d UTC', $hour, $min, $sec);
}

sub CalcTimeSince {
  my $total = shift;
  if ($total >= 7200) {
    return Ts('%s hours ago',int($total/3600));
  } elsif ($total >= 3600) {
    return T('1 hour ago');
  } elsif ($total >= 120) {
    return Ts('%s minutes ago',int($total/60));
  } elsif ($total >= 60) {
    return T('1 minute ago');
  } elsif ($total >= 2) {
    return Ts('%s seconds ago',int($total));
  } elsif ($total == 1) {
    return T('1 second ago');
  } else {
    return T('just now');
  }
}

sub TimeToText {
  my $t = shift;
  return CalcDay($t) . ' ' . CalcTime($t);
}

# Complete date plus hours and minutes: YYYY-MM-DDThh:mmTZD (eg
# 1997-07-16T19:20+01:00)
sub TimeToW3 {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  # use special UTC designator ("Z")
  return sprintf('%4d-%02d-%02dT%02d:%02dZ', $year+1900, $mon+1, $mday, $hour, $min);
}

sub TimeToRFC822 {
  my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime(shift);
  # Sat, 07 Sep 2002 00:00:01 GMT
  return sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT",
		 qw(Sun Mon Tue Wed Thu Fri Sat)[$wday], $mday,
		 qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon],
		 $year+1900, $hour, $min, $sec);
}

while(<>) {
  s/(\d\d\d\d\d+)/TimeToText($1)/ge;
  print;
}
