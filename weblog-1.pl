use vars qw($WeblogTextLogo $WeblogXmlLogo);

$WeblogXmlLogo = '/images/rss.png';
$WeblogTextLogo = '/images/txt.png';

$ModulesDescription .= '<p>$Id: weblog-1.pl,v 1.2 2004/01/28 01:06:19 as Exp $</p>';

*OldWeblog1InitRequest = *InitRequest;
*InitRequest = *NewWeblog1InitRequest;

sub NewWeblog1InitRequest {
  OldWeblog1InitRequest();
  if (GetParam('blog', 1)) { # language independent!
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    $today = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time - 60*60*24);
    $yesterday = sprintf("%d-%02d-%02d", $year + 1900, $mon + 1, $mday);
    push(@UserGotoBarPages, 'Blog', $today, $yesterday);
  }
}

# cannot use ScriptLink here, because $q is not defined!

$UserGotoBar = "<a href=\"$ScriptLink?action=rss\">"
  . "<img src=\"$WeblogXmlLogo\" alt=\"XML\" class=\"XML\" /></a>"
  . ' | '
  . "<a href=\"$ScriptLink?action=rc&amp;raw=1\">"
  . "<img src=\"$WeblogTextLogo\" alt=\"TXT\" class=\"XML\" /></a>";
