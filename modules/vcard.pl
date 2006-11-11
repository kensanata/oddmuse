# We just try to autodetect everything.

push(@MyRules, \&hCardRule);

my $addr = qr(\G(\S+ \S+)
(.*)
((?:[A-Z][A-Z]?-)?\d+) (.*)(?:
(.*))?

);

my $email = qr(\G\s*(\S+@\S+)\n?);

my $tel = qr(\G\s*(\S+): (\+?[-0-9 ]+)\n?);

sub hCardRule {
  return undef unless $bol;
  my ($fn, $street, $zip, $city, $country) = /$addr/cg;
  if ($fn) {
    my ($mail) = /$email/cg;
    my ($phonetype, $phone) = /$tel/cg;
    my $html = $q->span({-class=>'fn'}, $fn) . $q->br();
    $html .= $q->span({-class=>'street-address'}, $street) . $q->br();
    $html .= $q->span({-class=>'postal-code'}, $zip)
      . ' ' . $q->span({-class=>'locality'}, $city);
    $html .= $q->br()
      . $q->span({-class=>'country-name'}, $country) if $country;
    my $hCard = $q->p($html);
    $html = '';
    $html .= $q->span({-class=>'email'},
		      $q->a({-href=>'mailto:' . $mail}, $mail)) if $mail;
    $html .= $q->br() if $mail and $phone;
    $html .= $q->span({-class=>'tel'},
		      $q->span({-class=>'type'}, $phonetype) . ': '
		      . $q->span({-class=>'value'}, $phone)) if $phone;
    $hCard .= $q->p($html) if $html;
    $hCard = $q->div({-class=>'vcard',
		      -style=>'color:red;'}, $hCard);
    return CloseHtmlEnvironments() . $hCard . AddHtmlEnvironment('p');
  }
  return undef;
}
