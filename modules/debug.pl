*OldPrintFooter = *PrintFooter;
*PrintFooter = *NewPrintFooter;

sub NewPrintFooter {
  OldPrintFooter(@_);
  print "Debug Info: $DebugInfo";
}
