#! /usr/bin/perl -w

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
print header() . start_html(), p;
print 'Stop maintenance: $Id: prevent-maintenance.pl,v 1.1 2003/11/16 21:35:51 as Exp $', "\n";
if (not param('dir')) {
  print start_form, p,
    '$DataDir: ', textfield('dir', '/tmp/oddmuse'),
      p, submit('Ok'), "\n", end_form;
} elsif (param('dir') and not param('sure')) {
  print start_form, hidden('sure', 'yes'), hidden('dir', param('dir')),
    '$DataDir: ', param('dir'),
      p, submit('Confirm'), "\n", end_form;
} else {
  $time = (time) + 28 * 24 * 3600; # four weeks
  $file = param('dir') . "/maintain";
  open(F, ">$file") or die "Unable to create maintenance file";
  print F "Preventing maintenance until " . gmtime($time);
  close(F);
  utime $time, $time, $file;
  print pre(`ls -l $file`);
}
print end_html();
