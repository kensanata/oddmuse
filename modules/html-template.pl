# Uses the template in the $DataDir and processess processing
# instructions as follows:  <?&foo?>.  This will call the subroutine
# &foo.  It's return value will be substituted for the processing
# instruction.  Similarly, <?$foo?> will substitute the value of
# variable $foo.  Since the processing instruction is valid XHTML, the
# template should be valid XHTML as well.

sub HtmlTemplate {
  return q{
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title><?$SiteName?>: <?$OpenPageName?></title>
    <link type="text/css" rel="stylesheet" href="<?$StyleSheet?>" />
  </head>
  <body>
    <div class="header">
      <img class="logo" src="<?$LogoUrl?>" alt="[<?$HomePage?>]" />
      <h1><?$OpenPageName?></h1>
    </div>
    <?&PageHtml?>
  </body>
</html>}
}

$Action{template} = \&DoHtmlTemplate;

sub DoHtmlTemplate {
  my $id = GetParam('id', $HomePage);
  my $html = HtmlTemplate();
  OpenPage($id);
  $html =~ s/<\?(.*?)\?>/eval $1/eg;
  print GetHttpHeader('text/html');
  print $html;
}
