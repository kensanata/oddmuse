# The entire mechanism of how pages are built is now upside down.
# Instead of writing code that assembles pages, we load templates,
# that refer to pieces of code.
#
# This is the beginning of PHP-in-Perl.  :(

*BrowsePage = *DoHtmlTemplate;

# replace all actions with DoHtmlTemplate!
foreach my $key (keys %Action) {
  $Action{$key} = \&DoHtmlTemplate;
}

sub DoHtmlTemplate {
  my ($id, $raw, $comment, $status) = @_;
  if ($q->http('HTTP_IF_MODIFIED_SINCE')
      and $q->http('HTTP_IF_MODIFIED_SINCE') eq gmtime($LastUpdate)
      and GetParam('cache', $UseCache) >= 2) {
    print $q->header(-status=>'304 NOT MODIFIED');
    return;
  }
  OpenPage($id);
  my $html = HtmlTemplate();
  $html =~ s/<\?(.*?)\?>/eval $1/eg;
  print GetHttpHeader('text/html');
  print $html;
}

# Processing instructions are processed as follows:
#
# <?&foo?> -- This will call the subroutine &foo.  It's return value
# will be substituted for the processing instruction.
#
# <?$foo?> -- This substitutes the value of variable $foo.
#
# Since the processing instruction is valid XHTML, the template should
# be valid XHTML as well.

sub HtmlTemplate {

  # index
  if (GetParam('action', 'browse') eq 'index') {
    return q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title><?$SiteName?>: Index of all pages</title>
    <link type="text/css" rel="stylesheet" href="<?$StyleSheet?>" />
  </head>
  <body>
    <div class="header">
      <img class="logo" src="<?$LogoUrl?>" alt="[<?$HomePage?>]" />
      <h1><?$OpenPageName?></h1>
    </div>
    <?&PageHtml?>
  </body>
</html>};
  }

  # edit
  if (GetParam('action', 'browse') eq 'edit') {
    return q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title><?$SiteName?>: Editing <?$OpenPageName?></title>
    <link type="text/css" rel="stylesheet" href="<?$StyleSheet?>" />
  </head>
  <body>
    <div class="header">
      <img class="logo" src="<?$LogoUrl?>" alt="[<?$HomePage?>]" />
      <h1>Editing <?$OpenPageName?></h1>
    </div>
    <div class="content edit">
      <form method="post"
            action="<?$FullUrl?>"
            enctype="application/x-www-form-urlencoded">
        <p>
          <input type="hidden" name="title" value="MusicOfIslam" />
          <input type="hidden" name="oldtime" value="1101159078" />
          <textarea name="text" rows="25" cols="78"><?$Page{text}?></textarea>
        </p>
        <p>
          Zusammenfassung:
          <input type="text" name="summary"  size="60" />
        </p>
        <p>
          <input type="checkbox" name="recent_edit" value="on" />
          Dies ist eine kleinere Änderung.
        </p>
        <p>
          Benutzername:
          <input type="text" name="username" value="AlexSchroeder" size="20" maxlength="50" />
        </p>
        <p>
          <input type="submit" name="Save" value="Speichern" accesskey="s" />
          <input type="submit" name="Preview" value="Vorschau" />
        </p>
        <p>
          <a href="<?$FullUrl?>?action=edit;upload=1;id=<?$OpenPageName?>">
            Datei hochladen und den Text durch diese Datei ersetzen.
          </a>
        </p>
      </form>
    </div>
  </body>
</html>};
  }

  # browse
  return q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
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
    <div class="footer">
      <hr />
      <?&GetGotoBar?>
      <?&GetFooterLinks($id)?>
    </div>
  </body>
</html>};
}
