%NotifyJournalPage = ();
@NotifyUrlPatterns = ();

# NotifyJournalPage maps page names matching a certain pattern to
# another page.  In the example given below, \d stands for any number.
# Thus any page name matching a date such as 2004-01-23 will map to
# the Diary page.  You can add more statements like these right here.

$NotifyJournalPage{'\d\d\d\d-\d\d-\d\d'}='Diary';

# NotifyUrlPatterns is a list of URLs to visit.  They may contain three variables:

# 1. $name is replaced by the name of the page.
# 2. $url is replaced by the URL to the page.
# 3. $rss is replaced by the RSS feed for your site.

# You can push more of these statements onto the list.

push (@NotifyUrlPatterns, 'http://ping.blo.gs/?name=$name&url=$url&rssUrl=$rss&direct=1');

# You should not need to change anything below this point.

*OldSave = *Save;
*Save = *NewSave;

sub NewSave {
  my ($id, $new, $summary, $minor, $upload) = @_;
  Save(@_);
  if (not $minor) {
    PingTracker($id);
  }
}

sub PingTracker {
  my $id = shift;
  foreach my $regexp (keys %NotifyJournalPage) {
    if ($id =~ m/$regexp/) {
      $id = $NotifyJournalPage{$regexp};
      last;
    }
  }
  if ($q->url(-base=>1) !~ m|^http://localhost|) {
    my $url;
    if ($UsePathInfo) {
      $url = $ScriptName . '/' . $id;
    } else {
      $url = $ScriptName . '?' . $id;
    }
    $url = UrlEncode($url);
    my $name = UrlEncode($SiteName . ': ' . $id);
    my $rss = UrlEncode($q->url . '?action=rss');
    require LWP::UserAgent;
    foreach $uri (@NotifyUrlPatterns) {
      $uri =~ s/\$name/$name/g;
      $uri =~ s/\$url/$url/g;
      $uri =~ s/\$rss/$rss/g;
      my $ua = LWP::UserAgent->new;
      my $request = HTTP::Request->new('GET', $uri);
      $ua->request($request);
    }
  }
}
