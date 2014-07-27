(quotemeta($domain));
    $q->a({-href => $_}, $domain)
	. " (" . $q->a({-href => "$self/match/$term"}, $blog{$_}) . ")";
  } @list;
  return \@list;
}

sub match {
  my $term = shift;
  # start with the homepage
  my @list;
  my $title;
  for my $id (GetPageContent($HomePage) =~ /\* \[\[(.*?)\]\]/g) {
    for my $line (split /\n/, GetPageContent(FreeToNormal($id))) {
      if ($line =~ /^\*+\s+([^][\n]*)$/) {
	$title = $1;
      } elsif ($line =~ /$term/o) {
	if ($line =~ /^\*+\s+\[(https?:\S+)\s+([^]]+)\]/) {
	  push (@list, $q->a({-href => $1}, $2) . " (" . $title . ")");
	}
      }
    }
  }
  return \@list;
}

sub html_toc {
  my ($values, $labels) = toc();
  return $q->radio_group(-name =>'toc',
			 -values => $values,
			 -labels => $labels,
			 -linebreak=>'true');
}

sub default {
  print $q->p("Add a link to the " . $q->a({-href=>$home}, $name) . ".");
  print $q->start_multipart_form(-method=>'get', -class=>'submit');
  print $q->p($q->label({-for=>'url'}, T('URL:')) . ' '
	      . $q->textfield(-name=>'url', -id=>'url', -size=>80));
  print $q->p({-style=>'font-size: 10pt'},
	      "(Drag this bookmarklet to your bookmarks bar for easy access:",
	      $q->a({-href=>q{javascript:location='}
		   . $q->url()
		   . qq{?url='+encodeURIComponent(window.location.href)}},
		    "Submit $name") . ".)");
  print html_toc();
  print $q->submit('go', 'Add!');
  print $q->end_form();
}

sub confirm {
  my ($url, $name, $toc) = @_;
  print $q->p("Please confirm that you want to add "
	      . GetUrl($url, $name)
	      . " to the section “$toc”.");
  print $q->start_form(-method=>'get');
  print $q->p($q->label({-for=>'name', -style=>'display: inline-block; width: 15em'},
			T('Use a different link name:')) . ' '
	      . $q->textfield(-style=>'display: inline-block; width:50ex',
			      -name=>'name', -id=>'name', -size=>50, -default=>$name)
	      . $q->br()
	      . $q->label({-for=>'summary', -style=>'display: inline-block; width:15em'},
			  T('An optional short summary:')) . ' '
	      . $q->textfield(-style=>'display: inline-block; width:50ex',
			      -name=>'summary', -id=>'summary', -size=>50)
	      . $q->br()
	      . $q->label({-for=>'username', -style=>'display: inline-block; width:15em'},
			  T('Your name for the log file:')) . ' '
	      . $q->textfield(-style=>'display: inline-block; width:50ex',
			      -name=>'username', -id=>'username', -size=>50));
  my $star = $q->img({-src=>$stardata, -class=>'smiley', -alt=>'☆'});
  print '<p>Optionally: Do you want to rate it?<br />';
  my $i = 0;
  foreach my $label ($q->span({-style=>'display: inline-block; width:3em'}, $star)
		     . 'I might use this for my campaign',
		     $q->span({-style=>'display: inline-block; width:3em'}, $star x 2)
		     . 'I have used this in a campaign and it worked as intended',
		     $q->span({-style=>'display: inline-block; width:3em'}, $star x 3)
		     . 'I have used this in a campaign and it was ' . $q->em('great')) {
    $i++;
    print qq{<label><input type="radio" name="stars" value="$i" $checked/>$label</label><br />};
  }
  print '</p>';
  print $q->hidden('url', $url);
  print $q->hidden('toc', $toc);
  print $q->hidden('confirm', 1);
  print $q->submit('go', 'Continue');
  print $q->end_form();
}

# returns unquoted html
sub get_name {
  my $url = shift;
  my $tree = HTML::TreeBuilder->new_from_content(GetRaw($url));
  my $h = $tree->look_down('_tag', 'title');
  $h = $tree->look_down('_tag', 'h1') unless $h;
  $h = $h->as_text if $h;
  return $h;
}

sub post_addition {
  my ($url, $name, $toc, $summary) = @_;
  my $id = FreeToNormal($name);
  my $display = $name;
  utf8::decode($display); # we're dealing with user input
  utf8::decode($summary); # we're dealing with user input
  print $q->p("Adding ", GetUrl($url, $display), " to “$toc”.");
  # start with the homepage
  my @pages = GetPageContent($HomePage) =~ /\* \[\[(.*?)\]\]/g;
  for my $id (@pages) {
    return post($id, undef, $name, $summary, $url, GetParam('stars', '')) if $id eq $toc;
    my $data = GetPageContent(FreeToNormal($id));
    while ($data =~ /(\*+ ([^][\n]*))$/mg) {
      return post($id, $1, $name, $summary, $url, GetParam('stars', '')) if $2 eq $toc;
    }
  }
  print $q->p("Whoops. I was unable to find “$toc” in the wiki. Sorry!");
}

sub post {
  my ($id, $toc, $name, $summary, $url, $stars) = @_;
  my $data = GetPageContent(FreeToNormal($id));
  my $re = quotemeta($url);
  if ($data =~ /$re\s+(.*?)\]/) {
    my $display = $1;
    print $q->p($q->strong("Oops, we seem to have a problem!"));
    print $q->p(GetPageLink(NormalToFree($id)),
		" already links to the URL you submitted:",
	        GetUrl($url, $display));
    return;
  }
  $stars = ' ' . (':star:' x $stars) if $stars;
  $summary = ': ' . $summary if $summary;
  if ($toc) {
    $toc =~ /^(\*+)/;
    my $depth = "*$1"; # one more!
    my $regexp = quotemeta($toc);
    $data =~ s/$regexp/$toc\n$depth \[$url $name\]$summary$stars/;
  } else {
    $data = "* [$url $name]$summary$stars\n" . $data;
  }
  my $ua = LWP::UserAgent->new;
  my %params = (text => $data,
  		title => $id,
  		summary => $name,
  		username => GetParam('username'),
  		pwd => GetParam('pwd'));
  # spam fighting modules
  $params{$QuestionaskerSecretKey} = 1 if $QuestionaskerSecretKey;
  $params{$HoneyPotOk} = time if $HoneyPotOk;
  my $response = $ua->post($site, \%params);
  if ($response->is_error) {
    print $q->p("The submission failed!");
    print $q->pre($response->status_line . "\n"
  		  . $response->content);
  } else {
    print $q->p("See for yourself: ", GetPageLink($id));
  }
}

sub print_end_of_page {
    print $q->p('Questions? Send mail to Alex Schroeder <'
		. $q->a({-href=>'mailto:kensanata@gmail.com'},
			'kensanata@gmail.com') . '>');
    print $q->end_div();
    PrintFooter();
}

sub main {
  $ConfigFile = "$DataDir/config"; # read the global config file
  $DataDir = "$DataDir/$wiki";     # but link to the local pages
  Init();                          # read config file (no modules!)
  $ScriptName = $site;             # undo setting in the config file
  $FullUrl = $site;                #
  binmode(STDOUT,':utf8');
  $q->charset('utf8');
  if ($q->path_info eq '/source') {
    seek DATA, 0, 0;
    print "Content-type: text/plain; charset=UTF-8\r\n\r\n", <DATA>;
  } elsif ($q->path_info eq '/structure') {
    my ($values, $labels) = toc();
    my @indented = map {
      ($labels->{$_} || $_) =~ /^( *)/;
      [$_, length($1)]
    } @$values;
    print "Content-type: application/json; charset=UTF-8\r\n\r\n";
    binmode(STDOUT,':raw'); # because of encode_json
    print JSON::PP::encode_json(\@indented);
  } elsif ($q->path_info eq '/toc') {
    my ($values, $labels) = toc();
    print "Content-type: application/json; charset=UTF-8\r\n\r\n";
    binmode(STDOUT,':raw'); # because of encode_json
    print JSON::PP::encode_json($values);
  } elsif ($q->path_info eq '/top') {
    print GetHeader('', 'Top Blogs');
    print $q->start_div({-class=>'content top'});
    print $q->ol($q->li(top()));
    print_end_of_page();
  } elsif ($q->path_info =~ '^/match/(.*)') {
    my $term = $1;
    print GetHeader('', "Entries Matching '$term'");
    print $q->start_div({-class=>'content match'});
    print $q->o