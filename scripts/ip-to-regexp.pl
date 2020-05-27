use Modern::Perl;
use Net::Whois::Parser qw/parse_whois/;

sub main {
  my $ip = shift(@ARGV);
  die "Provide an IP number as argument.\n" unless $ip;
  print get_regexp_ip(get_range($ip)), "\n";
}

sub get_range {
  my $ip = shift;
  my $response = parse_whois(domain => $ip);
  my $re = '(?:[0-9]{1,3}\.){3}[0-9]{1,3}';
  my ($start, $end) = $response->{inetnum} =~ /($re) *- *($re)/;
  return $start, $end;
}

sub get_groups {
  my ($from, $to) = @_;
  my @groups;
  if ($from < 10) {
    my $to = $to >= 10 ? 9 : $to;
    push(@groups, [$from, $to]);
    $from = $to + 1;
  }
  while ($from < $to) {
    my $to = int($from/100) < int($to/100) ? $from + 99 - $from % 100 : $to;
    if ($from % 10) {
      push(@groups, [$from, $from + 9 - $from % 10]);
      $from += 10 - $from % 10;
    }
    if (int($from/10) < int($to/10)) {
      if ($to % 10 == 9) {
	push(@groups, [$from, $to]);
	$from = 1 + $to;
      } else {
	push(@groups, [$from, $to - 1 - $to % 10]);
	$from = $to - $to % 10;
      }
    } else {
      push(@groups, [$from - $from % 10, $to]);
      last;
    }
    if ($to % 10 != 9) {
      push(@groups, [$from, $to]);
      $from = 1 + $to; # jump from 99 to 100
    }
  }
  return \@groups;
}

sub get_regexp_range {
  my @chars;
  for my $group (@{get_groups(@_)}) {
    my ($from, $to) = @$group;
    my $char;
    for (my $i = length($from); $i >= 1; $i--) {
      if (substr($from, - $i, 1) eq substr($to, - $i, 1)) {
	$char .= substr($from, - $i, 1);
      } else {
	$char .= '[' . substr($from, - $i, 1) . '-' . substr($to, - $i, 1). ']';
      }
    }
    push(@chars, $char);
  }
  return join('|', @chars);
}

sub get_regexp_ip {
  my ($from, $to) = @_;
  my @start = split(/\./, $from);
  my @end = split(/\./, $to);
  my $regexp = "^";
  for my $i (0 .. 3) {
    if ($start[$i] eq $end[$i]) {
      $regexp .= $start[$i];
    } elsif ($start[$i] eq '0' and $end[$i] eq '255') {
      last;
    } elsif ($start[$i + 1] > 0) {
      $regexp .= '(' . $start[$i] . '\.('
	  . get_regexp_range($start[$i + 1], '255') . ')|'
	  . get_regexp_range($start[$i] + 1, $end[$i + 1]) . ')';
      $regexp .= '\.';
      last;
    } else {
      $regexp .= '(' . get_regexp_range($start[$i], $end[$i]) . ')$';
      last;
    }
    $regexp .= '\.' if $i < 3;
  }
  return $regexp;
}

main();
