$ModulesDescription .= '<p>$Id: calendar.pl,v 1.1 2004/01/30 01:45:27 as Exp $</p>';

*OldCalendarGetHeader = *GetHeader;
*GetHeader = *NewCalendarGetHeader;

sub NewCalendarGetHeader {
  my $header = OldCalendarGetHeader(@_);
  my $cal = Cal();
  $header =~ s/<div class="header">/$cal<div class="header">/;
  return $header;
}

sub Cal {
  my $cal = `cal`;
  return unless $cal;
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($Now);
  $cal =~ s|\b( ?\d?\d)\b|{
    my $day = $1;
    my $date = sprintf("%d-%02d-%02d", $year+1900, $mon+1, $day);
    my $class = ($day == $mday) ? 'today'
              : ($IndexHash{$date} ? 'exists' : 'wanted');
    "<a class=\"$class\" href=\"$ScriptName/$date\">$day</a>";
    }|ge;
  return "<div class=\"cal\"><pre>$cal</pre></div>";
}
