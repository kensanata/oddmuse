use vars qw($WeblogTextLogo $WeblogXmlLogo);

$WeblogXmlLogo = '/images/rss.png';
$WeblogTextLogo = '/images/txt.png';

$ModulesDescription .= '<p>$Id: weblog-1.pl,v 1.6 2004/01/28 01:22:53 as Exp $</p>';

*OldWeblog1InitVariables = *InitVariables;
*InitVariables = *NewWeblog1InitVariables;

sub NewWeblog1InitVariables {
  OldWeblog1InitVariables();
  if (GetParam('blog', 1)) { # language independent!
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    $today = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time - 60*60*24);
    $yesterday = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    # this modification is not mod_perl safe!
    push(@UserGotoBarPages, T('Blog'), $today, $yesterday);
    $UserGotoBar .=
      ScriptLink('action=rss',
		 "<img src=\"$WeblogXmlLogo\" alt=\"XML\" class=\"XML\" />")
      . ' | '
      . ScriptLink('action=rc;raw=1',
		   "<img src=\"$WeblogTextLogo\" alt=\"TXT\" class=\"XML\" />");
  }
}
