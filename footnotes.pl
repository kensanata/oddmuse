$ModulesDescription .= '<p>$Id: footnotes.pl,v 1.1 2004/01/28 21:34:01 as Exp $</p>';

my $MyFootnoteCounter = 0;
my @MyFootnotes = ();

push(@MyRules, \&FootnoteRule);

sub FootnoteRule {
  if (m/\G(\[\[\[(.*?)\]\]\])/gcs) {
    Dirty($1);
    push(@MyFootnotes,$2);
    $MyFootnoteCounter++;
    print $q->a({-href=>'#'.$MyFootnoteCounter,
		 -name=>'f'.$MyFootnoteCounter,
		 -title=>$2,
		 -class=>'footnote'},
		$MyFootnoteCounter);
  }
  return '';
}

*OldFootnotePrintFooter = *PrintFooter;
*PrintFooter = *NewFootnotePrintFooter;

sub NewFootnotePrintFooter {
  my @params = @_;
  if ($MyFootnoteCounter) {
    print '<div class="footnotes">' . $q->hr(), $q->p(T('Footnotes:')) . '<p>';
    for (my $i = 1; $i <= $MyFootnoteCounter; $i++) {
      print "<br />" if $i > 1;
      print $q->a({-name=>$i, -href=>'#f'.$i}, $i . '.' ) . ' ';
      ApplyRules(shift(@MyFootnotes), 1);
    }
    print '</p></div>';
  }
  OldFootnotePrintFooter(@params);
}
