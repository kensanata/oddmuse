push( @MyRules, \&DownloadSupportRule );

# [[download:page name]]

sub DownloadSupportRule {
  if (m!\G(\[\[download:$FreeLinkPattern\]\])!gc) {
    Dirty($1);
    print GetDownloadLink($2);
  }
  return '';
}
