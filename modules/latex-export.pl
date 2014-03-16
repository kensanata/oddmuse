use vars qw($LatexHeader @MyLaTeXRules);

my @LatexEnvironment;

sub OpenLatexEnvironment {
  my ($tag, $depth) = @_;
  while (@LatexEnvironment) {
    print "\\begin{" . pop(@LatexEnvironment) . "}\n";
  }
}

sub CloseLatexEnvironments {
  while (@LatexEnvironment) {
    print "\\end{" . pop(@LatexEnvironment) . "}\n";
  }
}

sub CloseLatexEnvironmentUntil {
}

sub AddLatexEnvironment {
}

sub InLatexEnvironment {
}

$LatexHeader = q{
\documentclass[a4paper]{article}
\usepackage[utf8]{inputenc}
\begin{document}
};

push(@MyAdminCode, \&LatexMenu);

sub LatexMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=latex;id=' . UrlEncode($id),
		  T('LaTeX export'), 'latex')) if $id;
}

$Action{latex} = \&DoLatex;

sub DoLatex {
  my $id = shift;

  OpenPage($id);

  # uploaded files
  if (my ($type) = TextIsFile($Page{text})) {
    ReportError(T('An uploaded file cannot be rendered as LaTeX.'),
		'400 BAD REQUEST');
  }

  print GetHttpHeader('application/x-latex');
  print $LatexHeader;

  print "\\title{" . NormalToFree($id) . "}\n";

  # authors
  my %contrib = ();
  for my $line (GetRcLines(1)) {
    my ($ts, $pagename, $minor, $summary, $host, $username) = @$line;
    $contrib{$username}++ if $username;
  }
  print "\\author{" . join(", ", sort(keys %contrib)) . "}\n" if %contrib;
  print "\\maketitle\n\n";

  # plain text
  if ($PlainTextPages{$id}) {
    print "\\begin{verbatim}\n";
    print $Page{text};
    print "\\end{verbatim}\n";
    return;
  }

  # process page content
  local *ApplyRules = *LatexApplyRules;
  $text = $Page{text};
  $text =~ s/$FS//go;   # field separator (this is paranoid)
  $text =~ s/\r\n/\n/g; # DOS to Unix
  $text =~ s/\n+$//g;   # No trailing paragraphs
  LatexApplyRules($text) if $text ne ''; # allow the text '0'
}

sub LatexApplyRules {
  my $text = shift;
  while (1) {
    # Block level elements should eat trailing empty lines to prevent empty p elements.
    if ($bol && m/\G(\s*\n)+/cg) {
      print "\n";
    } elsif ($bol && m/\G(\&lt;include(\s+(text|with-anchors))?\s+"(.*)"\&gt;[ \t]*\n?)/cgi) {
      # <include "uri..."> includes the text of the given URI verbatim
      my ($oldpos, $old_, $type, $uri) = ((pos), $_, $3, UnquoteHtml($4)); # remember, page content is quoted!
      if ($uri =~ /^($UrlProtocols):/o) {
	if ($type eq 'text') {
	  print "\\begin{verbatim}\n";
	  print GetRaw($uri);
	  print "\\end{verbatim}\n";
	} else {
	  LatexApplyRules(QuoteHtml(GetRaw($uri)));
	}
      } else {
	$Includes{$OpenPageName} = 1;
	local $OpenPageName = FreeToNormal($uri);
	if ($type eq 'text') {
	  print "\\begin{verbatim}\n";
	  print GetPageContent($OpenPageName);
	  print "\\end{verbatim}\n";
	} elsif (not $Includes{$OpenPageName}) { # watch out for recursion
	  LaTeXApplyRules(QuoteHtml(GetPageContent($OpenPageName)));
	  delete $Includes{$OpenPageName};
	} else {
	  print "\\textbf{" . Ts('Recursive include of %s!', $OpenPageName) . "}\n";
	}
      }
      ($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
    } elsif ($bol && m/\G(\&lt;journal(\s+(\d*))?(\s+"(.*?)")?(\s+(reverse|past|future))?(\s+search\s+(.*))?\&gt;[ \t]*\n?)/cgi) {
      print "\\textbf{" . T('Exporting of journal pages to LaTeX is not supported.') . "}\n";
    } elsif ($bol && m/\G(\&lt;rss(\s+(\d*))?\s+(.*?)\&gt;[ \t]*\n?)/cgis) {
      print "\\textbf{" . T('Exporting of RSS feeds to LaTeX is not supported.') . "}\n";
    } elsif (/\G(&lt;search (.*?)&gt;)/cgis) {
      print "\\textbf{" . T('Exporting of search results to LaTeX is not supported.') . "}\n";
    } elsif ($bol && m/\G(&lt;&lt;&lt;&lt;&lt;&lt;&lt; )/cg) {
	my ($str, $count, $limit, $oldpos) = ($1, 0, 100, pos);
	while (m/\G(.*\n)/cg and $count++ < $limit) {
	  $str .= $1;
	  last if (substr($1, 0, 29) eq '&gt;&gt;&gt;&gt;&gt;&gt;&gt; ');
	}
	if ($count >= $limit) {
	  pos = $oldpos; # reset because we did not find a match
	  print('<<<<<<< ');
	} else {
	  print "\\begin{verbatim}\n";
	  print $str;
	  print "\\end{verbatim}\n";
	}
      }
  } elsif ($bol and m/\G#REDIRECT/cg) {
    print "\\textbf{" . T('Exporting of redirections to LaTeX is not supported.') . "}\n";
  } elsif (LatexRunMyRules()) {
  } elsif (m/\G\s*\n(\s*\n)+/cg) { # paragraphs: at least two newlines
    print "\\n"; # another one like this further up
  } elsif (m/\G&amp;#([0-9]+);/cg) { # decimal entity reference
    print "\\char$1";
  } elsif (m/\G&amp;#x([A-Za-f0-9]+);/cg) { # hex entity reference
    print "\\char\"$1";
  } elsif (m/\G&amp;([A-Za-z]+);/cg) { # named entity references
    print " \\textbf{" . T('Exporting of named entity reference to LaTeX is not supported.') . "} ";
  } elsif (m/\G\s+/cg) {
    print " ";
  } elsif (m/\G([A-Za-z\x{0080}-\x{fffd}]+([ \t]+[a-z\x{0080}-\x{fffd}]+)*[ \t]+)/cg
	   or m/\G([A-Za-z\x{0080}-\x{fffd}]+)/cg or m/\G(\S)/cg) {
    print $1; # multiple words but do not match http://foo
  } else {
    last;
  }
  $bol = (substr($_,pos()-1,1) eq "\n");
    }
  }
  pos = length $_;  # notify module functions we've completed rule handling
  print "\\end{document}\n";
}

sub LatexRunMyRules {
  foreach my $sub (@MyLatexRules) {
    my $result = &$sub();
    return $result if defined($result);
  }
  return undef;
}

push (@MyLatexRules, \&LatexLinkRules);

sub LatexLinkRules {
  if ($BracketText && m/\G(\[$InterLinkPattern\s+([^\]]+?)\])/cog
      or $BracketText && m/\G(\[\[$FreeInterLinkPattern\|([^\]]+?)\]\])/cog
      or m/\G(\[$InterLinkPattern\])/cog or m/\G(\[\[\[$FreeInterLinkPattern\]\]\])/cog
      or m/\G($InterLinkPattern)/cog or m/\G(\[\[$FreeInterLinkPattern\]\])/cog) {
    # [InterWiki:FooBar text] or [InterWiki:FooBar] or
    # InterWiki:FooBar or [[InterWiki:foo bar|text]] or
    # [[InterWiki:foo bar]] or [[[InterWiki:foo bar]]]
    my $bracket = (substr($1, 0, 1) eq '[') # but \[\[$FreeInterLinkPattern\]\] it not bracket!
      && !((substr($1, 0, 2) eq '[[') && (substr($1, 2, 1) ne '[') && index($1, '|') < 0);
    my $quote = (substr($1, 0, 2) eq '[[');
    my $text = $3 || $2; # $3 may be empty
    # link target is stripped; brackets are stripped entirely
    print "\\underline{$text}" unless $bracket;
  } elsif ($BracketText && m/\G(\[$FullUrlPattern[|[:space:]]([^\]]+?)\])/cog
     or $BracketText && m/\G(\[\[$FullUrlPattern[|[:space:]]([^\]]+?)\]\])/cog
     or m/\G(\[$FullUrlPattern\])/cog or m/\G($UrlPattern)/cog) {
    # [URL text] makes [text] link to URL, [URL] makes footnotes [1]
    my ($str, $url, $text, $bracket, $rest) = ($1, $2, $3, (substr($1, 0, 1) eq '['), '');
    if ($url =~ /(&lt|&gt|&amp)$/) { # remove trailing partial named entitites and add them
      $rest = $1;      # back again at the end as trailing text.
      $url =~ s/&(lt|gt|amp)$//;
    }
    # link target is stripped; brackets are stripped entirely
    $text ||= $url;
    print "\\underline{$text}" unless $bracket;
  } elsif ($WikiLinks && m/\G!$LinkPattern/cog) {
    print "\\underline{$1}"; # ! gets eaten
  } elsif ($WikiLinks && $locallinks
     && ($BracketWiki && m/\G(\[$LinkPattern\s+([^\]]+?)\])/cog
         or m/\G(\[$LinkPattern\])/cog or m/\G($LinkPattern)/cog)) {
    # [LocalPage text], [LocalPage], LocalPage
    my $bracket = (substr($1, 0, 1) eq '[' and not $3);
    my $text = $3 || $2; # $3 may be empty
    print "\\underline{$text}" unless $bracket;
  } elsif ($locallinks && $FreeLinks && (m/\G(\[\[image:$FreeLinkPattern\]\])/cog
           or m/\G(\[\[image:$FreeLinkPattern\|([^]|]+)\]\])/cog)) {
    print " \\textbf{" . T('Exporting of images to LaTeX is not supported.') . "} ";
  } elsif ($FreeLinks && $locallinks
     && ($BracketWiki && m/\G(\[\[$FreeLinkPattern\|([^\]]+)\]\])/cog
         or m/\G(\[\[\[$FreeLinkPattern\]\]\])/cog
         or m/\G(\[\[$FreeLinkPattern\]\])/cog)) {
    # [[Free Link|text]], [[[Free Link]]], [[Free Link]]
    my $bracket = (substr($1, 0, 1) eq '[' and not $3);
    my $text = $3 || $2; # $3 may be empty
    print "\\underline{$text}" unless $bracket;
  } else {
    return undef;   # nothing matched
  }
  return '';     # one of the dirty rules matched (and they all are)
}

push (@MyLaTeXRules, \&LatexListRule);

sub ListRule {
  if ($bol && m/\G(\s*\n)*(\*+)[ \t]+/cg
      or InLatexEnvironment('li') && m/\G(\s*\n)+(\*+)[ \t]+/cg) {
    return CloseLatexEnvironmentUntil('li')
      . OpenLatexEnvironment('ul',length($2)) . AddLatexEnvironment('li');
  }
  return undef;
}
